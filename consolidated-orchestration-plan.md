# BRAND Resale Reports - Consolidated Multi-Agent Orchestration Plan

## Overview

This plan defines a 5-stage multi-agent pipeline for converting PDF resale reports to structured JSON and HTML. Each agent operates with fresh context, passing data via JSON files. A QA agent validates accuracy with Pass/Fail decisions, and a Fix Agent handles surgical corrections before full retry fallback.

**Source**: Consolidated from `prompts/orchestration-plan.md` (Pipeline) and `mpp-resale-reports-orchestration-plan.md` (Main). Original plans retained for reference.

---

## Design Decisions

| Decision | Choice | Source |
|----------|--------|--------|
| QA Philosophy | Pass/Fail binary | Pipeline |
| Fix Agent | Yes - Stage 5 surgical edits | Pipeline |
| Stage Structure | 5-stage linear | Pipeline |
| Output Structure | Flat with suffixes | Pipeline |
| Source of Truth | JSON from Stage 2 | Pipeline |
| Escalation Path | Fix -> Retry -> Escalate | Pipeline |
| CSV Metadata | Separate step in Stage 1 | Main |
| Data Analysis | Removed - source data pre-verified | Updated |
| Agent Definitions | 8 agents total | Updated |
| JSON Generator | Removed - Content Enhancement outputs final JSON | Updated |
| CSS QA | General layout check | Main |
| Human Review | Phased sampling | Main |
| Component Library | Single source v5-SEO | Main |
| SEO Validation | Separate score alongside Pass/Fail | New |
| Scope | Single-report focus | New |
| Component Selection | Algorithmic with mandatory evaluation steps | Updated |
| Prompt Architecture | Separated: selection rules + content generation | Updated |

---

## Pipeline Architecture

```
User Request: "Process [PDF_PATH]"
         |
         v
+------------------+
|   ORCHESTRATOR   |  (You - Claude Code main session)
+------------------+
         |
         | 1. Validate PDF exists
         | 2. Derive output filename from PDF
         v
+------------------+
|     STAGE 1      |  Ingestion Layer
+------------------+
    |-- PDF Extraction Agent
    |-- CSV Metadata Agent
    Output: output/[name]-extracted.json
         |
         v
+------------------+
|     STAGE 2      |  Processing Layer
+------------------+
    |-- Content Enhancement Agent (with Component Selection)
    Output: output/[name].json
         |
         v
+------------------+
|     STAGE 3      |  Output Layer
+------------------+
    |-- HTML Generator Agent
    Output: output/[name].html
         |
         v
+------------------+
|     STAGE 4      |  Quality Assurance
+------------------+
    |-- QA Agent
    Output: output/[name]-qa-report.md
         |
    +----+----+
    |         |
  PASS      FAIL
    |         |
    v         v
COMPLETE   STAGE 5
               |
               v
        +------------------+
        |     STAGE 5      |  Fix Agent
        +------------------+
            Input:  QA report + affected files
            Output: Patched files in place
               |
               v
        +------------------+
        |  RE-RUN QA       |
        +------------------+
               |
          +----+----+
          |         |
        PASS      FAIL
          |         |
          v         v
      COMPLETE   FULL RETRY
                     |
                     v
             ESCALATE to user
```

---

## Agent Definitions

### 1. Master Coordinator Agent (Orchestrator)

**Role**: Central orchestration and workflow management

**Responsibilities**:
- Validate PDF exists and derive output filename
- Execute stages sequentially
- Pass data between agents via JSON files
- Monitor for failures and trigger fix/retry loops
- Report final status to user

**State Tracking** (per report):
```json
{
  "report_name": "business-bay-h1-2024",
  "status": "pending | stage_1 | stage_2 | stage_3 | stage_4 | stage_5 | completed | failed",
  "current_stage": 1,
  "qa_attempts": 0,
  "fix_attempts": 0,
  "error_log": []
}
```

---

### 2. PDF Extraction Agent

**Role**: Extract structured data from PDF reports using Claude vision

**Prompt Reference**: `prompts/pdf-extraction-prompt.md`

**Input**: PDF file path

**Output**: `output/[name]-extracted.json`

