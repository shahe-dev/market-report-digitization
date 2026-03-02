# MPP Resale Reports: Multi-Agent Orchestration Plan

## Executive Summary

This document outlines a comprehensive multi-agent system for converting 240 PDF real estate resale reports into SEO-optimized HTML reports with companion JSON data files. The system is designed to establish the company as an authoritative source in the UAE real estate market through professional, citable, and visually appealing content.

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ORCHESTRATION LAYER                                  │
│                      (Master Coordinator Agent)                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│   INGESTION   │    ──►   │  PROCESSING   │    ──►   │    OUTPUT     │
│    LAYER      │          │    LAYER      │          │    LAYER      │
└───────────────┘          └───────────────┘          └───────────────┘
        │                           │                           │
   ┌────┴────┐              ┌───────┴───────┐           ┌───────┴───────┐
   ▼         ▼              ▼       ▼       ▼           ▼       ▼       ▼
┌─────┐  ┌─────┐       ┌─────┐ ┌─────┐ ┌─────┐    ┌─────┐ ┌─────┐ ┌─────┐
│ PDF │  │ CSV │       │Data │ │HTML │ │JSON │    │ QC  │ │Final│ │Pub- │
│Parse│  │Parse│       │Anal.│ │Gen. │ │Gen. │    │Agent│ │Assem│ │lish │
└─────┘  └─────┘       └─────┘ └─────┘ └─────┘    └─────┘ └─────┘ └─────┘
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                   ┌───────────┐       ┌───────────┐
                   │  Insight  │       │ Component │
                   │  Writer   │       │ Selector  │
                   └───────────┘       └───────────┘
```

---

## 2. Agent Definitions

### 2.1 Master Coordinator Agent (Orchestrator)

**Role**: Central orchestration and workflow management

**Responsibilities**:
- Manage the processing queue of 240 reports
- Track processing status (pending, in-progress, completed, failed)
- Handle retry logic for failed conversions
- Aggregate metrics and generate batch reports
- Enforce rate limiting and resource management
- Coordinate inter-agent communication

**State Management**:
```json
{
  "batch_id": "batch_2025_01_19",
  "total_reports": 240,
  "status": {
    "pending": [],
    "in_progress": [],
    "completed": [],
    "failed": [],
    "needs_review": []
  },
  "metrics": {
    "start_time": "ISO_TIMESTAMP",
    "avg_processing_time_sec": 0,
    "success_rate": 0.0
  }
}
```

---

### 2.2 PDF Parser Agent

**Role**: Extract structured data from PDF reports

**Responsibilities**:
- Parse PDF content using pdfplumber/PyMuPDF
- Extract tables, charts, and text sections
- Identify report structure (sections, headers, data points)
- Handle multi-page documents
- Extract embedded images if present
- Output structured intermediate format

**Input**: PDF file path
**Output**: Structured JSON (ParsedReportData)

**Extraction Targets**:
| Data Type | Extraction Method | Validation |
|-----------|-------------------|------------|
| Title/Community | Text extraction from header | Non-empty string |
| Time Period | Pattern matching (H1/H2/Q1-Q4 + Year) | Valid date range |
| KPI Metrics | Table extraction + numeric parsing | Numeric values |
| Transaction Data | Table extraction | Positive integers |
| Price Data | Table extraction | Currency format |
| Charts | Image extraction + OCR if needed | Data presence |
| Insights/Text | Paragraph extraction | Min word count |

**Error Handling**:
- Corrupted PDF → Log error, skip to manual review queue
- Missing sections → Flag with partial data, continue
- Encoding issues → Attempt multiple encodings, fallback to OCR

---

### 2.3 CSV Metadata Agent

**Role**: Enrich parsed data with URL mappings

**Responsibilities**:
- Load and parse the CSV file mapping PDFs to webpage URLs
- Match each PDF to its corresponding webpage
- Provide canonical URL for JSON-LD structured data
- Validate URL accessibility (optional)

**Input**: CSV file path, PDF filename
**Output**: URL metadata object

---

### 2.4 Data Analyst Agent

**Role**: Transform raw data into analytical insights

**Responsibilities**:
- Calculate derived metrics (YoY changes, growth rates)
- Identify trends and patterns
- Generate statistical summaries
- Rank and compare data points
- Detect anomalies or outliers
- Prepare data for visualization

**Calculations**:
```python
# Year-over-Year Change
yoy_change = ((current - previous) / previous) * 100

