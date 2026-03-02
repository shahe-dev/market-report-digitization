# batch-process.ps1
# 5-Stage Pipeline Orchestrator for MPP Resale Reports
# Stages: 1-Extraction, 2-Enhancement, 3-HTML, 4-QA, 5-Fix (if needed)

param(
    [switch]$Status,           # Show progress status only
    [switch]$Test,             # Process only first 3 files
    [string[]]$Slugs,          # Process specific slugs only
    [int]$StartFrom = 0,       # Start from specific index
    [int]$MaxRetries = 1       # Max fix/retry attempts per report
)

$ErrorActionPreference = "Continue"
$projectRoot = "$PSScriptRoot + "\..""
$progressFile = "$projectRoot\batch\processing-status.csv"
$outputDir = "$projectRoot\output"
$logFile = "$projectRoot\batch\batch-log.txt"

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Log function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Update CSV row status
function Update-RowStatus {
    param(
        [string]$Slug,
        [string]$Stage,
        [string]$Status,
        [string]$ErrorMessage = ""
    )

    $csv = Import-Csv $progressFile
    $row = $csv | Where-Object { $_.Slug -eq $Slug }
    if ($row) {
        $row.$Stage = $Status
        $row.LastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        if ($ErrorMessage) { $row.Error = $ErrorMessage }
        $csv | Export-Csv -Path $progressFile -NoTypeInformation -Encoding UTF8
    }
}