**Extraction Targets**:
| Data Type | Extraction Method | Validation |
|-----------|-------------------|------------|
| Metadata | Header text parsing | community, period, propertyType present |
| KPIs | Large headline numbers | Numeric values with YoY changes |
| Price Insights | Bedroom breakdown cards | Rows with price + transactions + YoY |
| Charts | Data point labels | Points array with xAxis/yAxis |
| Raw Text | Verbatim copy | headerText, insightText, footnotes |
| Visual Descriptions | Chart type identification | chartTypes, colorCoding, layoutNotes |

**Critical Requirements**:
- Extract exact values (AED 1,744 not 1744)
- Capture both price YoY and transaction YoY separately
- Build dataTable arrays from chart points
- Do NOT enhance or modify data - extract only

---

### 3. CSV Metadata Agent

**Role**: Enrich extracted data with URL mappings

**Input**: CSV file path, PDF filename

**Output**: Updated `output/[name]-extracted.json` with canonicalUrl

**Responsibilities**:
- Load CSV mapping PDFs to webpage URLs
- Match PDF filename to canonical URL
- Add `metadata.canonicalUrl` to extracted JSON
- Validate URL format

---

### 4. Content Enhancement Agent (with Component Selection)

**Role**: Transform extracted data into SEO-optimized content AND select visualization components

**Prompt References**:
- `prompts/component-selection-rules.md` - **Execute FIRST** (algorithmic component selection)
- `prompts/content-enhancement-prompt.md` - Execute SECOND (content generation with inline threshold reference)

**Input**: `output/[name]-extracted.json`

**Output**: `output/[name].json`

**Execution Order** (MANDATORY):
```
STEP 1: Execute component-selection-rules.md
        -> Populate: dataInventory, dataEvaluation, componentSelections, validation

STEP 2: Execute content-enhancement-prompt.md
        -> Populate: enhanced.* fields, schemaOrg, seoMetaContent
```

**Responsibilities**:
- **Component Selection** (Step 1):
  - Inventory data types present in extracted JSON
  - Evaluate data characteristics (point counts, category counts, variance ratios)
  - Apply deterministic selection rules with hard thresholds
  - Validate selections against anti-pattern checklist
  - Document rationale for each selection

- **Content Generation** (Step 2):
  - Write component-aware summaries that reference selected visuals
  - Generate executiveSummaryEnhanced (2-3 sentences, lead with key metric)
  - Write chartSummaries describing trends AND visual elements
  - Create marketDynamicsEnhanced (3 paragraphs)
  - Generate marketInsightsEnhanced
  - Create investorConsiderationsEnhanced (5 structured factors)
  - Generate seoMetaContent (title, description, H1)
  - Generate schemaOrg object for JSON-LD

**Component Selection Thresholds** (from rulebook):
| Threshold | Value | Component ID |
|-----------|-------|--------------|
| Time-series points | >= 3, 1 series | `area-line` |
| Time-series points | >= 3, 2-3 series | `multi-line` |
| Time-series points | 2 periods | `grouped-column` |
| Categories | > 12 | `data-table` |
| Label length | > 15 chars | `bar` |
| Stacked segments | > 4 | `data-table` |
| Line series | > 3 | `data-table` |
| Rankings | any | `bar` |
| Period comparison | 2 periods, <= 6 categories | `grouped-column` |
| Composition | 2-4 segments | `stacked-column` |
| Binary ratio | 2 values summing to 100% | `comparison-cards` |
| Entity comparison | 2-4 entities, qualitative | `comparison-table` |
| Volume + yield pairing | hierarchical metrics | `indicators-block` |
| Peer-level KPIs | 4 equal metrics | `kpi-strip` |

**Writing Standards**:
- Use specific numbers with AED formatting
- Include YoY comparisons ("up 9.4% from H1 2024")
- Add market context where available
- Reference visualization types in summaries (must match componentSelections)
- NO promotional language or CTAs
- NO vague descriptors without supporting data

**Source of Truth**: The JSON output is the source of truth for all downstream stages.

---

### 5. HTML Generator Agent

**Role**: Assemble complete HTML report from JSON and component library

**Prompt Reference**: `prompts/html-generation-prompt.md`

**Input**:
- `output/[name].json`
- `MPP-COMPONENTS-LIBRARY-v5-SEO.html`

**Output**: `output/[name].html`