# Price per Square Foot
price_psf = transaction_value / area_sqft

# Market Share
market_share = (category_transactions / total_transactions) * 100

# Growth Rate (CAGR for multi-period)
cagr = ((end_value / start_value) ** (1/periods) - 1) * 100
```

**Output**: EnrichedDataPacket with derived metrics

---

### 2.5 Component Selector Agent

**Role**: Map data types to appropriate visualization components

**Responsibilities**:
- Analyze data characteristics (cardinality, type, relationships)
- Select optimal component from library based on SKILL.md guidelines
- Determine component configuration (colors, sizing, layout)
- Ensure variety and visual balance in report

**Selection Matrix**:
| Data Characteristic | Recommended Component |
|---------------------|----------------------|
| Single trend over time | Single Line Chart with Area Fill |
| Multiple trends comparison | Multi-line Comparison Chart |
| Period-over-period comparison | Vertical Multi-bar Chart |
| Category distribution | Vertical Single-bar Chart |
| Composition/proportions | Vertical Stacked Bar Chart |
| Top N ranking | Horizontal Bar Chart |
| Primary metrics (4 values) | KPI Strip (4-column) |
| Detailed price breakdown | Price Data Insights Table |
| Feature comparison | Key Differences Table |
| Key insight callout | Market Insight Block |
| Opening summary | Executive Summary Card |

**Output**: ComponentSelectionPlan

---

### 2.6 Content Enhancement + Component Selection Agent (Stage 3)

**Role**: Transform extracted data into SEO-optimized content AND select visualization components

**Responsibilities**:
- **Select visualization components** using the Component Selection Matrix
- **Write component-aware summaries** that describe selected visualizations
- Generate enhanced executive summaries (2-3 sentences, lead with key metric)
- Write insight-rich chart summaries referencing the visual elements
- Create 3-paragraph market dynamics analysis
- Produce market insights callout text
- Generate investor considerations (5 structured factors)
- Create SEO meta content (title, description, H1 variations)
- Output componentSelections field with visualization assignments

**Prompt Reference**: `prompts/content-enhancement-prompt.md`

**Input**: Extracted JSON from Stage 2 (PDF Parser)
**Output**: Enhanced JSON with:
- `enhanced` object containing all content fields
- `componentSelections` object with visualization assignments

**Writing Standards**:
- Use specific numbers with AED formatting (AED 2,053, not "around 2000")
- Include YoY comparisons ("up 9.4% from H1 2024")
- Add market context ("outpacing Dubai average by 2.3%")
- **Reference visualization types in summaries** ("The line traces...", "The bars reveal...")
- NO promotional language or CTAs
- NO vague descriptors without supporting data
- Authoritative, professional tone

**Quality Checklist**:
- [ ] Executive summary leads with most impactful metric
- [ ] All chart summaries explain trends AND reference their visualization
- [ ] Market dynamics includes specific comparisons
- [ ] Primary keyword appears in executive summary
- [ ] No sales language present
- [ ] componentSelections matches data types present
- [ ] Summaries coherent with selected visualization types

**Example Outputs**:
```
Enhanced Executive Summary:
"Business Bay apartments recorded 3,745 resale transactions in H1 2025,
with average prices reaching AED 2,053 per square foot - a 9.4% increase
year-over-year. The market's gross rental yield of 6.74% positions it
among Dubai's strongest income-generating apartment communities."

Enhanced Chart Summary:
"Price per square foot demonstrated steady appreciation throughout H1 2025,
rising from AED 1,980 in January to AED 2,053 in June - a 3.7% gain over
six months. This trajectory suggests sustained buyer confidence despite
broader market uncertainty in Q2."

