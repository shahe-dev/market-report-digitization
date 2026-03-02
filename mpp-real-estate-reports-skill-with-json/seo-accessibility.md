# SEO & Accessibility Requirements for Charts

All charts, graphs, and data visualizations MUST follow these requirements to ensure search engine crawlability and AI readability.

## Table of Contents
1. [Companion Data Tables](#1-companion-data-tables)
2. [Schema.org Structured Data](#2-schemaorg-structured-data)
3. [Semantic HTML Structure](#3-semantic-html-structure)
4. [Crawlable KPI Cards](#4-crawlable-kpi-cards)
5. [Text Summaries](#5-text-summaries)
6. [Complete Example](#6-complete-example)

---

## 1. Companion Data Tables

Every chart/graph MUST have a toggleable companion data table for SEO crawlability. The table is collapsed by default and expands when the user clicks "View Data Table".

**Applies to:** Line charts, bar graphs, multi-line charts, horizontal bar charts, stacked bar charts.

**Does NOT apply to:** KPIs, text sections, executive summaries, investor considerations, or tables that are already visible (Price Insights, Key Differences).

### Implementation (Preferred - Toggleable)

```html
<figure class="chart-figure">
  <div class="chart-container" role="img" aria-describedby="price-trend-desc">
    <!-- Visual chart renders here -->
  </div>
  <figcaption id="price-trend-desc">
    Line chart showing quarterly price per square foot from Q1 2024 through H1 2025.
  </figcaption>

  <!-- Toggleable Data Table -->
  <details class="chart-data-toggle">
    <summary>
      <span class="toggle-icon"></span>
      View Data Table
    </summary>
    <div class="data-table-container">
      <table class="chart-data-table">
        <caption class="sr-only">Average Price per Sq. Ft - The Meadows Villas</caption>
        <thead>
          <tr>
            <th scope="col">Period</th>
            <th scope="col">Avg. Price (AED/SQ.FT)</th>
            <th scope="col">Transactions</th>
            <th scope="col">QoQ Change</th>
          </tr>
        </thead>
        <tbody>
          <tr><td>Q1 2024</td><td>AED 2,180</td><td>42</td><td>-</td></tr>
          <tr><td>Q2 2024</td><td>AED 2,340</td><td>38</td><td>+7.3%</td></tr>
          <tr><td>Q3 2024</td><td>AED 2,520</td><td>45</td><td>+7.7%</td></tr>
          <tr><td>Q4 2024</td><td>AED 2,710</td><td>41</td><td>+7.5%</td></tr>
          <tr><td>H1 2025</td><td>AED 2,911</td><td>78</td><td>+7.4%</td></tr>
        </tbody>
      </table>
    </div>
  </details>

  <p class="data-source">Source: Property Monitor, Your Company Name Analysis</p>
</figure>
```

### Extended Columns (Time-Series Only)

Time-series charts (trend, transactions, rental price) support additional columns beyond the chart data:

| Column | Description |
|--------|-------------|
| Period | Time period from chart xAxis |
| Value | Primary metric from chart yAxis |
| Transactions | Volume/count for that period |
| Change | QoQ/YoY percentage change |

Non-time-series charts (distribution, ranking, composition) use simpler 2-3 column format matching their data structure.

### Required CSS

```css
/* Toggleable Data Table */
.chart-data-toggle {
  margin-top: 16px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

.chart-data-toggle summary {
  padding: 12px 16px;
  background: #f5f5f5;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #01AEE5;
}

.chart-data-toggle[open] summary {
  border-bottom: 1px solid #e0e0e0;
}

.data-table-container {
  padding: 16px;
}

.chart-data-table {
  width: 100%;
  border-collapse: collapse;
}

.chart-data-table th {
  background: #01AEE5;
  color: white;
  padding: 12px;
  text-align: left;
  text-transform: uppercase;
  font-size: 12px;
}

.chart-data-table td {
  padding: 12px;
  border-bottom: 1px solid #e0e0e0;
}

.chart-data-table tr:nth-child(even) {
  background: #f9f9f9;
}

/* Screen-reader only (for caption) */
.sr-only {
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

### Fallback (sr-only Hidden Tables)

For simpler implementations without JavaScript toggle functionality, you may use hidden tables:

```html
<table class="sr-only chart-data-table">
  <!-- Same table structure, but always hidden -->
</table>
```

This approach is less user-friendly but still provides SEO crawlability.

---

## 2. Schema.org Structured Data

Every report page MUST include Dataset schema in the `<head>`.

### Template

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Dataset",
  "name": "[Report Title]",
  "description": "[One-sentence description of the data]",
  "temporalCoverage": "[Start Date]/[End Date]",
  "spatialCoverage": {
    "@type": "Place",
    "name": "[Location], Dubai, UAE"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Your Company Name",
    "url": "https://your-company.com"
  },
  "datePublished": "[Publication Date]",
  "license": "https://your-company.com/terms"
}
</script>
```

### Example

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Dataset",
  "name": "The Meadows Villas Resale Market Report H1 2025",
  "description": "Comprehensive analysis of villa resale transactions in The Meadows, Dubai including price trends, transaction volumes, and bedroom configuration breakdowns",
  "temporalCoverage": "2025-01-01/2025-06-30",
  "spatialCoverage": {
    "@type": "Place",
    "name": "The Meadows, Dubai, UAE"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Your Company Name",
    "url": "https://your-company.com"
  },
  "datePublished": "2025-07-15"
}
</script>
```

---

## 3. Semantic HTML Structure

Every data visualization block MUST use this structure:

```html
<section aria-labelledby="[unique-id]">
  <h2 id="[unique-id]">[Chart Title]</h2>
  
  <!-- Prose summary for SEO -->
  <p class="chart-summary">
    [1-2 sentence summary of key insights from this visualization]
  </p>
  
  <figure>
    <div class="chart-container" role="img" aria-describedby="[desc-id]">
      <!-- Visual chart renders here -->
    </div>
    <figcaption id="[desc-id]">
      [Chart type] showing [what the chart displays] from [time period].
    </figcaption>
    <!-- Hidden data table here -->
  </figure>
  
  <p class="data-source">Source: [Data Source]</p>
</section>
```

### ARIA Attributes Required
- `aria-labelledby` on `<section>` pointing to heading
- `role="img"` on chart container
- `aria-describedby` on chart container pointing to figcaption
- `aria-hidden="true"` on decorative chart elements

---

## 4. Crawlable KPI Cards

All statistics MUST be in visible, crawlable HTML text.

### ✅ Correct

```html
<div class="kpi-card">
  <div class="kpi-card__icon"><!-- SVG --></div>
  <div class="kpi-card__value">AED 2,911</div>
  <div class="kpi-card__label">Average Price per Sq. Ft</div>
</div>
```

### ❌ Incorrect

```html
<!-- BAD: Data in attributes only, not crawlable -->
<div class="kpi-card" data-value="2911" data-label="avg-price"></div>
```

---

## 5. Text Summaries

Each chart section MUST include a 1-2 sentence prose summary highlighting key insights.

### Examples

**Price Trends:**
> "Villa prices in The Meadows increased 33.5% year-over-year, rising from AED 2,180/sq.ft in Q1 2024 to AED 2,911/sq.ft in H1 2025."

**Transaction Volume:**
> "Transaction volume decreased 15% YoY while prices increased 33.5%, indicating supply constraints in this premium segment."

**Bedroom Comparison:**
> "Five-bedroom villas showed strongest appreciation at 56.3%, while three-bedroom units experienced a 25% decline in transactions."

**Market Composition:**
> "The Meadows recorded 100% ready property transactions with zero off-plan activity in H1 2025."

---

## 6. Complete Example

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>The Meadows Villa Market Report H1 2025 | Your Company Name</title>

  <!-- Schema.org Dataset -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Dataset",
    "name": "The Meadows Villas Resale Market Report H1 2025",
    "description": "Analysis of villa resale transactions in The Meadows, Dubai",
    "temporalCoverage": "2025-01-01/2025-06-30",
    "spatialCoverage": {
      "@type": "Place",
      "name": "The Meadows, Dubai, UAE"
    },
    "publisher": {
      "@type": "Organization",
      "name": "Your Company Name"
    }
  }
  </script>

  <style>
    /* Include component library CSS */

    /* Toggleable Data Table */
    .chart-data-toggle {
      margin-top: 16px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      overflow: hidden;
    }
    .chart-data-toggle summary {
      padding: 12px 16px;
      background: #f5f5f5;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 600;
      color: #01AEE5;
    }
    .chart-data-toggle[open] summary {
      border-bottom: 1px solid #e0e0e0;
    }
    .data-table-container { padding: 16px; }
    .chart-data-table { width: 100%; border-collapse: collapse; }
    .chart-data-table th {
      background: #01AEE5;
      color: white;
      padding: 12px;
      text-align: left;
      text-transform: uppercase;
      font-size: 12px;
    }
    .chart-data-table td { padding: 12px; border-bottom: 1px solid #e0e0e0; }
    .chart-data-table tr:nth-child(even) { background: #f9f9f9; }
    .sr-only {
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
  </style>
</head>
<body>
  <!-- KPIs with crawlable text (NO toggleable table) -->
  <section aria-labelledby="kpi-section">
    <h2 id="kpi-section">Key Performance Indicators</h2>
    <div class="kpi-grid">
      <div class="kpi-card">
        <div class="kpi-card__value">AED 2,911</div>
        <div class="kpi-card__label">Avg. Price per Sq. Ft</div>
      </div>
      <!-- More KPIs... -->
    </div>
  </section>

  <!-- Chart with toggleable data table -->
  <section aria-labelledby="chart-price-trend">
    <h2 id="chart-price-trend">Average Price per Square Foot Trend</h2>

    <p class="chart-summary">
      Villa prices in The Meadows increased 33.5% year-over-year,
      rising from AED 2,180/sq.ft in Q1 2024 to AED 2,911/sq.ft in H1 2025.
    </p>

    <figure class="chart-figure">
      <div class="chart-card" role="img" aria-describedby="price-trend-desc">
        <!-- Visual chart from component library -->
      </div>
      <figcaption id="price-trend-desc">
        Line chart showing quarterly price progression from Q1 2024 through H1 2025.
      </figcaption>

      <!-- Toggleable Data Table -->
      <details class="chart-data-toggle">
        <summary>
          <span class="toggle-icon"></span>
          View Data Table
        </summary>
        <div class="data-table-container">
          <table class="chart-data-table">
            <caption class="sr-only">Average Price per Sq. Ft - The Meadows Villas</caption>
            <thead>
              <tr>
                <th scope="col">Period</th>
                <th scope="col">Avg. Price (AED/SQ.FT)</th>
                <th scope="col">Transactions</th>
                <th scope="col">QoQ Change</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Q1 2024</td><td>AED 2,180</td><td>42</td><td>-</td></tr>
              <tr><td>Q2 2024</td><td>AED 2,340</td><td>38</td><td>+7.3%</td></tr>
              <tr><td>Q3 2024</td><td>AED 2,520</td><td>45</td><td>+7.7%</td></tr>
              <tr><td>Q4 2024</td><td>AED 2,710</td><td>41</td><td>+7.5%</td></tr>
              <tr><td>H1 2025</td><td>AED 2,911</td><td>78</td><td>+7.4%</td></tr>
            </tbody>
          </table>
        </div>
      </details>
    </figure>

    <p class="data-source">Source: Property Monitor, Your Company Name Analysis</p>
  </section>
</body>
</html>
```

---

## Checklist

Before finalizing any report, verify:

- [ ] Every chart/graph has a toggleable `<details class="chart-data-toggle">` with `<table>` containing all data points
- [ ] Time-series charts have extended columns (Transactions, QoQ Change) in their dataTables
- [ ] Schema.org Dataset JSON-LD is in `<head>`
- [ ] All sections use `aria-labelledby` linking to headings
- [ ] Chart containers have `role="img"` and `aria-describedby`
- [ ] Every visualization has a prose summary paragraph
- [ ] All KPI values are in visible HTML text, not data attributes
- [ ] Data source citations are included as `<p class="data-source">`
- [ ] `.chart-data-toggle` and `.chart-data-table` CSS is included
- [ ] KPIs and text sections do NOT have toggleable tables (only charts/graphs)