**Responsibilities**:
- Build HTML document structure from template
- Integrate CSS from component library (lines 10-1699)
- Render selected components with actual data
- Calculate chart dimensions and positions
- Generate SVG paths for line charts
- Insert Schema.org JSON-LD from schemaOrg object
- Add hidden data tables for each visualization
- Apply section ordering from sectionOrder
- Include/exclude sections per conditionalSections

**Critical Requirements**:
- Embed ALL CSS inline (self-contained file)
- All container elements with max-width must have `margin: 0 auto`
- SVG charts must have `vector-effect="non-scaling-stroke"` for dashed lines
- All values must match JSON exactly
- Include `.sr-only.chart-data-table` CSS
- ARIA labels for accessibility

---

### 6. QA Agent

**Role**: Validate accuracy, consistency, and quality across all outputs

**Input**:
- `output/[name]-extracted.json`
- `output/[name].json`
- `output/[name].html`

**Output**: `output/[name]-qa-report.md`

**Decision**: **PASS** or **FAIL** (binary)

**SEO Score**: Tracked separately alongside Pass/Fail (0-100)

#### FAIL Criteria (Any = FAIL)

| Category | FAIL Conditions |
|----------|-----------------|
| Data Values | Any number in HTML differs from JSON |
| Percentages | Any calculated percentage differs from source by >0.5% |
| Chart Labels | Any data point label shows wrong value |
| Chart Positions | Data point vertical position >2% off from calculated value |
| Y-Axis Scale | Non-uniform intervals that misrepresent data proportions |
| Missing Data | Any data point, row, or metric omitted from output |
| Wrong Calculation | Any derived statistic in JSON incorrect |
| JSON-HTML Mismatch | Enhanced JSON narrative differs from HTML narrative |
| Container Centering | Elements with max-width missing horizontal centering |

#### WARNING Criteria (Non-blocking)

| Category | WARNING Conditions |
|----------|-------------------|
| Formatting | Currency format variations (AED 1,000 vs AED 1000) |
| Styling | Minor CSS inconsistencies that don't hide data |
| Accessibility | Missing but non-critical ARIA labels |
| SEO | Meta description slightly over character limit |

**Rule: When in doubt, classify as FAIL.**

#### Validation Checklist

**1. Data Integrity (Extracted -> Enhanced)**
- [ ] All keyPerformance values preserved exactly
- [ ] All priceInsights rows preserved exactly
- [ ] All graph data points preserved exactly
- [ ] No numbers modified or rounded differently

**2. Data Integrity (Enhanced -> HTML)**
- [ ] KPI card values match keyPerformance
- [ ] Table cell values match priceInsights
- [ ] Chart data point labels match graph values
- [ ] All percentages match source calculations

**3. Chart Calculations**
- [ ] Y-axis uses UNIFORM intervals
- [ ] Data point positions calculated correctly (tolerance: 2%)
- [ ] SVG path coordinates match data point positions

**4. Enhanced JSON Validation**
- [ ] All chartSummaries percentages are mathematically correct
- [ ] executiveSummaryEnhanced numbers match keyPerformance
- [ ] No hallucinated statistics in enhanced.* fields

**5. SEO/Accessibility (General Layout)**
- [ ] Schema.org JSON-LD present in `<head>`
- [ ] All charts have hidden data tables
- [ ] ARIA attributes complete
- [ ] Container elements centered with margin: 0 auto

**SEO Score Calculation**:
```
SEO Score = (
  Schema.org Complete * 30 +
  Hidden Data Tables Present * 25 +
  ARIA Attributes Complete * 20 +
  Chart Summaries Present * 15 +
  Data Source Citations * 10
)
```

---

### 7. Fix Agent

**Role**: Make targeted surgical edits to fix specific QA issues

**Triggered**: On QA FAIL

**Input**:
- `output/[name]-qa-report.md`
- Affected files (JSON and/or HTML)

**Output**: Patched files in place

**Fixable Issue Types**:
| Issue Type | Fix Action | Target File |
|------------|------------|-------------|
| Y-axis non-uniform intervals | Calculate uniform steps, edit labels | HTML |
| Wrong percentage in summary | Recalculate from source, edit text | JSON + HTML |
| Data point position error | Recalculate %, edit CSS top value | HTML |
| SVG path mismatch | Recalculate coordinates, edit path d= | HTML |
| Value mismatch (JSON to HTML) | Copy correct value from JSON | HTML |
| Container centering missing | Add margin: 0 auto to CSS rules | HTML |