Enhanced Market Insight:
"Business Bay's dual identity as both a business hub and residential
community creates a diversified tenant base spanning corporate professionals
and long-term residents. This demand diversity provides rental income
stability that pure residential or pure commercial areas cannot match."
```

---

### 2.7 HTML Generator Agent

**Role**: Assemble complete HTML report from components with full SEO/accessibility compliance

**Reference**: `mpp-real-estate-reports-skill-with-json/seo-accessibility.md` for complete requirements

**Responsibilities**:
- Build HTML document structure from template
- Integrate CSS from component-library.html (lines 10-1699)
- Populate selected components with actual data
- Calculate chart dimensions and positions
- Generate SVG paths for line charts
- Insert Schema.org JSON-LD structured data
- Implement all SEO/accessibility requirements
- Add hidden data tables for each visualization
- Validate HTML output

**HTML Assembly Process**:
1. Initialize document with DOCTYPE, meta tags, fonts
2. Insert Schema.org Dataset JSON-LD in `<head>` from `schemaOrg` object
3. Copy production CSS (exclude demo styles)
4. Add `.sr-only.chart-data-table` CSS (see seo-accessibility.md Section 1)
5. Build content sections in order:
   - Executive Summary
   - KPI Strip
   - Price/Transaction Charts (with hidden data tables)
   - Data Tables
   - Market Dynamics (if applicable)
   - Investor Considerations
   - Source Citation
6. Ensure all ARIA attributes are present
7. Generate companion data tables for each chart

**SEO/Accessibility Requirements (Mandatory)**:

| Requirement | Implementation | Reference |
|-------------|----------------|-----------|
| Schema.org JSON-LD | `<script type="application/ld+json">` in `<head>` with schemaOrg object | seo-accessibility.md Section 2 |
| Section ARIA | `<section aria-labelledby="[id]">` with `<h2 id="[id]">` | seo-accessibility.md Section 3 |
| Chart ARIA | `role="img"` and `aria-describedby="[figcaption-id]"` on chart containers | seo-accessibility.md Section 3 |
| Hidden data tables | `<table class="sr-only chart-data-table">` after each chart | seo-accessibility.md Section 1 |
| Data source citation | `<p class="data-source">Source: [dataSource]</p>` after each visualization | seo-accessibility.md Section 3 |
| Chart summaries | `<p class="chart-summary">` prose summary before each chart | seo-accessibility.md Section 5 |
| KPI crawlability | Values in visible HTML text (not data attributes) | seo-accessibility.md Section 4 |

**Required CSS (must be included)**:
```css
.sr-only.chart-data-table {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

**HTML Structure Template for Chart Sections**:
```html
<section aria-labelledby="[unique-id]">
  <h2 id="[unique-id]">[Chart Title]</h2>
  <p class="chart-summary">[Enhanced chart summary from chartSummaries]</p>
  <figure>
    <div class="chart-container" role="img" aria-describedby="[desc-id]">
      <!-- Visual chart renders here -->
    </div>
    <figcaption id="[desc-id]">[Chart type] showing [data] from [period].</figcaption>
    <table class="sr-only chart-data-table">
      <caption>[dataTable.caption]</caption>
      <thead>
        <tr>
          <th scope="col">[header 1]</th>
          <th scope="col">[header 2]</th>
        </tr>
      </thead>
      <tbody>
        <!-- rows from dataTable.rows -->
      </tbody>
    </table>
  </figure>
  <p class="data-source">Source: [metadata.dataSource]</p>
</section>
```

**Output**: Complete HTML file (self-contained, no external dependencies except Google Fonts)

---

### 2.8 JSON Generator Agent

**Role**: Create structured JSON representation of report data

**Responsibilities**:
- Transform all report data to JSON schema format
- Include all metrics, calculations, and derived values
- Maintain data lineage/provenance
- Enable programmatic access to report data
- Support API integration and data syndication

**JSON Schema Structure** (to be defined in json-schema.md):
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "MPP Resale Report",
  "type": "object",
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "report_id": { "type": "string" },
        "community": { "type": "string" },
        "property_type": { "type": "string" },
        "time_period": { "type": "string" },
        "publication_date": { "type": "string", "format": "date" },
        "source_pdf": { "type": "string" },
        "canonical_url": { "type": "string", "format": "uri" }
      }
    },
    "kpis": {
      "type": "object",
      "properties": {
        "avg_price_psf": { "type": "number" },
        "yoy_change_percent": { "type": "number" },
        "total_transactions": { "type": "integer" },
        "total_value_aed": { "type": "number" }
      }
    },
    "price_trends": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "period": { "type": "string" },
          "avg_price_psf": { "type": "number" },
          "transactions": { "type": "integer" },
          "total_value_aed": { "type": "number" }
        }
      }
    },
    "bedroom_breakdown": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "bedrooms": { "type": "string" },
          "avg_price": { "type": "number" },
          "transactions": { "type": "integer" },
          "yoy_change_percent": { "type": "number" }
        }
      }
    },
    "market_composition": {
      "type": "object",
      "properties": {
        "offplan_percent": { "type": "number" },
        "ready_percent": { "type": "number" },
        "mortgage_percent": { "type": "number" },
        "cash_percent": { "type": "number" }
      }
    },
    "insights": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": { "type": "string" },
          "title": { "type": "string" },
          "content": { "type": "string" }
        }
      }
    }
  }
}
```

---

### 2.9 Quality Control Agent

**Role**: Validate outputs against requirements

**Reference**: `mpp-real-estate-reports-skill-with-json/seo-accessibility.md` for SEO checklist

**Responsibilities**:
- Validate HTML structure and syntax
- Verify SEO requirements compliance
- Check accessibility (ARIA, semantic HTML)
- Validate JSON against schema
- Cross-check data accuracy (HTML vs JSON vs source)
- Score report quality
- Flag issues for human review

**Validation Checklist**:

#### HTML Validation
- [ ] Valid HTML5 document structure
- [ ] All required meta tags present
- [ ] CSS included inline (no external stylesheets except fonts)
- [ ] All images have alt text
- [ ] No broken internal references
- [ ] Responsive breakpoints functional

#### SEO Validation (Reference: seo-accessibility.md)
- [ ] Schema.org Dataset JSON-LD present in `<head>`
- [ ] Schema.org `name` matches "[Community] [PropertyType] Resale Market Report [Period]"
- [ ] Schema.org `temporalCoverage` is valid ISO date range
- [ ] Schema.org `description` is 1-2 sentences (max 200 chars)
- [ ] All charts have hidden `<table class="sr-only chart-data-table">`
- [ ] Hidden tables have `<caption>`, `<thead>`, `<tbody>` with proper `<th scope="col">`
- [ ] `.sr-only.chart-data-table` CSS included in `<style>` block
- [ ] All `<section>` elements have `aria-labelledby` pointing to heading
- [ ] Chart containers have `role="img"` and `aria-describedby`
- [ ] `<p class="chart-summary">` present before each visualization
- [ ] `<p class="data-source">` present after each visualization
- [ ] KPI values in visible HTML text (not data-* attributes)
- [ ] All IDs are unique within document

#### Data Accuracy
- [ ] All metrics match source PDF
- [ ] Calculations verified (YoY%, sums, averages)
- [ ] No placeholder text remaining
- [ ] Date/time period correct
- [ ] Community name matches source
- [ ] dataTable.rows match graph points array

#### JSON Validation
- [ ] Valid JSON syntax
- [ ] Conforms to schema (json-schema.md)
- [ ] `schemaOrg` object present with all required fields
- [ ] `enhanced` object present with all required fields
- [ ] All graph objects have `dataTable` with caption, headers, rows
- [ ] Data matches HTML output
- [ ] Proper encoding (UTF-8)

**Quality Score Calculation**:
```
Quality Score = (
  Data_Accuracy * 0.40 +
  SEO_Compliance * 0.20 +
  HTML_Validity * 0.15 +
  Accessibility * 0.15 +
  JSON_Validity * 0.10
) * 100
```

**Thresholds**:
- Score ≥ 90: Auto-approve
- Score 70-89: Flag for review
- Score < 70: Reject, return to processing

---

### 2.10 Final Assembly Agent

**Role**: Package outputs for delivery

**Responsibilities**:
- Create output directory structure
- Name files consistently
- Generate manifest/index
- Create deployment package
- Archive source PDFs with outputs

**Output Directory Structure**:
```
output/
├── reports/
│   ├── the-meadows-villas-h1-2025/
│   │   ├── report.html
│   │   ├── report.json
│   │   └── metadata.json
│   ├── dubai-marina-apartments-h1-2025/
│   │   ├── report.html
│   │   ├── report.json
│   │   └── metadata.json
│   └── ... (240 communities)
├── manifest.json
├── processing-log.json
└── quality-report.csv
```

**File Naming Convention**:
```
{community-slug}-{property-type}-{period}.html
{community-slug}-{property-type}-{period}.json

