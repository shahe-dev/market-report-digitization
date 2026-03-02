# Brand Resale Reports - Multi-Agent Orchestration Plan

## Overview

This document defines a reusable multi-agent pipeline for converting PDF resale reports to structured JSON and HTML. Each agent operates with fresh context, passing data via JSON files. A final QA agent validates accuracy across all outputs.

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
|  STAGE 1 AGENT   |  PDF Extraction
|  (Task tool)     |
+------------------+
    Input:  PDF file + pdf-extraction-prompt.md
    Output: output/[name]-extracted.json
         |
         | Orchestrator validates JSON exists
         v
+------------------+
|  STAGE 2 AGENT   |  Content Enhancement
|  (Task tool)     |
+------------------+
    Input:  [name]-extracted.json + content-enhancement-prompt.md + json-schema.md
    Output: output/[name]-enhanced.json
         |
         | Orchestrator validates enhanced fields exist
         v
+------------------+
|  STAGE 3 AGENT   |  HTML Generation
|  (Task tool)     |
+------------------+
    Input:  [name]-enhanced.json + html-generation-prompt.md + component-library.html
    Output: output/[name].html
         |
         | Orchestrator confirms HTML created
         v
+------------------+
|  STAGE 4 AGENT   |  Quality Assurance
|  (Task tool)     |
+------------------+
    Input:  [name]-extracted.json + [name]-enhanced.json + [name].html
    Output: output/[name]-qa-report.md
         |
         | Orchestrator reviews QA results
         v
    +----+----+
    |         |
  PASS      FAIL
    |         |
    v         v
COMPLETE   FIX LOOP (see below)
               |
               v
        +------------------+
        |  STAGE 5 AGENT   |  Targeted Fix
        |  (Task tool)     |
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
      COMPLETE   FULL RETRY (fallback)
```

---

## QA Severity Classification

**FAIL (Blocking - Requires Retry)**

Any issue affecting data accuracy or numerical representation:

| Category | FAIL Conditions |
|----------|-----------------|
| Data Values | Any number in HTML differs from source JSON |
| Percentages | Any calculated percentage differs from source by >0.5% |
| Chart Labels | Any data point label shows wrong value |
| Chart Positions | Data point vertical position >2% off from calculated value |
| Y-Axis Scale | Non-uniform intervals that misrepresent data proportions |
| Missing Data | Any data point, row, or metric omitted from output |
| Wrong Calculation | Any derived statistic (trough-to-peak %, YoY change) incorrect |

**WARNING (Non-blocking - Log Only)**

Cosmetic or stylistic issues that don't affect accuracy:

| Category | WARNING Conditions |
|----------|-------------------|
| Formatting | Currency format variations (AED 1,000 vs AED 1000) |
| Styling | Minor CSS inconsistencies that don't hide data |
| Accessibility | Missing but non-critical ARIA labels |
| SEO | Meta description slightly over character limit |

**Rule: When in doubt, classify as FAIL.**

---

## Fix Loop (On QA FAIL)

The fix loop uses a targeted Fix Agent first, falling back to full stage retry only if surgical fixes fail.

```
QA FAIL detected
         |
         v
+------------------+
|  STAGE 5: FIX    |  Targeted surgical fixes
+------------------+
    Input: QA report + affected files (JSON/HTML)
    Action: Edit specific values/calculations
    Output: Patched files in place
         |
         v
+------------------+
|  RE-RUN QA       |  Validate fixes
+------------------+
         |
    +----+----+
    |         |
  PASS      FAIL
    |         |
    v         v
COMPLETE   FULL RETRY (fallback)
               |
               v
        +------------------+
        | IDENTIFY SOURCE  |  Which stage needs full regeneration?
        +------------------+
               |
          +----+----+----+
          |         |    |
       Stage 1   Stage 2  Stage 3
          |         |    |
          v         v    v
        +------------------+
        |  RE-RUN STAGE    |  Full regeneration with feedback
        +------------------+
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
          v         +---> ESCALATE to user
      COMPLETE