**CRITICAL**: Fix Agent MUST fix BOTH JSON AND HTML when a calculated value is wrong. Enhanced JSON is the source of truth.

**Unfixable Issues (Triggers Full Retry)**:
| Issue Type | Fallback |
|------------|----------|
| Source data extraction error | Re-run Stage 1 |
| Missing enhanced fields | Re-run Stage 2 |
| Wrong component selected | Re-run Stage 3 |
| Missing entire section | Re-run Stage 2 or 3 |

---

### 8. Final Assembly Agent

**Role**: Package outputs for delivery (batch operations)

**Note**: This agent handles batch concerns separately from single-report processing.

**Responsibilities**:
- Create output directory structure
- Generate manifest/index for batch
- Create quality summary report
- Archive processing logs

---

## File Naming Convention

From PDF path: `resale-report-pdfs/https_your-company.com_wp-content_uploads_2024_08_RR-Business-Bay-H1-2024.pdf`

Extract: `business-bay-h1-2024`

**Output files** (flat structure with suffixes):
```
output/business-bay-h1-2024-extracted.json  (Stage 1)
output/business-bay-h1-2024.json            (Stage 2)
output/business-bay-h1-2024.html            (Stage 3)
output/business-bay-h1-2024-qa-report.md    (Stage 4)
```

---

## Fix Loop Execution

```
IF status == FAIL:

    # STEP 1: Try targeted fixes first
    1. Run Stage 5 Agent (Fix Agent)
    2. Parse Fix Agent output for "Recommendation"

    IF recommendation == "RE-RUN QA":
        3. Re-run Stage 4 (QA)
        4. IF PASS: Complete
        5. IF FAIL: Continue to Step 2

    # STEP 2: Fallback to full retry
    IF recommendation == "FULL RETRY NEEDED" OR fix failed:
        6. Read "Failure Attribution" from QA report
        7. Identify responsible stage
        8. Re-run that stage with QA feedback
        9. Re-run downstream dependencies
        10. Re-run Stage 4 (QA)
        11. IF PASS: Complete
        12. IF FAIL: ESCALATE to user

ESCALATE:
    Report to user: "Pipeline failed after fix attempt and full retry"
    Show remaining issues
    Ask user: "Manual fix or abort?"
```

### Downstream Dependencies

| Retried Stage | Also Re-run |
|---------------|-------------|
| Stage 1 | Stage 2, Stage 3 |
| Stage 2 | Stage 3 |
| Stage 3 | (none) |

Always re-run Stage 4 (QA) after any fix or retry.

---

## Human Review Strategy (Phased Sampling)

| Phase | Reports | Review % | Criteria |
|-------|---------|----------|----------|
| Pilot | 10 | 100% | Full human review of all outputs |
| Validation | 50 | 20% | Random sample + all flagged |
| Production | Remaining | 5% | Random sample + flagged only |

**Flag Triggers**:
- Novel data patterns (outliers, anomalies)
- Significant YoY changes (>100% or <-50%)
- Missing sections that should be present
- SEO Score < 80

---

## Orchestrator Checklist

**Before Each Stage**:
- [ ] Verify input file(s) exist
- [ ] Verify prompt files exist

**After Stage 1**:
- [ ] Verify extracted JSON exists
- [ ] Verify JSON is valid (parseable)
- [ ] Verify metadata fields populated

**After Stage 2**:
- [ ] Verify JSON exists
- [ ] Verify dataEvaluation populated (component selection step completed)
- [ ] Verify componentSelections present with rationale
- [ ] Verify validation.validationPassed == true
- [ ] Verify enhanced content fields present (executiveSummaryEnhanced, chartSummaries, etc.)
- [ ] Verify schemaOrg object present

**After Stage 3**:
- [ ] Verify HTML file exists
- [ ] Verify file size > 10KB
- [ ] Verify JSON file exists

**After Stage 4**:
- [ ] Read QA report status (PASS/FAIL)
- [ ] Read SEO Score
- [ ] If FAIL: Execute fix loop
- [ ] If PASS: Report completion

