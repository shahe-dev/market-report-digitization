# MPP Report Orchestrator Launcher
# Single-report mode only - use run-batch.ps1 for multiple reports

param(
    [string]$Slug,           # Process single report (required for processing)
    [switch]$Status          # Show current status
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

# Status check - simple CSV read
if ($Status) {
    $csv = Import-Csv "$ProjectRoot\batch\processing-status.csv"
    $completed = ($csv | Where-Object { $_.FinalStatus -eq "completed" }).Count
    $pending = ($csv | Where-Object { $_.FinalStatus -ne "completed" }).Count
    $failed = ($csv | Where-Object { $_.FinalStatus -eq "failed" }).Count

    Write-Host "=== Processing Status ===" -ForegroundColor Cyan
    Write-Host "Completed: $completed"
    Write-Host "Pending:   $pending"
    Write-Host "Failed:    $failed"
    Write-Host ""
    Write-Host "Next pending reports:"
    $csv | Where-Object { $_.FinalStatus -ne "completed" } | Select-Object -First 5 | ForEach-Object {
        Write-Host "  - $($_.Slug)"
    }
    exit 0
}

# Require -Slug for processing
if (-not $Slug) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\run-orchestrator.ps1 -Slug <report-slug>  # Process single report"
    Write-Host "  .\run-orchestrator.ps1 -Status              # Show status"
    Write-Host ""
    Write-Host "For multiple reports, use run-batch.ps1:" -ForegroundColor Gray
    Write-Host "  .\run-batch.ps1 -Limit 5                    # Process next 5 pending"
    Write-Host "  .\run-batch.ps1                             # Process all pending"
    exit 1
}

$prompt = @"
You are an autonomous report generation orchestrator.

**Read consolidated-orchestration-plan.md - this is your ONLY source of truth.**

The orchestration plan contains EVERYTHING you need:
- Pipeline architecture and agent definitions
- Which prompt files to read for each stage
- CSV update function and exact update sequence
- PDF path derivation rules
- Validation checkpoints
- Error handling

**Your task**: Process ONLY the report with slug: $Slug

**Execution**:
1. Read consolidated-orchestration-plan.md FIRST
2. Read batch/processing-status.csv to find the report row
3. Follow the "Update Sequence Per Report" section EXACTLY
4. Update the CSV after EVERY status change using the documented function
5. Exit when this single report is complete (PASS or FAIL)

Start now.
"@

Write-Host "=== MPP Report Orchestrator ===" -ForegroundColor Cyan
Write-Host "Processing: $Slug" -ForegroundColor Yellow
Write-Host "Starting Claude Code session..." -ForegroundColor Gray
Write-Host ""

# Change to project root and run Claude
Set-Location $ProjectRoot
claude --dangerously-skip-permissions -p $prompt