```

### Fix Agent Capabilities

The Fix Agent can handle these issue types with surgical edits:

| Issue Type | Fix Action | Target File |
|------------|------------|-------------|
| Y-axis non-uniform intervals | Calculate uniform steps, edit labels | HTML |
| Wrong percentage in summary | Recalculate from source, edit text | **JSON + HTML** |
| Wrong percentage in chartSummaries | Recalculate, edit JSON field | **JSON** |
| Data point position error | Recalculate %, edit CSS top value | HTML |
| SVG path mismatch | Recalculate coordinates, edit path d= | HTML |
| Value mismatch (JSON to HTML) | Copy correct value from JSON | HTML |
| Missing data point label | Add label from source data | HTML |
| JSON-HTML narrative mismatch | Sync HTML to match corrected JSON | **JSON + HTML** |
| Container centering missing | Add `margin: 0 auto` to CSS rules | HTML |

**CRITICAL: The Fix Agent MUST fix BOTH the enhanced JSON AND HTML when a calculated value is wrong. JSON is the source of truth.**

### Fix Agent Limitations (Triggers Full Retry)

| Issue Type | Why Fix Agent Cannot Handle | Fallback |
|------------|----------------------------|----------|
| Source data extraction error | Correct value unknown | Re-run Stage 1 |
| Missing enhanced fields | Requires content generation | Re-run Stage 2 |
| Wrong component selected | Requires full HTML restructure | Re-run Stage 3 |
| Missing entire section | Requires full regeneration | Re-run Stage 2 or 3 |

### Failure Attribution Rules

| QA Failure Type | Fixable? | If Not Fixable, Retry Stage |
|-----------------|----------|----------------------------|
| Numbers in HTML differ from enhanced JSON | YES | - |
| Chart position calculations wrong | YES | - |
| Y-axis non-uniform intervals | YES | - |
| Wrong percentage in narrative | YES | - |
| SVG path coordinates wrong | YES | - |
| Numbers in enhanced JSON differ from extracted | NO | Stage 2 |
| Missing enhanced fields | NO | Stage 2 |
| Wrong component used | NO | Stage 3 |
| Missing entire section | NO | Stage 2 or 3 |
| Data extraction missed values | NO | Stage 1 |

---

## File Naming Convention

From PDF path: `resale-report-pdfs/https_your-company.com_wp-content_uploads_2024_08_RR-Business-Bay-H1-2024.pdf`

Extract: `business-bay-h1-2024`

Output files:
- `output/business-bay-h1-2024-extracted.json` (Stage 1)
- `output/business-bay-h1-2024-enhanced.json` (Stage 2)
- `output/business-bay-h1-2024.html` (Stage 3)
- `output/business-bay-h1-2024-qa-report.md` (Stage 4)
- `output/business-bay-h1-2024.json` (Final - copy of enhanced)

---

## Agent Prompts

### Stage 1: PDF Extraction Agent

```
You are a PDF data extraction specialist. Your task is to extract structured data from a real estate PDF report.

**Instructions:**
1. Read the PDF at: [PDF_PATH]
2. Read the extraction schema at: prompts/pdf-extraction-prompt.md
3. Extract ALL data following the schema exactly
4. Write the JSON output to: output/[NAME]-extracted.json

**Critical Requirements:**
- Extract ALL numerical data with exact values
- Capture ALL graph data points
- Include ALL table rows
- Preserve original formatting for currency (AED)
- Do NOT enhance or modify data - extract only

**Output:** Write JSON to the specified path. Confirm completion with the filename.
```

### Stage 2: Content Enhancement Agent

```
You are a content enhancement specialist for real estate market reports. Your task is to enhance extracted data with SEO content, narrative summaries, and component selections.

**Instructions:**
1. Read the extracted JSON at: output/[NAME]-extracted.json
2. Read the enhancement guidelines at: prompts/content-enhancement-prompt.md
3. Read the full schema at: mpp-real-estate-reports-skill-with-json/json-schema.md
4. Enhance the JSON with:
   - SEO metadata (title, description, h1)
   - Executive summary
   - Chart summaries using appropriate narrative styles
   - Component selections with rationale
   - Section ordering based on data emphasis
   - Conditional section flags
   - Investor considerations