**After Stage 5 (if triggered)**:
- [ ] Parse Fix Agent recommendation
- [ ] If "RE-RUN QA": Re-run Stage 4
- [ ] If "FULL RETRY NEEDED": Identify stage and retry

---

## Progress Tracking

### Status CSV: `batch/processing-status.csv`

This file tracks processing progress for all reports. The orchestrator MUST update this file after each stage.

**CSV Columns**:

| Column | Purpose | Read-Only | Values |
|--------|---------|-----------|--------|
| `Id` | WordPress post ID | YES | Integer |
| `Slug` | Report identifier (use for file naming) | YES | String |
| `FilenameSuggestion` | Output filename | YES | `[slug].json` |
| `URL` | Target webpage URL (canonicalUrl) | YES | HTTPS URL |
| `PDF Report Link` | Source PDF URL | YES | HTTPS URL |
| `Stage1Status` | PDF Extraction status | NO | `""`, `"in_progress"`, `"completed"`, `"failed"` |
| `Stage2Status` | Content Enhancement status | NO | `""`, `"in_progress"`, `"completed"`, `"failed"` |
| `Stage3Status` | HTML Generation status | NO | `""`, `"in_progress"`, `"completed"`, `"failed"`, `"retry"` |
| `Stage4Status` | QA status | NO | `""`, `"in_progress"`, `"PASS"`, `"FAIL"` |
| `Stage5Status` | Fix Agent status | NO | `""`, `"in_progress"`, `"completed"`, `"failed"`, `"needs_review"` |
| `FinalStatus` | Overall status | NO | `""`, `"PASS"`, `"FAIL"`, `"SKIPPED"` |
| `LastUpdated` | Timestamp | NO | `YYYY-MM-DD HH:MM:SS` |
| `Error` | Error message if failed | NO | String or empty |

### CSV Update Function

Replicate this exact logic when updating the CSV:

```
FUNCTION Update-RowStatus(Slug, StageColumn, Status, ErrorMessage=""):
    1. Read entire CSV into memory
    2. Find row where row.Slug == Slug
    3. Set row[StageColumn] = Status
    4. Set row.LastUpdated = current timestamp (YYYY-MM-DD HH:MM:SS)
    5. IF ErrorMessage is not empty:
           Set row.Error = ErrorMessage
    6. Write entire CSV back to file (overwrite)
```

### Update Sequence Per Report

Execute these updates in EXACT order:

```
PROCESSING REPORT: [slug]
========================================

STAGE 1 (PDF Extraction):
    BEFORE: Update-RowStatus(slug, "Stage1Status", "in_progress")
    ON SUCCESS: Update-RowStatus(slug, "Stage1Status", "completed")
    ON FAILURE: Update-RowStatus(slug, "Stage1Status", "failed", errorMessage)
                SKIP to next report

STAGE 2 (Content Enhancement):
    BEFORE: Update-RowStatus(slug, "Stage2Status", "in_progress")
    ON SUCCESS: Update-RowStatus(slug, "Stage2Status", "completed")
    ON FAILURE: Update-RowStatus(slug, "Stage2Status", "failed", errorMessage)
                SKIP to next report

STAGE 3 (HTML Generation):
    BEFORE: Update-RowStatus(slug, "Stage3Status", "in_progress")
    ON SUCCESS: Update-RowStatus(slug, "Stage3Status", "completed")
    ON FAILURE: Update-RowStatus(slug, "Stage3Status", "failed", errorMessage)
                SKIP to next report

STAGE 4 (QA Validation):
    BEFORE: Update-RowStatus(slug, "Stage4Status", "in_progress")
    PARSE QA report for "Status: PASS" or "Status: FAIL"
    ON PASS: Update-RowStatus(slug, "Stage4Status", "PASS")
    ON FAIL: Update-RowStatus(slug, "Stage4Status", "FAIL")
             CONTINUE to Stage 5

STAGE 5 (Fix - only if Stage 4 = FAIL):
    BEFORE: Update-RowStatus(slug, "Stage5Status", "in_progress")
    IF QA report mentions "Stage 3" or "HTML":
        Update-RowStatus(slug, "Stage3Status", "retry")
        Regenerate HTML
        IF regeneration succeeds:
            Update-RowStatus(slug, "Stage3Status", "completed")
            Update-RowStatus(slug, "Stage5Status", "completed")
            Re-run QA and update Stage4Status
        ELSE:
            Update-RowStatus(slug, "Stage5Status", "failed", "HTML regeneration failed")
    ELSE:
        Update-RowStatus(slug, "Stage5Status", "needs_review")

FINAL STATUS:
    IF Stage4Status == "PASS":
        Update-RowStatus(slug, "FinalStatus", "PASS")
    ELSE:
        Update-RowStatus(slug, "FinalStatus", "FAIL", "QA did not pass after fix attempt")
```

