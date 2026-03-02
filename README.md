# Market Report Digitization Platform

Multi-agent pipeline that converts PDF real estate market reports into publication-ready HTML pages with SEO optimization, Schema.org markup, and a brand-consistent CSS component library. Built for a Dubai-based real estate company.

## What It Does

Takes PDF resale reports as input and produces self-contained HTML output with responsive CSS, data tables, SVG charts, and metrics sections. A Claude Code orchestrator agent coordinates specialist sub-agents for data extraction, content enhancement, HTML assembly, and QA validation. Designed for monthly batch processing of property market reports covering individual Dubai communities.

## Architecture

```
PDF Input (resale market reports)
  --> Orchestrator Agent (reads consolidated-orchestration-plan.md)
  --> Stage 1: Extraction Agent (PDF-to-JSON, preserves exact formatting)
  --> Stage 2: Enhancement Agent (SEO content, component selection, Schema.org)
  --> Stage 3: HTML Generation Agent (assembles from MPP component library)
  --> Stage 4: QA Agent (binary pass/fail, validates completeness)
  --> Stage 5: Fix Agent (targeted corrections on QA failures)
  --> Output: JSON + self-contained HTML (publication-ready)
```

Two pipeline variants share the same CSV tracker and batch scripts:

- **Full pipeline** (`run-orchestrator.ps1` / `run-batch.ps1`): 5 stages, produces JSON + HTML
- **JSON-only pipeline** (`run-orchestrator-json.ps1` / `run-batch-json.ps1`): 4 stages, JSON output for developer-built HTML

Each stage runs as a fresh Claude Code session with focused context. Data passes between stages via JSON files in `output/`. No state bleeds between agents.

## Tech Stack

- PowerShell 7+ (orchestration, batch processing, CSV state tracking)
- Claude Code CLI (`claude --dangerously-skip-permissions -p <prompt>`) for all agent passes
- HTML/CSS component library (`MPP-COMPONENTS-LIBRARY-v5-SEO.html`, 3500+ lines)
- Schema.org JSON-LD (serialized directly from enhanced JSON into `<head>`)

## Key Files

| Path | Purpose |
|------|---------|
| `batch/run-orchestrator.ps1` | Single-report launcher (full pipeline) |
| `batch/run-batch.ps1` | Multi-report batch launcher (full pipeline) |
| `batch/run-orchestrator-json.ps1` | Single-report launcher (JSON-only pipeline) |
| `batch/run-batch-json.ps1` | Multi-report batch launcher (JSON-only pipeline) |
| `batch/processing-status.csv` | Per-report progress tracker (source of truth for batch state) |
| `consolidated-orchestration-plan.md` | Full pipeline spec -- orchestrator reads this |
| `prompts/pdf-extraction-prompt.md` | Stage 1: PDF-to-JSON extraction rules |
| `prompts/component-selection-rules.md` | Stage 2: Deterministic component selection algorithm |
| `prompts/content-enhancement-prompt.md` | Stage 2: SEO content generation and JSON enrichment |
| `prompts/html-generation-prompt.md` | Stage 3: HTML assembly with SVG charts |
| `MPP-COMPONENTS-LIBRARY-v5-SEO.html` | Master component library -- all HTML templates and CSS |
| `mpp-real-estate-reports-skill-with-json/` | Claude skill definition, JSON schema, SEO spec |
| `developer-handoff/` | Spec for building HTML from enhanced JSON externally |
| `output/` | Generated artifacts (HTML, JSON, QA reports) |
| `resale-report-pdfs/` | Source PDF files |

## Setup

### Prerequisites

- Claude Code CLI installed and authenticated (`claude` available on PATH)
- PowerShell 7+

### Running a single report (full pipeline)

```powershell
cd batch
.\run-orchestrator.ps1 -Slug <report-slug>
```

### Running a single report (JSON-only pipeline)

```powershell
cd batch
.\run-orchestrator-json.ps1 -Slug <report-slug>
```

### Batch processing

```powershell
cd batch
.\run-batch.ps1              # Process all pending (full pipeline)
.\run-batch.ps1 -Limit 5    # Process next 5 pending
.\run-batch-json.ps1         # Batch for JSON-only pipeline
```

### Check status

```powershell
cd batch
.\run-orchestrator.ps1 -Status
```

## Output Format

Each processed report produces:

- `output/[slug]-extracted.json` -- Raw extraction from PDF (intermediate artifact)
- `output/[slug].json` -- Enhanced JSON with SEO content, component selections, Schema.org data
- `output/[slug].html` -- Self-contained HTML page (all CSS inline, Google Fonts only external dep)
- `output/[slug]-qa-report.md` -- QA agent output (pass/fail with notes)

## Component Selection

Component selection is deterministic, not AI-creative. The algorithm in `prompts/component-selection-rules.md` uses explicit thresholds based on `pointCount`, `categoryCount`, and data characteristics. Each selection decision is recorded with rationale in the enhanced JSON under `enhanced.componentSelections`.

## Design Tokens

```
Primary:   #01AEE5 (cyan), #57CE9F (green), #E7AC65 (orange)
Gradient:  #107899 -> #01AEE5
Semantic:  #278702 (positive), #E40000 (negative)
Font:      Inter (400, 500, 600, 700)
```

## Developer Handoff

If building HTML from the JSON output externally (not using the HTML generation agent), see `developer-handoff/README.md` for the full data specification including section rendering order, component mappings, conditional branching rules, and known data quirks.

## Project Status

Active. In production use for monthly market report publication.

## License

MIT