5. Write enhanced JSON to: output/[NAME]-enhanced.json

**Critical Requirements:**
- Preserve ALL original extracted data
- Add enhanced.* fields per schema
- Select components based on data patterns
- Choose narrative styles based on trend shapes
- All numbers must match source data exactly

**Output:** Write enhanced JSON to the specified path. Confirm completion with the filename.
```

### Stage 3: HTML Generation Agent

```
You are an HTML generation specialist for real estate market reports. Your task is to generate a complete, self-contained HTML file from enhanced JSON data.

**Instructions:**
1. Read the enhanced JSON at: output/[NAME]-enhanced.json
2. Read the HTML templates at: prompts/html-generation-prompt.md
3. Read the CSS from: mpp-real-estate-reports-skill-with-json/component-library.html (lines 1-1100 for CSS)
4. Generate complete HTML following:
   - Section order from enhanced.sectionOrder
   - Components from enhanced.componentSelections
   - Narrative styles from enhanced.narrativeStyle
   - Include/exclude sections per enhanced.conditionalSections
5. Write HTML to: output/[NAME].html

**Critical Requirements:**
- Embed ALL CSS inline (self-contained file)
- Include Schema.org JSON-LD
- All ARIA labels for accessibility
- SVG charts with vector-effect="non-scaling-stroke" for dashed lines
- Data tables for each chart (toggleable)
- All values must match source JSON exactly

**Output:** Write HTML to the specified path. Confirm completion with the filename.
```

### Stage 4: Quality Assurance Agent

```
You are a QA specialist for real estate market reports. Your task is to validate accuracy, consistency, and quality across all pipeline outputs.

**CRITICAL: Data accuracy issues are FAIL, not warnings. Any numerical discrepancy blocks the pipeline.**

**Instructions:**
1. Read the extracted JSON at: output/[NAME]-extracted.json
2. Read the enhanced JSON at: output/[NAME]-enhanced.json
3. Read the HTML file at: output/[NAME].html
4. Perform all validation checks listed below
5. Write QA report to: output/[NAME]-qa-report.md

**FAIL Criteria (Any of these = FAIL status):**
- Any number in HTML differs from source JSON
- Any percentage calculation off by >0.5%
- Any chart data point label shows wrong value
- Any data point vertical position >2% off from calculated value
- Y-axis uses non-uniform intervals that misrepresent proportions
- Any data point, row, or metric missing from output
- Any derived statistic (trough-to-peak %, YoY) incorrect
- **Any derived statistic in enhanced JSON differs from calculated value**
- **Enhanced JSON chartSummaries contain incorrect percentages**
- **Mismatch between enhanced JSON narrative and HTML narrative**
- **Container elements with max-width missing horizontal centering (margin: 0 auto)**

**WARNING Criteria (Non-blocking):**
- Currency format variations (AED 1,000 vs AED 1000)
- Minor CSS inconsistencies
- Non-critical missing ARIA labels
- SEO meta slightly over character limit

**Validation Checklist:**

## 1. Data Integrity (Extracted -> Enhanced) [FAIL if any mismatch]
- [ ] All keyPerformance values preserved exactly
- [ ] All priceInsights rows preserved exactly
- [ ] All graph data points preserved exactly
- [ ] All rentalMetrics values preserved (if present)
- [ ] All topSearched items preserved
- [ ] No numbers modified or rounded differently

## 2. Data Integrity (Enhanced -> HTML) [FAIL if any mismatch]
- [ ] KPI card values match keyPerformance
- [ ] Table cell values match priceInsights
- [ ] Chart data point labels match graph values
- [ ] Executive summary numbers match source data
- [ ] YoY percentages match source data

## 3. Chart Calculations [FAIL if any error]
- [ ] Y-axis uses UNIFORM intervals (equal step size)
- [ ] Y-axis range appropriate for data (min/max with padding)
- [ ] Data point vertical positions calculated correctly (tolerance: 2%)
- [ ] Data point horizontal positions evenly distributed
- [ ] SVG path coordinates match data point positions
- [ ] All calculated percentages in summaries are mathematically correct