### Finding Reports to Process

```
PENDING REPORTS:
    WHERE FinalStatus == "" AND Stage1Status == ""

FAILED REPORTS (for retry):
    WHERE FinalStatus == "FAIL"

SKIP REPORTS:
    WHERE FinalStatus == "PASS"
    WHERE FinalStatus == "SKIPPED"

RESUME PARTIAL (start from incomplete stage):
    IF Stage1Status == "completed" AND Stage2Status == "":
        Start from Stage 2
    IF Stage2Status == "completed" AND Stage3Status == "":
        Start from Stage 3
    (etc.)
```

### PDF Path Derivation

Convert `PDF Report Link` URL to local filename:
```
URL: https://your-company.com/wp-content/uploads/2026/01/The-Meadows-V.pdf
Local: resale-report-pdfs/https_your-company.com_wp-content_uploads_2026_01_The-Meadows-V.pdf
```

Rule: Replace `https://` with `https_`, replace all `/` with `_`

---

## Required Files

### Input Files:
1. `resale-report-pdfs/*.pdf` - Source PDFs
2. `resale-report-pdfs/report-urls-with-pdf-links.csv` - URL mappings
3. `MPP-COMPONENTS-LIBRARY-v5-SEO.html` - Component library (single source)
4. `batch/processing-status.csv` - Progress tracking (read/write)

### Prompt Files:
1. `prompts/pdf-extraction-prompt.md` - Stage 1 extraction prompt
2. `prompts/component-selection-rules.md` - Stage 2a component selection (algorithmic)
3. `prompts/content-enhancement-prompt.md` - Stage 2b content generation
4. `prompts/html-generation-prompt.md` - Stage 3 generation prompt

### Reference Files:
1. `prompts/chart-component-reference.md` - Standardized chart component ID cross-reference
2. `mpp-real-estate-reports-skill-with-json/json-schema.md` - JSON schema
3. `mpp-real-estate-reports-skill-with-json/seo-accessibility.md` - SEO requirements
4. `mpp-real-estate-reports-skill-with-json/SKILL.md` - Skill instructions

### Output Files (per report):
1. `output/[name]-extracted.json`
2. `output/[name].json`
3. `output/[name].html`
4. `output/[name]-qa-report.md`

---

## Usage

When user says "Process [PDF_PATH]":

1. Parse PDF path, derive base name
2. **Stage 1**: Run PDF Extraction Agent + CSV Metadata Agent
3. Validate Stage 1 output exists
4. **Stage 2**: Run Content Enhancement Agent
5. Validate Stage 2 output exists
6. **Stage 3**: Run HTML Generator Agent
7. Validate Stage 3 outputs exist
8. **Stage 4**: Run QA Agent
9. Parse QA report for status (PASS/FAIL) and SEO Score
10. **If PASS**: Report completion with paths and scores
11. **If FAIL**: Execute fix loop (Stage 5 -> QA -> Retry -> Escalate)

---

*Version 1.7 - January 2026*
*Consolidated from prompts/orchestration-plan.md (v4.1) and mpp-resale-reports-orchestration-plan.md (v1.4)*
*v1.1: Component selection refactored to algorithmic framework with separated prompt files*
*v1.2: Added Progress Tracking section with CSV structure and update rules*
*v1.3: Added exact CSV update function, update sequence, PDF path derivation from batch-process.ps1*
*v1.4: Standardized component IDs in thresholds table per chart-component-reference.md*
*v1.5: Added thresholds for comparison-cards, comparison-table, indicators-block, kpi-strip*
*v1.6: Updated time-series thresholds: area-line >= 3 points, 2 periods -> grouped-column*
*v1.7: Removed archived chart-selection-rulebook.md references (thresholds now inline in prompts)*