Examples:
- the-meadows-villas-h1-2025.html
- dubai-marina-apartments-q4-2024.html
- palm-jumeirah-villas-2024-full-year.html
```

---

## 3. Workflow Pipeline

### Stage 1: Initialization
```
┌────────────────────────────────────────────────────────┐
│ 1. Load PDF inventory (240 files)                      │
│ 2. Parse CSV URL mappings                              │
│ 3. Initialize processing queue                         │
│ 4. Create output directories                           │
│ 5. Log batch start                                     │
└────────────────────────────────────────────────────────┘
```

### Stage 2: Extraction (Per Report) - PDF to JSON
```
┌────────────────────────────────────────────────────────┐
│ 1. PDF Parser Agent extracts raw data                  │
│    - Uses prompts/pdf-extraction-prompt.md             │
│    - Outputs: metrics, charts, rawTextPassages,        │
│      visualDescriptions                                │
│ 2. CSV Metadata Agent adds URL mapping                 │
│ 3. Validate extraction completeness                    │
│ 4. Store intermediate ParsedReportData                 │
└────────────────────────────────────────────────────────┘
```

### Stage 3: Content Enhancement + Component Selection + SEO Generation (Per Report)
```
┌────────────────────────────────────────────────────────┐
│ MERGED: Content, visualization, and SEO generation     │
│                                                        │
│ 1. Content Enhancement Agent (with Component Matrix)   │
│    - Uses prompts/content-enhancement-prompt.md        │
│    - Input: Stage 2 extracted JSON                     │
│    - Selects visualization components per data type    │
│    - Writes summaries that reference selected visuals  │
│                                                        │
│ 2. SEO Object Generation:                              │
│    - Generate schemaOrg object from metadata           │
│    - Convert period to ISO temporalCoverage            │
│    - Derive description from executiveSummaryEnhanced  │
│    - Reference: seo-accessibility.md Section 2         │
│                                                        │
│ 3. Output: schemaOrg + enhanced objects containing:    │
│    - schemaOrg (Dataset JSON-LD structure)             │
│    - executiveSummaryEnhanced                          │
│    - chartSummaries (component-aware)                  │
│    - marketDynamicsEnhanced                            │
│    - marketInsightsEnhanced                      │
│    - investorConsiderationsEnhanced                    │
│    - seoMetaContent                                    │
│    - componentSelections (visualization assignments)   │
│                                                        │
│ 4. Validate:                                           │
│    - Content quality (no CTAs, specific numbers)       │
│    - Component-content coherence                       │
│    - Summaries reference correct visualization types   │
│    - schemaOrg completeness (all required fields)      │
│    - dataTable presence on all graphs                  │
│                                                        │
│ 5. Store EnhancedReportData with SEO + component data  │
└────────────────────────────────────────────────────────┘
```

**Why merged?** Component selection and content writing are naturally coupled.
When an analyst writes "the line traces an upward trajectory," they're
simultaneously deciding it's a line chart AND describing what they see.
Separating these creates artificial disconnect between narrative and visuals.

### Stage 4: Generation (Per Report)

**Prompt Reference**: `prompts/html-generation-prompt.md`

```
┌────────────────────────────────────────────────────────┐
│ 1. HTML Generator Agent builds complete HTML           │
│    - Uses prompts/html-generation-prompt.md            │
│    - Uses enhanced content + componentSelections       │
│      from Stage 3                                      │
│    - Renders selected components with data             │
│    - Generates SVG paths for charts                    │
│ 2. JSON Generator Agent creates data file              │
│    - Includes extracted, enhanced, and component       │
│      selection fields                                  │
│ 3. Initial self-validation                             │
│ 4. Store draft outputs                                 │
└────────────────────────────────────────────────────────┘
```

### Stage 5: Quality Control (Per Report)
```
┌────────────────────────────────────────────────────────┐
│ 1. QC Agent runs full validation suite                 │
│                                                        │
│ 2. SEO/Accessibility Validation (BLOCKING)             │
│    Reference: seo-accessibility.md                     │
│    - [ ] Schema.org JSON-LD in <head> with all fields  │
│    - [ ] Every chart has <table class="sr-only...">    │
│    - [ ] All sections have aria-labelledby             │
│    - [ ] Chart containers have role="img"              │
│    - [ ] <p class="chart-summary"> before each chart   │
│    - [ ] <p class="data-source"> after each chart      │
│    - [ ] .sr-only.chart-data-table CSS present         │
│    - [ ] All IDs unique within document                │
│    FAILURE = REJECT (no score calculation)             │
│                                                        │
│ 3. Calculate quality score (if SEO passes):            │
│    - Data accuracy (35%)                               │
│    - Content quality (25%)                             │
│    - Component coherence (15%) - summaries match visuals│
│    - SEO compliance (10%) - beyond minimum requirements│
│    - HTML validity (10%)                               │
│    - Accessibility (5%)                                │
│                                                        │
│ 4. Route based on score:                               │
│    - ≥90: Approve → Final Assembly                     │
│    - 70-89: Flag → Human Review Queue                  │
│    - <70: Reject → Reprocess or Manual                 │
└────────────────────────────────────────────────────────┘
```

### Stage 6: Finalization (Batch)
```
┌────────────────────────────────────────────────────────┐
│ 1. Final Assembly Agent packages approved outputs      │
│ 2. Generate batch manifest                             │
│ 3. Create quality summary report                       │
│ 4. Archive processing logs                             │
│ 5. Notify completion                                   │
└────────────────────────────────────────────────────────┘
```

---

## 4. Quality Assurance Framework

### 4.1 Automated Checks

| Check Type | Tool/Method | Pass Criteria |
|------------|-------------|---------------|
| HTML Validity | html5lib parser | Zero errors |
| JSON Validity | jsonschema | Validates against schema |
| Schema.org | Google Rich Results Test API | Valid Dataset |
| Accessibility | axe-core or pa11y | Zero critical issues |
| Link Validation | Internal ref checker | No broken links |
| Data Consistency | Cross-reference HTML/JSON/Source | 100% match |

### 4.2 Human Review Triggers

Reports are flagged for human review when:
- Quality score is 70-89
- Novel data patterns detected (outliers, anomalies)
- PDF extraction confidence < 85%
- Community not in known list
- Significant YoY changes (>100% or < -50%)
- Missing sections that should be present

### 4.3 Sampling Strategy

For the initial batch of 240 reports:
- **Pilot Phase**: Process 10 reports, full human review
- **Validation Phase**: Process 50 reports, 20% sampled review
- **Production Phase**: Process remaining, 5% random + flagged review

### 4.4 Error Recovery

```
┌─────────────────────────────────────────────────────────┐
│                    ERROR HANDLING                        │
├─────────────────────────────────────────────────────────┤
│ PDF Parse Failure:                                       │
│   → Attempt with alternative parser (PyMuPDF/pdfplumber)│
│   → If still fails, move to manual extraction queue     │
│                                                          │
│ Data Calculation Error:                                  │
│   → Log specific calculation that failed                │
│   → Continue with available data, flag for review       │
│                                                          │
│ Component Rendering Error:                               │
│   → Fallback to simpler component variant               │
│   → If critical, skip component and flag                │
│                                                          │
│ QC Rejection:                                            │
│   → Log specific failures                               │
│   → Attempt targeted fix (up to 2 retries)              │
│   → After 2 failures, escalate to manual                │
└─────────────────────────────────────────────────────────┘
```

---

## 5. Implementation Approach for Claude Code

### 5.1 Recommended Execution Strategy

Given Claude Code's strengths, the recommended approach is:

**Option A: Sequential Processing with Checkpoints** (Recommended for reliability)
- Process reports one at a time
- Save state after each successful report
- Enables easy resume on interruption
- Better for maintaining context quality

**Option B: Batch Processing with Parallelization** (Faster but riskier)
- Process multiple reports in parallel threads
- Higher throughput but more complex error handling
- Requires careful resource management

### 5.2 Claude Code Session Structure

Each processing session should:

1. **Load Context**
   - Read SKILL.md
   - Read component-library.html
   - Read seo-accessibility.md
   - Read json-schema.md
   - Read prompts/pdf-extraction-prompt.md
   - Read prompts/content-enhancement-prompt.md

2. **Process Single Report (Two-Stage)**
   - **Stage 1**: Extract PDF data using pdf-extraction-prompt.md
   - **Stage 2**: Enhance content using content-enhancement-prompt.md
   - Select components based on data
   - Generate HTML with enhanced content
   - Generate JSON with both extracted and enhanced fields
   - Validate outputs

3. **Save State**
   - Write outputs to filesystem
   - Update processing log
   - Clear context for next report

### 5.3 Suggested Prompt Template for Processing

```markdown
## Task: Convert PDF Report to HTML + JSON (Two-Stage Pipeline)