## 4. Component Consistency
- [ ] Sections appear in order specified by sectionOrder
- [ ] Components used match componentSelections
- [ ] Conditional sections included/excluded correctly

## 5. Enhanced JSON Validation [FAIL if any mismatch]
- [ ] All chartSummaries percentages are mathematically correct
- [ ] executiveSummaryEnhanced numbers match keyPerformance values
- [ ] No hallucinated statistics in enhanced.* fields
- [ ] chartSummaries.trendOverTime percentage matches calculated trough-to-peak
- [ ] chartSummaries.transactions percentage matches calculated month-over-month
- [ ] Enhanced JSON narratives match corresponding HTML text

## 6. Content Quality [FAIL if statistics wrong]
- [ ] Executive summary mentions key metrics accurately
- [ ] Chart summaries reference actual data trends
- [ ] No hallucinated statistics or percentages
- [ ] Investor considerations are data-grounded
- [ ] All percentages verified against source calculations

## 7. Technical Quality
- [ ] HTML is well-formed (no unclosed tags)
- [ ] All CSS classes referenced exist in embedded styles
- [ ] SVG charts include vector-effect="non-scaling-stroke"
- [ ] Schema.org JSON-LD is valid

## 8. Layout & CSS Quality [FAIL if centering missing]
- [ ] All container elements with max-width have horizontal centering (margin: 0 auto)
- [ ] Verify these classes have margin with auto left/right:
  - .report-header
  - .executive-summary-card
  - .key-performance
  - .chart-card
  - .chart-summary
  - .data-source
  - .indicators-block
  - .price-data-insights
  - .horizontal-chart
  - .market-insight
  - .market-dynamics
  - .investor-considerations
  - .source-citation
  - .chart-data-toggle
- [ ] Content blocks should be centered on the page, not left-aligned against viewport edge

**Report Format:**

# QA Report: [Community] [Period]

## Summary
- Status: PASS / FAIL
- Blocking Issues: [count] (data accuracy failures)
- Warnings: [count] (cosmetic only)

## Data Integrity
[Results of checks 1-2]

## Enhanced JSON Validation
[Results of check 5]
**chartSummaries Percentage Verification:**
| Field | Stated Value | Calculated Value | Status |
[Verify each percentage in chartSummaries]

