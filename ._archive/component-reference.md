# Component Reference

Detailed documentation for each component in the MPP Real Estate Reports library.

## Table of Contents
1. [Summary Blocks](#1-summary-blocks)
2. [KPI & Metrics](#2-kpi--metrics)
3. [Data Tables](#3-data-tables)
4. [Bar Charts](#4-bar-charts)
5. [Line Charts](#5-line-charts)
6. [Content Blocks](#6-content-blocks)

---

## 1. Summary Blocks

### 1.1 Executive Summary Card
**Use for**: Opening statement with key metric and trend visualization
**Structure**: Left content area (title + description) + Right mini sparkline chart
**Key classes**: `.executive-summary-card`, `.executive-summary-card__content`, `.executive-summary-card__title`, `.executive-summary-card__description`, `.executive-summary-card__chart`

### 1.2 Market Insight Block
**Use for**: Highlighted callouts, key findings, analyst observations
**Structure**: Icon + Title + Description with cyan left border accent
**Key classes**: `.market-insight`, `.market-insight__icon`, `.market-insight__title`, `.market-insight__description`

### 1.3 Source Citation
**Use for**: Data attribution, methodology notes
**Structure**: Simple paragraph with muted styling
**Key class**: `.source-citation`

---

## 2. KPI & Metrics

### 2.1 Key Performance Indicators (4-column strip)
**Use for**: Primary metrics dashboard at report top
**Structure**: 4 connected cards, each with icon + value + label
**Recommended metrics**: Price/sqft, YoY growth, transaction count, total value
**Key classes**: `.key-performance`, `.kpi-grid`, `.kpi-card`, `.kpi-card__icon`, `.kpi-card__value`, `.kpi-card__label`

### 2.2 Indicators Block
**Use for**: Hero stat highlighting (rentals, yields, etc.)
**Structure**: 2-column grid with gradient primary card + secondary card with donut
**Key classes**: `.indicators`, `.indicator-card`, `.indicator-card--primary`, `.indicator-card--secondary`

### 2.3 Comparison Metrics Cards
**Use for**: Category breakdowns (transaction types, contract distribution)
**Structure**: Side-by-side cards with cyan top border, each containing labeled rows
**Key classes**: `.comparison-metrics`, `.metrics-card`, `.metrics-row`

---

## 3. Data Tables

### 3.1 Price Data Insights Table
**Use for**: Bedroom/unit breakdowns with pricing and performance
**Columns**: Bedrooms | Average Price | Transactions | YoY Change
**Styling**: Alternating row colors, cyan header text, green/red YoY values
**Key classes**: `.price-data-insights`, `.insights-table`, `.yoy-value.positive`, `.yoy-value.negative`

### 3.2 Key Differences Table
**Use for**: Feature comparisons, option analysis
**Columns**: Feature | Option A | Option B
**Styling**: Clean comparison layout with feature labels bold
**Key classes**: `.key-differences`, `.differences-table`, `.feature-label`

---

## 4. Bar Charts

### 4.1 Vertical Multi-bar Chart
**Use for**: Period-over-period comparisons (2024 vs 2025)
**Structure**: Y-axis labels + Grid + Grouped bars + X-axis labels + Legend
**Bar colors**: Cyan (period 1), Green (period 2)
**Height calculation**: `(value / max_y) × 100%`
**Key classes**: `.bars-container--multibar`, `.bar-group`, `.bar--cyan`, `.bar--green`

### 4.2 Vertical Single-bar Chart
**Use for**: Distribution/volume by category
**Structure**: Y-axis + Grid + Single bars with value labels inside + Category labels below
**Features**: Value displayed inside bar, label below
**Key classes**: `.bars-container--single`, `.bar-wrapper`, `.bar--labeled`, `.bar__value`, `.bar__label`

### 4.3 Vertical Stacked Bar Chart
**Use for**: Composition analysis (off-plan vs ready, new vs renewal)
**Structure**: Y-axis (0-100%) + Full-height stacked columns + Legend
**Segment sizing**: Use `flex` property for proportions
**Key classes**: `.bars-container--stacked`, `.bar-column`, `.stacked-bar`, `.bar-segment--cyan`, `.bar-segment--green`

### 4.4 Horizontal Bar Chart
**Use for**: Rankings, Top N lists
**Structure**: Scale header + Repeating bar groups (label + bar with value)
**Bar width**: CSS variable `--bar-width: XX%`
**Key classes**: `.horizontal-chart`, `.horizontal-bar-group`, `.horizontal-bar`, `.horizontal-bar__value`

---

## 5. Line Charts

### 5.1 Single Line Chart with Area Fill
**Use for**: Single metric trend over time
**Structure**: Y-axis + Grid + SVG (area fill path + line path + data points) + X-axis
**SVG viewBox**: `0 0 100 100` with `preserveAspectRatio="none"`
**Coordinate system**: X = 0-100 (left to right), Y = 0-100 (0 = top, 100 = bottom)
**Key classes**: `.grid-container--line`, `.line-chart`, `.area-fill`, `.line-path`, `.data-points`, `.data-point`

### 5.2 Multi-line Comparison Chart
**Use for**: Comparing trends across communities/segments
**Structure**: Same as single line but multiple `<path>` elements
**Line colors**: Cyan, Green, Orange
**Key classes**: `.trend-line`, `.trend-line--cyan`, `.trend-line--green`, `.trend-line--orange`

---

## 6. Content Blocks

### 6.1 Market Dynamics
**Use for**: Long-form analysis with supporting imagery
**Structure**: 2-column grid with text wrapping around image
**Grid areas**: text (top-left), image (right), additional (bottom-left)
**Key classes**: `.market-dynamics`, `.market-dynamics__wrapper`, `.market-dynamics__text`, `.market-dynamics__image`, `.market-dynamics__additional`

### 6.2 Investor Considerations
**Use for**: Recommendations, factors to consider, key points
**Structure**: Title + Subtitle + 6-column icon card grid
**Card variants**: Standard (2 columns), Wide (3 columns)
**Key classes**: `.investor-considerations`, `.investor-considerations__grid`, `.consideration-card`, `.consideration-card--wide`

---

## SVG Icon Library

Common icons included in component-library.html:

```html
<!-- Clock (timing) -->
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <circle cx="12" cy="12" r="10" stroke="#01AEE5" stroke-width="1.5"/>
  <path d="M12 6v6l4 2" stroke="#01AEE5" stroke-width="1.5" stroke-linecap="round"/>
</svg>

<!-- Trend Up (growth) -->
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M3 17l6-6 4 4 8-8" stroke="#01AEE5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M17 7h4v4" stroke="#01AEE5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

<!-- Bar Chart (volume) -->
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <rect x="3" y="10" width="4" height="10" stroke="#01AEE5" stroke-width="1.5"/>
  <rect x="10" y="6" width="4" height="14" stroke="#01AEE5" stroke-width="1.5"/>
  <rect x="17" y="2" width="4" height="18" stroke="#01AEE5" stroke-width="1.5"/>
</svg>

<!-- Checkmark Circle (quality) -->
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <circle cx="12" cy="12" r="10" stroke="#01AEE5" stroke-width="1.5"/>
  <path d="M8 12l2 2 4-4" stroke="#01AEE5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

<!-- Target (focus) -->
<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
  <path d="M12 2v4m0 12v4M2 12h4m12 0h4" stroke="#01AEE5" stroke-width="1.5" stroke-linecap="round"/>
  <circle cx="12" cy="12" r="6" stroke="#01AEE5" stroke-width="1.5"/>
</svg>
```

---

## Responsive Breakpoints

- **Desktop**: Default styles (max-width: 1120px container)
- **Tablet**: `@media (max-width: 900px)` - Single column KPIs, stacked grids
- **Mobile**: `@media (max-width: 600px)` - Horizontal table scroll, reduced chart heights
- **Small Mobile**: `@media (max-width: 480px)` - Compact typography, minimal spacing