### Input Files:
- PDF: {pdf_path}
- Component Library: MPP-COMPONENTS-LIBRARY-v5-SEO.html (single source of truth)
- SEO Requirements: mpp-real-estate-reports-skill-with-json/seo-accessibility.md
- JSON Schema: mpp-real-estate-reports-skill-with-json/json-schema.md
- Stage 1 Prompt: prompts/pdf-extraction-prompt.md
- Stage 2 Prompt: prompts/content-enhancement-prompt.md
- Target URL: {canonical_url}

### Required Outputs:
1. HTML file following component library guidelines (using enhanced content)
2. JSON file following schema (including enhanced object)
3. Processing log entry

### Steps:
**Stage 1 - Initialization:**
1. Load component library reference (component matrix)
2. Prepare extraction context

**Stage 2 - Extraction:**
3. Extract data from PDF using pdf-extraction-prompt.md
4. Capture rawTextPassages and visualDescriptions
5. Validate extraction completeness

**Stage 3 - Content Enhancement + Component Selection (Merged):**
6. Select visualization components using Component Matrix
7. Write component-aware summaries (referencing selected visuals)
8. Generate executiveSummaryEnhanced, chartSummaries, marketDynamicsEnhanced
9. Generate investorConsiderationsEnhanced and seoMetaContent
10. Output componentSelections with visualization assignments
11. Validate content quality AND component-content coherence