# Run Claude CLI and capture output
function Invoke-ClaudeStage {
    param(
        [string]$Prompt,
        [string]$OutputFile,
        [int]$TimeoutMinutes = 10
    )

    try {
        $result = & claude --print --model claude-opus-4-5-20251101 $Prompt 2>&1

        if ($LASTEXITCODE -eq 0 -and $result) {
            # Clean markdown code blocks if present
            $output = $result -join "`n"
            $output = $output -replace '```json\s*', '' -replace '```html\s*', '' -replace '```markdown\s*', '' -replace '```\s*$', '' -replace '^\s*```\s*', ''

            # For HTML files, strip any preamble text before <!DOCTYPE
            if ($OutputFile -match '\.html$' -and $output -match '<!DOCTYPE') {
                $doctypeIndex = $output.IndexOf('<!DOCTYPE')
                if ($doctypeIndex -gt 0) {
                    $output = $output.Substring($doctypeIndex)
                }
            }

            # For JSON files, strip any preamble text before { or [
            if ($OutputFile -match '\.json$') {
                $braceIdx = $output.IndexOf('{')
                $bracketIdx = $output.IndexOf('[')
                if ($braceIdx -ge 0 -or $bracketIdx -ge 0) {
                    $firstIdx = if ($braceIdx -ge 0 -and $bracketIdx -ge 0) { [Math]::Min($braceIdx, $bracketIdx) } elseif ($braceIdx -ge 0) { $braceIdx } else { $bracketIdx }
                    if ($firstIdx -gt 0) {
                        $output = $output.Substring($firstIdx)
                    }
                }
            }

            $output | Out-File $OutputFile -Encoding UTF8
            return @{ Success = $true; Output = $output }
        }
        else {
            return @{ Success = $false; Error = "Claude CLI returned error: $result" }
        }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# Parse QA report for status
function Get-QAStatus {
    param([string]$QAReportPath)

    if (-not (Test-Path $QAReportPath)) {
        return @{ Status = "ERROR"; Issues = @(); CanFix = $false }
    }

    $content = Get-Content $QAReportPath -Raw

    # Look for status line
    if ($content -match "Status:\s*(PASS|FAIL)") {
        $status = $Matches[1]
    }
    else {
        $status = "UNKNOWN"
    }

    # Check if issues are fixable
    $canFix = $content -match "Fixes Applied|surgical fix|targeted fix"

    return @{
        Status = $status
        Content = $content
        CanFix = $canFix
    }
}

# Load progress CSV
$csv = Import-Csv $progressFile
Write-Log "Loaded $($csv.Count) rows from progress file"

# Status mode: show summary and exit
if ($Status) {
    $stats = @{
        Total = $csv.Count
        Completed = ($csv | Where-Object { $_.FinalStatus -eq "PASS" }).Count
        Failed = ($csv | Where-Object { $_.FinalStatus -eq "FAIL" }).Count
        InProgress = ($csv | Where-Object { $_.Stage1Status -ne "" -and $_.FinalStatus -eq "" }).Count
        Pending = ($csv | Where-Object { $_.Stage1Status -eq "" }).Count
    }

    Write-Host "`n=========================================="
    Write-Host "         Batch Processing Status          "
    Write-Host "=========================================="
    Write-Host "Total:       $($stats.Total)"
    Write-Host "Completed:   $($stats.Completed) (PASS)"
    Write-Host "Failed:      $($stats.Failed) (FAIL after retries)"
    Write-Host "In Progress: $($stats.InProgress)"
    Write-Host "Pending:     $($stats.Pending)"
    Write-Host "==========================================`n"

    if ($stats.Failed -gt 0) {
        Write-Host "Failed reports:"
        $csv | Where-Object { $_.FinalStatus -eq "FAIL" } | ForEach-Object {
            Write-Host "  - $($_.Slug): $($_.Error)"
        }
    }
    exit
}

# Build processing queue
$queue = @()
$index = 0
foreach ($row in $csv) {
    $slug = $row.Slug

    # Skip if filtering by specific slugs
    if ($Slugs -and $Slugs -notcontains $slug) {
        continue
    }

    # Skip if already completed (PASS)
    if ($row.FinalStatus -eq "PASS") {
        continue
    }

    # Skip entries before StartFrom index
    if ($index -lt $StartFrom) {
        $index++
        continue
    }

    $queue += $row
    $index++

    # Test mode: limit to 3
    if ($Test -and $queue.Count -ge 3) {
        break
    }
}

Write-Log "Processing queue: $($queue.Count) reports"

# ============================================
# MAIN PROCESSING LOOP
# ============================================

$processedCount = 0
foreach ($row in $queue) {
    $slug = $row.Slug
    $canonicalUrl = $row.URL
    $pdfUrl = $row.'PDF Report Link'

    # Convert URL to local filename
    $pdfFilename = $pdfUrl -replace 'https://', 'https_' -replace '/', '_'
    $pdfPath = "$projectRoot\resale-report-pdfs\$pdfFilename"

    Write-Log "=========================================="
    Write-Log "Processing: $slug"
    Write-Log "PDF: $pdfFilename"

    # Check if PDF exists locally
    if (-not (Test-Path $pdfPath)) {
        Write-Log "SKIP: PDF not found at $pdfPath" "WARN"
        Update-RowStatus -Slug $slug -Stage "FinalStatus" -Status "SKIPPED" -ErrorMessage "PDF not found"
        continue
    }

    # Define output paths
    $extractedPath = "$outputDir\$slug-extracted.json"
    $enhancedPath = "$outputDir\$slug-enhanced.json"
    $htmlPath = "$outputDir\$slug.html"
    $qaReportPath = "$outputDir\$slug-qa-report.md"

    # ----------------------------------------
    # STAGE 1: PDF Extraction
    # ----------------------------------------
    if ($row.Stage1Status -ne "completed") {
        Write-Log "Stage 1: Extracting PDF data..."
        Update-RowStatus -Slug $slug -Stage "Stage1Status" -Status "in_progress"

        $prompt = @"
You are a PDF data extraction specialist. Your task is to extract structured data from a real estate PDF report.

**Instructions:**
1. Read the PDF at: $pdfPath
2. Read the extraction schema at: prompts/pdf-extraction-prompt.md
3. Extract ALL data following the schema exactly
4. The canonicalUrl for this report is: $canonicalUrl

**Critical Requirements:**
- Extract ALL numerical data with exact values
- Capture ALL graph data points
- Include ALL table rows
- Preserve original formatting for currency (AED)
- Do NOT enhance or modify data - extract only
- For priceInsights and rentalInsights: capture BOTH priceYoyChange AND transactionYoyChange

Output ONLY the JSON. No explanation, no markdown code blocks.
"@

        $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $extractedPath
        if ($result.Success) {
            Write-Log "Stage 1 complete: $extractedPath"
            Update-RowStatus -Slug $slug -Stage "Stage1Status" -Status "completed"
        }
        else {
            Write-Log "Stage 1 FAILED: $($result.Error)" "ERROR"
            Update-RowStatus -Slug $slug -Stage "Stage1Status" -Status "failed" -ErrorMessage $result.Error
            continue
        }
    }
    else {
        Write-Log "Stage 1: Using existing extracted file"
    }

    # ----------------------------------------
    # STAGE 2: Content Enhancement
    # ----------------------------------------
    if ($row.Stage2Status -ne "completed") {
        Write-Log "Stage 2: Enhancing content..."
        Update-RowStatus -Slug $slug -Stage "Stage2Status" -Status "in_progress"

        $prompt = @"
You are a content enhancement specialist for real estate market reports. Your task is to enhance extracted data with SEO content, narrative summaries, and component selections.

**Instructions - EXECUTE IN ORDER:**

**STEP 1: Component Selection (MANDATORY FIRST)**
1. Read the extracted JSON at: $extractedPath
2. Read the component selection rules at: prompts/component-selection-rules.md
3. Execute the 5-step selection process:
   - Step 1: Data Inventory (record what data types exist)
   - Step 2: Evaluate characteristics (point counts, category counts, variance ratios)
   - Step 3: Select components using decision rules
   - Step 4: Validate against anti-patterns
   - Step 5: Record selection rationale

**STEP 2: Content Enhancement**
4. Read the content guidelines at: prompts/content-enhancement-prompt.md
5. Read the full schema at: mpp-real-estate-reports-skill-with-json/json-schema.md
6. Enhance the JSON with:
   - SEO metadata (title, description, h1)
   - Executive summary
   - Chart summaries that REFERENCE the selected visualization types
   - Section ordering based on data emphasis
   - Conditional section flags
   - Investor considerations
   - schemaOrg JSON-LD structure

**Critical Requirements:**
- Preserve ALL original extracted data
- Populate dataInventory, dataEvaluation, componentSelections, componentSelectionRationale, validation
- Add enhanced.* fields per schema
- Chart summaries must match component type language (e.g., "The line traces..." for line charts)
- All numbers must match source data exactly
- validation.validationPassed must be true

Output ONLY the JSON. No explanation, no markdown code blocks.
"@

        $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $enhancedPath
        if ($result.Success) {
            Write-Log "Stage 2 complete: $enhancedPath"
            Update-RowStatus -Slug $slug -Stage "Stage2Status" -Status "completed"
        }
        else {
            Write-Log "Stage 2 FAILED: $($result.Error)" "ERROR"
            Update-RowStatus -Slug $slug -Stage "Stage2Status" -Status "failed" -ErrorMessage $result.Error
            continue
        }
    }
    else {
        Write-Log "Stage 2: Using existing enhanced file"
    }

    # ----------------------------------------
    # STAGE 3: HTML Generation
    # ----------------------------------------
    if ($row.Stage3Status -ne "completed") {
        Write-Log "Stage 3: Generating HTML..."
        Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "in_progress"

        $prompt = @"
You are an HTML generation specialist for real estate market reports.

**CRITICAL: You are running in --print mode. Do NOT use any tools. Do NOT ask for permissions. Simply READ the files and PRINT the HTML output directly to stdout.**

**Instructions:**
1. Read the enhanced JSON at: $enhancedPath
2. Read the HTML templates at: prompts/html-generation-prompt.md
3. Read the CSS from: mpp-real-estate-reports-skill-with-json/component-library.html (use the CSS styles)
4. Generate complete HTML following:
   - Section order from enhanced.sectionOrder
   - Components from enhanced.componentSelections
   - Narrative styles from enhanced.narrativeStyle
   - Include/exclude sections per enhanced.conditionalSections

**Critical Requirements:**
- Embed ALL CSS inline (self-contained file)
- Include Schema.org JSON-LD from schemaOrg
- All ARIA labels for accessibility
- All container elements with max-width must have margin: 0 auto for centering
- Data tables for each chart (toggleable)
- All values must match source JSON exactly

**OUTPUT INSTRUCTIONS:**
Print the complete HTML directly. Start with <!DOCTYPE html> and end with </html>.
No explanation, no markdown code blocks, no permission requests. Just raw HTML.
"@

        $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $htmlPath
        if ($result.Success) {
            # Validate HTML output - must start with <!DOCTYPE or <html
            $htmlContent = Get-Content $htmlPath -Raw -ErrorAction SilentlyContinue
            $htmlSize = (Get-Item $htmlPath -ErrorAction SilentlyContinue).Length

            if ($htmlSize -lt 5000 -or $htmlContent -notmatch '<!DOCTYPE|<html') {
                Write-Log "Stage 3 FAILED: Output is not valid HTML (size: $htmlSize bytes)" "ERROR"
                Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "failed" -ErrorMessage "Invalid HTML output"

                # Retry Stage 3 once
                Write-Log "Retrying Stage 3..."
                $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $htmlPath
                $htmlContent = Get-Content $htmlPath -Raw -ErrorAction SilentlyContinue
                $htmlSize = (Get-Item $htmlPath -ErrorAction SilentlyContinue).Length

                if ($htmlSize -lt 5000 -or $htmlContent -notmatch '<!DOCTYPE|<html') {
                    Write-Log "Stage 3 RETRY FAILED: Still not valid HTML" "ERROR"
                    Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "failed" -ErrorMessage "Invalid HTML after retry"
                    continue
                }
            }

            Write-Log "Stage 3 complete: $htmlPath ($htmlSize bytes)"
            Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "completed"
        }
        else {
            Write-Log "Stage 3 FAILED: $($result.Error)" "ERROR"
            Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "failed" -ErrorMessage $result.Error
            continue
        }
    }
    else {
        Write-Log "Stage 3: Using existing HTML file"
    }

    # ----------------------------------------
    # STAGE 4: Quality Assurance
    # ----------------------------------------
    Write-Log "Stage 4: Running QA validation..."
    Update-RowStatus -Slug $slug -Stage "Stage4Status" -Status "in_progress"

    $prompt = @"
You are a QA specialist for real estate market reports. Your task is to validate accuracy, consistency, and quality across all pipeline outputs.

**CRITICAL: Data accuracy issues are FAIL, not warnings. Any numerical discrepancy blocks the pipeline.**

**Instructions:**
1. Read the extracted JSON at: $extractedPath
2. Read the enhanced JSON at: $enhancedPath
3. Read the HTML file at: $htmlPath
4. Perform all validation checks from the QA checklist in prompts/orchestration-plan.md

**FAIL Criteria (Any = FAIL):**
- Any number in HTML differs from source JSON
- Any percentage calculation off by >0.5%
- Any chart data point label shows wrong value
- Any data missing from output
- Container elements with max-width missing margin: 0 auto

**Validation Checklist:**
1. Data Integrity: All values match across extracted -> enhanced -> HTML
2. Chart Calculations: Y-axis uniform intervals, correct positions
3. Component Consistency: Sections in correct order
4. Enhanced JSON: All percentages mathematically correct
5. Technical Quality: HTML well-formed, CSS complete

Output a QA report in markdown format with:
- Status: PASS or FAIL
- Blocking Issues count
- Detailed findings
- For FAIL: List each issue with responsible stage

Output ONLY the markdown report. No extra text.
"@

    $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $qaReportPath
    if (-not $result.Success) {
        Write-Log "Stage 4 FAILED to generate report: $($result.Error)" "ERROR"
        Update-RowStatus -Slug $slug -Stage "Stage4Status" -Status "failed" -ErrorMessage $result.Error
        continue
    }

    # Parse QA results
    $qaResult = Get-QAStatus -QAReportPath $qaReportPath
    Write-Log "Stage 4 complete: QA Status = $($qaResult.Status)"
    Update-RowStatus -Slug $slug -Stage "Stage4Status" -Status $qaResult.Status

    # ----------------------------------------
    # STAGE 5: Analyze Failures (if QA FAIL)
    # ----------------------------------------
    if ($qaResult.Status -eq "FAIL") {
        Write-Log "Stage 5: Analyzing QA failures..."
        Update-RowStatus -Slug $slug -Stage "Stage5Status" -Status "in_progress"

        # Check if this is a Stage 3 regeneration issue
        $qaContent = Get-Content $qaReportPath -Raw
        if ($qaContent -match "Stage 3|HTML generation|HTML not generated|placeholder") {
            Write-Log "Stage 5: QA indicates Stage 3 failure - regenerating HTML..."

            # Reset Stage 3 and retry
            Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "retry"

            $prompt = @"
You are an HTML generation specialist for real estate market reports.

**CRITICAL: You are running in --print mode. Do NOT use any tools. Do NOT ask for permissions. Simply READ the files and PRINT the HTML output directly to stdout.**

**Instructions:**
1. Read the enhanced JSON at: $enhancedPath
2. Read the HTML templates at: prompts/html-generation-prompt.md
3. Read the CSS from: mpp-real-estate-reports-skill-with-json/component-library.html (use the CSS styles)
4. Generate complete HTML following:
   - Section order from enhanced.sectionOrder
   - Components from enhanced.componentSelections
   - Narrative styles from enhanced.narrativeStyle
   - Include/exclude sections per enhanced.conditionalSections

**Critical Requirements:**
- Embed ALL CSS inline (self-contained file)
- Include Schema.org JSON-LD from schemaOrg
- All ARIA labels for accessibility
- All container elements with max-width must have margin: 0 auto for centering
- Data tables for each chart (toggleable)
- All values must match source JSON exactly

**OUTPUT INSTRUCTIONS:**
Print the complete HTML directly. Start with <!DOCTYPE html> and end with </html>.
No explanation, no markdown code blocks, no permission requests. Just raw HTML.
"@

            $result = Invoke-ClaudeStage -Prompt $prompt -OutputFile $htmlPath
            $htmlContent = Get-Content $htmlPath -Raw -ErrorAction SilentlyContinue
            $htmlSize = (Get-Item $htmlPath -ErrorAction SilentlyContinue).Length

            if ($htmlSize -gt 5000 -and $htmlContent -match '<!DOCTYPE|<html') {
                Write-Log "Stage 5: HTML regeneration successful ($htmlSize bytes)"
                Update-RowStatus -Slug $slug -Stage "Stage3Status" -Status "completed"
                Update-RowStatus -Slug $slug -Stage "Stage5Status" -Status "completed"

                # Re-run QA
                Write-Log "Re-running QA after regeneration..."
                $qaPrompt = @"
You are a QA specialist. Validate the regenerated HTML report.

**CRITICAL: You are in --print mode. Just read the files and output markdown.**

Files to validate:
- Extracted: $extractedPath
- Enhanced: $enhancedPath
- HTML: $htmlPath

Output a brief QA report with Status: PASS or FAIL.
"@
                $null = Invoke-ClaudeStage -Prompt $qaPrompt -OutputFile $qaReportPath
                $qaResult = Get-QAStatus -QAReportPath $qaReportPath
                Write-Log "Re-run QA Status: $($qaResult.Status)"
                Update-RowStatus -Slug $slug -Stage "Stage4Status" -Status $qaResult.Status
            }
            else {
                Write-Log "Stage 5: HTML regeneration still failed" "ERROR"
                Update-RowStatus -Slug $slug -Stage "Stage5Status" -Status "failed" -ErrorMessage "HTML regeneration failed"
            }
        }
        else {
            # For other QA failures, log for manual review
            Write-Log "Stage 5: QA failed with non-regeneratable issues - marked for manual review" "WARN"
            Update-RowStatus -Slug $slug -Stage "Stage5Status" -Status "needs_review"
        }
    }

    # ----------------------------------------
    # FINAL STATUS
    # ----------------------------------------
    if ($qaResult.Status -eq "PASS") {
        Write-Log "SUCCESS: $slug completed with QA PASS"
        Update-RowStatus -Slug $slug -Stage "FinalStatus" -Status "PASS"
        $processedCount++
    }
    else {
        Write-Log "REQUIRES REVIEW: $slug completed but QA did not pass" "WARN"
        Update-RowStatus -Slug $slug -Stage "FinalStatus" -Status "FAIL" -ErrorMessage "QA did not pass after fix attempt"
    }

    # Pause between reports
    Write-Log "Pausing 15 seconds before next report..."
    Start-Sleep -Seconds 15
}

Write-Log "=========================================="
Write-Log "Batch complete. Processed: $processedCount reports"
Write-Log "Check progress: .\batch\batch-process.ps1 -Status"
