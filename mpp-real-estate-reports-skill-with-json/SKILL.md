---
name: mpp-real-estate-reports
description: Professional real estate report and article creation using the company component library. Use when creating HTML reports, market analyses, research papers, blog posts, or data visualizations for real estate content. Triggers on requests involving Dubai/UAE real estate reports, property market analysis, transaction data visualization, price trends, community comparisons, investor guides, rental yield reports, or any content requiring professional real estate data presentation with charts, tables, KPIs, and executive summaries. Includes mandatory SEO optimization with Schema.org markup, semantic HTML, ARIA accessibility, and crawlable data tables for all visualizations.
---

# BRAND Real Estate Reports Skill

Create professional, visually polished HTML reports and articles for real estate content using the MPP component library.

## Quick Start

1. Read `assets/component-library.html` to access full CSS and HTML templates
2. Read `references/json-schema.md` for JSON output structure
3. Select components based on content type (see Component Selection below)
4. Assemble components into complete HTML document
5. Populate with actual data, replacing placeholder values
6. Generate companion JSON file with identical data

## Component Selection Guide

### For Executive Summaries & Key Takeaways
- **Executive Summary Card**: Opening hook with key insight + mini sparkline chart
- **Market Insight Block**: Highlighted callout for important findings
- **Source Citation**: Attribution footer

### For KPIs & Metrics Display
- **Key Performance Indicators (4-column)**: Primary metrics strip (price/sqft, YoY%, transactions, total value)
- **Indicators Block**: Hero stat with gradient + supporting metric with donut chart
- **Comparison Metrics Cards**: Side-by-side category breakdowns

### For Data Tables
- **Price Data Insights Table**: Bedroom/unit type with price, transactions, YoY change
- **Key Differences Table**: Feature comparison across options

### For Charts
| Data Type | Component |
|-----------|-----------|
| Period comparison (2024 vs 2025) | Vertical Multi-bar Chart |
| Volume/distribution by category | Vertical Single-bar Chart |
| Composition/proportions | Vertical Stacked Bar Chart |
| Rankings/Top N | Horizontal Bar Chart |
| Trends over time | Single Line Chart with Area Fill |
| Multi-series trends | Multi-line Comparison Chart |

### For Content Blocks
- **Market Dynamics**: Long-form analysis with image (text wraps around image)
- **Investor Considerations**: Icon cards grid for recommendations/factors

## Document Structure Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Report Title]</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* Copy CSS from component-library.html (lines 10-1699) */
    /* Remove demo-only styles: .component-section, .section-header, .component-demo, .component-label */
  </style>
</head>
<body>
  <!-- Executive Summary -->
  <!-- KPIs/Metrics -->
  <!-- Charts -->
  <!-- Tables -->
  <!-- Content Blocks -->
  <!-- Source Citation -->
</body>
</html>
```

## CSS Variables Reference

```css
/* Primary Colors */
--color-brand-cyan: #01AEE5;
--color-brand-green: #57CE9F;
--color-brand-orange: #E7AC65;

/* Semantic */
--color-positive: #278702;
--color-negative: #E40000;

/* Gradient for hero indicators */
--gradient-primary: linear-gradient(90deg, #107899 0%, #01AEE5 100%);
```

## Data Formatting Conventions

- Currency: `AED X,XXX` or `AED X.XM` for millions
- Percentages: `+XX.X%` (positive green) or `-XX.X%` (negative red)
- Prices per sqft: `AED X,XXX`
- Transaction counts: Plain integers

## Chart Height Calculations

For bar charts, calculate height percentages:
```
height% = (value / max_y_axis_value) × 100
```

For line charts, calculate Y position (inverted, 0 = top):
```
top% = 100 - ((value - min) / (max - min) × 100)
```

## Icon SVGs

Copy icon SVGs directly from component-library.html. Common icons available:
- Clock (timing/entry)
- Trend line (growth/performance)
- Bar chart (volume/distribution)
- Checkmark circle (quality/selection)
- Target/crosshair (flexibility/focus)

## Output Requirements

1. Single self-contained HTML file
2. All CSS inline in `<style>` tag
3. No external dependencies except Google Fonts
4. Responsive design included (tablet + mobile breakpoints)
5. Replace all placeholder content with actual data
6. **SEO/Accessibility compliance** — See `references/seo-accessibility.md` (MANDATORY)
7. **Companion JSON file** — Structured data version of the report (MANDATORY)

## JSON Output (Mandatory)

Every HTML report MUST have a companion JSON file following the schema in `references/json-schema.md`.

### Why JSON Output?
- Database storage of report content
- API responses for programmatic access
- Template-driven regeneration of HTML
- Content validation and diffing
- Multi-format publishing (PDF, email, etc.)

### Key Requirements
1. **Same filename** with `.json` extension (e.g., `report.html` → `report.json`)
2. **All data duplicated** — JSON must contain all text, values, and data from HTML
3. **rawValue fields** — Always include numeric values alongside formatted display strings
4. **dataTable objects** — Required for all charts (mirrors SEO crawlable tables)
5. **Unique IDs** — Every component must have a unique `id` field

### JSON Document Structure
```json
{
  "version": "1.0",
  "documentType": "market-report",
  "metadata": { ... },
  "components": [ ... ]
}
```

See `references/json-schema.md` for complete component schemas.

## SEO & Accessibility Requirements (Mandatory)

Every chart and visualization MUST include:

1. **Companion Data Table** — Hidden but crawlable table with all data points
2. **Schema.org Dataset** — JSON-LD structured data in `<head>`
3. **Semantic HTML** — `<section>`, `<figure>`, `<figcaption>`, ARIA labels
4. **Text Summaries** — 1-2 sentence prose summary per visualization
5. **Crawlable KPIs** — Stats in HTML text, not just data attributes

See `references/seo-accessibility.md` for implementation templates.

## Usage Example

User: "Create a report on The Meadows villa market performance in H1 2025"

Action:
1. Read component-library.html for full templates
2. Read references/json-schema.md for JSON structure
3. Select: Executive Summary Card + KPI strip + Price Data Table + Line Chart + Market Dynamics
4. Assemble document with actual market data
5. Output **both files**:
   - `meadows-villa-market-h1-2025.html` — Complete styled report
   - `meadows-villa-market-h1-2025.json` — Structured data version