## Chart Accuracy
[Results of check 3]
**Y-Axis Verification:**
- Expected intervals: [list uniform steps]
- Actual intervals: [list what's in HTML]
- Status: PASS / FAIL

**Position Calculations:**
[For each data point: expected %, actual %, variance]

## Component Validation
[Results of check 4]

## Content Quality
[Results of check 5]
**Percentage Verification:**
[List each percentage claim, show calculation, verify accuracy]

## Technical Quality
[Results of check 6]

## Issues Requiring Fix (BLOCKING)
[List each FAIL item with:]
- Issue description
- Expected value
- Actual value
- Responsible stage (1, 2, or 3)

## Warnings (Non-blocking)
[List cosmetic issues only]

## Failure Attribution
If status is FAIL, include:
| Issue | Responsible Stage | Recommended Action |
|-------|-------------------|-------------------|
[Map each failure to stage]

**Output:** Write QA report to the specified path. Confirm completion with status (PASS/FAIL) and failure count.
```

### Stage 5: Fix Agent (Triggered on QA FAIL)

```
You are a precision fix specialist for real estate market reports. Your task is to make targeted surgical edits to fix specific issues identified in the QA report.

**CRITICAL: You are making EDITS to existing files, not regenerating them. Preserve all working content.**

**Instructions:**
1. Read the QA report at: output/[NAME]-qa-report.md
2. Read the "Issues Requiring Fix (BLOCKING)" section
3. For each fixable issue:
   a. Identify the file to edit (HTML or JSON)
   b. Locate the exact line/value that needs correction
   c. Calculate the correct value from source data
   d. Make the surgical edit using the Edit tool
4. Report which fixes were applied

**Fixable Issue Types:**

## Y-Axis Non-Uniform Intervals
1. Read current Y-axis labels from HTML
2. Determine data range (min and max values)
3. Calculate uniform step size: step = (max - min + padding) / (num_labels - 1)
4. Edit each Y-axis label to use uniform intervals
5. Recalculate all data point vertical positions based on new scale
6. Edit each data-point top % value
7. Edit SVG path coordinates to match

## Wrong Percentage in Narrative
1. Find the incorrect percentage in HTML/JSON
2. Get source values from extracted JSON
3. Calculate correct percentage: ((new - old) / old) * 100
4. Edit the specific text to show correct percentage

## Data Point Position Error
1. Read Y-axis range from HTML (top label = 0%, bottom label = 100%)
2. For each data point value, calculate: position% = ((max - value) / range) * 100
3. Edit the CSS top: X% value for each incorrect point
4. Edit SVG path d= coordinates to match

## Value Mismatch (JSON to HTML)
1. Read correct value from enhanced JSON
2. Find incorrect value in HTML
3. Edit HTML to show correct value

## Container Centering Missing
1. Identify CSS classes with `max-width` but no horizontal centering
2. For each class, add `margin: 0 auto [existing-bottom-margin]` or change `margin-bottom: X` to `margin: 0 auto X`
3. Key classes to check:
   - `.report-header` -> `margin: 0 auto var(--space-4xl);`
   - `.executive-summary-card` -> `margin: 0 auto var(--space-4xl);`
   - `.key-performance` -> `margin: 0 auto var(--space-4xl);`
   - `.chart-card` -> `margin: 0 auto 60px;`
   - `.chart-summary` -> `margin: 0 auto var(--space-2xl);`
   - `.data-source` -> `margin: var(--space-2xl) auto 0;`
   - `.indicators-block` -> `margin: 0 auto var(--space-4xl);`
   - `.price-data-insights` -> `margin: 0 auto var(--space-4xl);`
   - `.horizontal-chart` -> `margin: 0 auto var(--space-4xl);`
   - `.market-insight` -> `margin: 0 auto var(--space-4xl);`
   - `.market-dynamics` -> `margin: 0 auto var(--space-4xl);`
   - `.investor-considerations` -> `margin: 0 auto var(--space-4xl);`
   - `.source-citation` -> `margin: 0 auto var(--space-4xl);`

**What You CANNOT Fix (Report as "Requires Full Retry"):**
- Missing data in source extraction (Stage 1 issue)
- Missing enhanced fields like executiveSummary (Stage 2 issue)
- Wrong component type used (Stage 3 structural issue)
- Missing entire HTML section (Stage 3 structural issue)

**Output Format:**

## Fixes Applied
| Issue | File | Old Value | New Value | Line |
|-------|------|-----------|-----------|------|
[List each fix]

## Issues Requiring Full Retry
[List any issues that could not be surgically fixed]

## Status
- Fixes Applied: [count]
- Unfixable Issues: [count]
- Recommendation: RE-RUN QA / FULL RETRY NEEDED

**Output:** Report fixes applied. If all issues were fixed, recommend "RE-RUN QA". If unfixable issues remain, recommend "FULL RETRY NEEDED" with responsible stage.
```

---

## Orchestrator Checklist

Before each stage:
- [ ] Verify input file(s) exist
- [ ] Verify prompt files exist

After Stage 1:
- [ ] Verify extracted JSON exists
- [ ] Verify JSON is valid (parseable)

After Stage 2:
- [ ] Verify enhanced JSON exists
- [ ] Verify enhanced.* fields present

After Stage 3:
- [ ] Verify HTML file exists
- [ ] Verify file size > 10KB (sanity check)

After Stage 4:
- [ ] Read QA report status
- [ ] If FAIL: Execute fix loop (Stage 5 first, then fallback to retry)
- [ ] If PASS: Proceed to completion

After Stage 5 (if triggered):
- [ ] Parse Fix Agent recommendation
- [ ] If "RE-RUN QA": Re-run Stage 4
- [ ] If "FULL RETRY NEEDED": Identify stage and retry
- [ ] After retry, re-run Stage 4

After all stages:
- [ ] Copy enhanced JSON to final filename
- [ ] Report completion with output paths and QA status

---

## Usage

When user says "Process [PDF_PATH]":

1. Parse PDF path, derive base name
2. Run Stage 1 Agent (Task tool) - PDF Extraction
3. Validate Stage 1 output exists
4. Run Stage 2 Agent (Task tool) - Content Enhancement
5. Validate Stage 2 output exists
6. Run Stage 3 Agent (Task tool) - HTML Generation
7. Validate HTML output exists
8. Run Stage 4 Agent (Task tool) - Quality Assurance
9. Parse QA report for status and failure attribution
10. **If PASS:** Copy enhanced JSON to final location, report completion
11. **If FAIL:** Execute fix loop:

### Fix Loop Execution

```
IF status == FAIL:

    # STEP 1: Try targeted fixes first
    1. Run Stage 5 Agent (Task tool) - Fix Agent
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
        9. Re-run downstream dependencies (see table)
        10. Re-run Stage 4 (QA)
        11. IF PASS: Complete
        12. IF FAIL: ESCALATE to user

ESCALATE:
    Report to user: "Pipeline failed after fix attempt and full retry"
    Show remaining issues
    Ask user: "Manual fix or abort?"
```

### Downstream Dependencies

When retrying a stage, downstream stages must also be re-run:

| Retried Stage | Also Re-run |
|---------------|-------------|
| Stage 1 | Stage 2, Stage 3 |
| Stage 2 | Stage 3 |
| Stage 3 | (none) |

Always re-run Stage 4 (QA) after any fix or retry.

---

## Error Handling

### Stage Failure (Agent Fails to Produce Output)
If any stage fails to produce output:
1. Report which stage failed
2. Show error message
3. Preserve partial outputs for debugging
4. Retry failed stage once before escalating to user

### QA Failure (Automatic Fix Loop)
QA failures are handled automatically by the fix loop. The orchestrator:
1. First runs Stage 5 (Fix Agent) for surgical fixes
2. Re-runs QA to validate fixes
3. If fixes insufficient, falls back to full stage retry
4. Escalates to user only after both fix and retry fail

### Common Issues and Resolution Path

| Issue | Fix Agent Can Handle? | Resolution |
|-------|----------------------|------------|
| Numbers in HTML differ from JSON | YES | Stage 5 edits HTML values |
| Chart positions wrong | YES | Stage 5 recalculates and edits |
| Y-axis non-uniform intervals | YES | Stage 5 recalculates scale |
| Wrong percentage in text | YES | Stage 5 recalculates and edits |
| SVG path coordinates wrong | YES | Stage 5 recalculates and edits |
| Container centering missing | YES | Stage 5 adds margin: 0 auto to CSS |
| Numbers in enhanced JSON differ from extracted | NO | Full retry Stage 2 |
| Missing enhanced fields | NO | Full retry Stage 2 |
| Missing sections | NO | Full retry Stage 2 or 3 |
| Wrong component used | NO | Full retry Stage 3 |
| CSS not applied | NO | Full retry Stage 3 |

### Escalation to User
After fix attempt AND full retry both fail, the orchestrator:
1. Reports all remaining issues
2. Shows what was attempted (fixes + retry)
3. Asks user: "Manual fix required. Options: (A) Retry specific stage manually, (B) Edit output files directly, (C) Abort pipeline"

---

## Batch Processing

To process multiple PDFs:

```
For each PDF in [PDF_LIST]:
    1. Run full pipeline (Stages 1-4)
    2. If QA PASS: Add to success list
    3. If QA FAIL: Add to review list
    4. Continue to next PDF

Report:
    - Successfully processed: [count]
    - Requiring review: [count] with issues
```

---

*Version 4.1 - January 2026*
*v2.0: Stage 4 QA Agent, batch processing guidance, error handling matrix*
*v3.0: Strict FAIL criteria for data accuracy, automatic retry loop, failure attribution*
*v4.0: Stage 5 Fix Agent for surgical edits, fix-first approach before full retry*
*v4.1: Enhanced JSON validation as source of truth, JSON-HTML consistency checks*