**Stage 4 - HTML/JSON Generation:**
12. Generate HTML using selected components with enhanced content
13. Generate JSON with extracted + enhanced + componentSelections
14. Validate both outputs
15. Report quality score

### Validation Requirements:
- Schema.org JSON-LD present in <head> (from schemaOrg object)
- schemaOrg.temporalCoverage is valid ISO date range
- All charts have hidden data tables (<table class="sr-only chart-data-table">)
- ARIA attributes complete (aria-labelledby, role="img", aria-describedby)
- <p class="chart-summary"> before each visualization
- <p class="data-source"> after each visualization
- .sr-only.chart-data-table CSS included
- All metrics accurate
- No placeholder content
- Enhanced content has specific numbers (not vague descriptors)
- No promotional language or CTAs in enhanced content
- Primary keyword appears in executiveSummaryEnhanced
- Reference: seo-accessibility.md for complete SEO checklist
```

---

## 6. Deliverables Checklist

### Per Report:
- [ ] HTML report file (self-contained)
- [ ] JSON data file
- [ ] Processing log entry

### Per Batch:
- [ ] Manifest (index of all reports)
- [ ] Quality summary report
- [ ] Error/exception log
- [ ] Human review queue list

### Documentation:
- [ ] JSON Schema specification (json-schema.md)
- [ ] Processing runbook
- [ ] Troubleshooting guide

---

## 7. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Completion Rate | 95%+ | Reports successfully processed / Total |
| Quality Score Average | 90+ | Mean QC score across batch |
| Data Accuracy | 99%+ | Spot-check verification |
| Content Quality | 85%+ | Enhanced content passes review (specific numbers, no CTAs) |
| SEO Compliance | 100% | Schema.org validation pass rate |
| Processing Time | <5 min/report | Average end-to-end time |
| Human Review Rate | <15% | Reports requiring manual intervention |

---

## 8. Appendix: File Dependencies

### Required Input Files:
1. `resale-report-pdfs/*.pdf` (240 files)
2. `resale-report-pdfs/report-urls-with-pdf-links.csv` (244 rows, 4 duplicates)
3. `MPP-COMPONENTS-LIBRARY-v5-SEO.html` - Component library with Schema.org SEO (single source)
4. `mpp-real-estate-reports-skill-with-json/SKILL.md` - Skill instructions
5. `mpp-real-estate-reports-skill-with-json/seo-accessibility.md` - SEO requirements
6. `mpp-real-estate-reports-skill-with-json/json-schema.md` - Extended JSON schema (updated)
7. `prompts/pdf-extraction-prompt.md` - Stage 1: Extraction prompt for Claude vision
8. `prompts/content-enhancement-prompt.md` - Stage 2/3: Content enhancement prompt
9. `prompts/html-generation-prompt.md` - Stage 4: HTML generation prompt
10. `sample-input-output/1.sample-input-pdf-output-html/resale_report_data_json_scheme.json` - Sample JSON
11. `sample-input-output/1.sample-input-pdf-output-html/sample-input-*.pdf` (reference)
12. `sample-input-output/1.sample-input-pdf-output-html/sample-output-*.html` (reference)

### Archived Files (in `_archive/` folder):
- `MPP-COMPONENTS-LIBRARY-v4.html` - Superseded by v5-SEO
- `MASTER-COMPONENTS-TEMPLATES.html` - Subset of v5
- `MASTER-COMPONENTS-STYLES.css` - CSS now in v5
- `coded-blocks/` - Individual component fragments

### Files to Create:
1. `output/manifest.json` - Batch manifest
2. `output/processing-log.json` - Processing status log
3. `output/quality-report.csv` - QC results summary

---

## 9. Next Steps

### Completed:
1. [x] **Audit CSV/PDF mapping** - Found 4 duplicates (not missing files)
2. [x] **Fix JSON schema typo** - Corrected "keyPerformace" to "keyPerformance"
3. [x] **Extend JSON schema** - Added metadata, IDs, dataTables for SEO compliance
4. [x] **Update json-schema.md** - Documented extended developer schema
5. [x] **Create extraction prompt** - Created `prompts/pdf-extraction-prompt.md`
6. [x] **Consolidate component files** - Archived redundant files, v5-SEO is single source
7. [x] **Two-stage pipeline** - Added rawTextPassages/visualDescriptions to extraction prompt
8. [x] **Content enhancement prompt** - Created `prompts/content-enhancement-prompt.md` for Stage 2
9. [x] **Update json-schema.md** - Added enhanced content fields and Stage 2 documentation
10. [x] **Update orchestration plan** - Added Stage 3 (Content Enhancement) to workflow

### Remaining:
11. [ ] **Pilot**: Process 5-10 reports to validate two-stage workflow
12. [ ] **Iterate**: Refine content enhancement based on pilot outputs
13. [ ] **Scale**: Implement automated batch processing with checkpoints
14. [ ] **Review**: Human QC of flagged reports and random sample
15. [ ] **Deploy**: Publish approved reports to target URLs

---

*Document Version: 1.4*
*Created: January 19, 2026*
*Updated: January 20, 2026 - Integrated SEO/Accessibility requirements throughout pipeline*
*Changes: Added schemaOrg generation to Stage 3, SEO validation to Stage 5, HTML template requirements to HTML Generator*
*Reference: seo-accessibility.md for complete SEO requirements*
*For: the company SEO Team*
