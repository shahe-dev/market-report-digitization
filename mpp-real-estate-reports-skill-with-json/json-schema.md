# JSON Schema Reference

Standardized JSON output format for MPP Real Estate Resale Reports. Every HTML report must have a companion JSON file with this structure.

## Document Root

```json
{
  "metadata": { ... },
  "schemaOrg": { ... },
  "rawTextPassages": { ... },
  "visualDescriptions": { ... },
  "executiveSummary": "string",
  "keyPerformance": { ... },
  "priceInsights": [ ... ],
  "rentalMetrics": { ... },
  "contactDistribution": { ... },
  "marketInsights": "string",
  "totalTransactions": "string",
  "grossRentYield": "string",
  "marketDynamicsAnalysisParagraphs": [ ... ],
  "investorConsiderations": { ... },
  "keyDifferences": { ... },
  "trendOverTimeGraph": { ... },
  "multiSeriesComparisonGraph": { ... },
  "distributionByCategoryGraph": { ... },
  "periodOverPeriodComparisonGraph": { ... },
  "topEntitiesByVolumeGraph": { ... },
  "compositionSplitByEntityGraph": { ... },
  "stackedBarGraph": { ... },
  "stackedBarDualGraph": { ... },
  "enhanced": { ... }
}
```

**Two-Stage Pipeline:**
- **Stage 1 (Extraction)**: Populates all fields except `enhanced` and `schemaOrg`
- **Stage 2 (Content Enhancement)**: Populates `enhanced` object AND `schemaOrg` object

---

## 1. Metadata Object (Required for SEO)

```json
{
  "metadata": {
    "community": "string (e.g., 'Business Bay')",
    "propertyType": "Apartments | Villas | Townhouses | Mixed",
    "period": "string (e.g., 'H1 2024')",
    "periodRange": "string (e.g., '1st January - 30th June')",
    "canonicalUrl": "string (full URL from CSV)",
    "dataSource": "string (e.g., 'Property Monitor')",
    "dataAccessDate": "string (YYYY-MM-DD)"
  }
}
```

Used to generate Schema.org JSON-LD in HTML `<head>`.

---

## 1a. Schema.org Object (Required for SEO)

The `schemaOrg` object contains structured data for search engine rich results. This MUST be generated during Stage 2 (Content Enhancement) and injected as JSON-LD in the HTML `<head>`.

```json
{
  "schemaOrg": {
    "@context": "https://schema.org",
    "@type": "Dataset",
    "name": "string (report title, e.g., 'Business Bay Apartments Resale Market Report H1 2025')",
    "description": "string (1-2 sentence summary of the data)",
    "temporalCoverage": "string (ISO format, e.g., '2025-01-01/2025-06-30')",
    "spatialCoverage": {
      "@type": "Place",
      "name": "string (e.g., 'Business Bay, Dubai, UAE')"
    },
    "publisher": {
      "@type": "Organization",
      "name": "Your Company Name",
      "url": "https://your-company.com"
    },
    "datePublished": "string (ISO date, e.g., '2025-07-15')",
    "license": "https://your-company.com/terms"
  }
}
```

### Field Generation Rules

| Field | Source | Example |
|-------|--------|---------|
| `name` | `metadata.community` + `metadata.propertyType` + `metadata.period` | "Business Bay Apartments Resale Market Report H1 2025" |
| `description` | Generated from `enhanced.executiveSummaryEnhanced` (first sentence) | "Analysis of 3,745 apartment resale transactions in Business Bay, Dubai including price trends and bedroom configuration breakdown" |
| `temporalCoverage` | Derived from `metadata.period` | "2025-01-01/2025-06-30" for H1, "2025-07-01/2025-12-31" for H2 |
| `spatialCoverage.name` | `metadata.community` + ", Dubai, UAE" | "Business Bay, Dubai, UAE" |
| `datePublished` | Current date or `metadata.dataAccessDate` | "2025-07-15" |

### Period to Date Mapping

| Period | temporalCoverage |
|--------|------------------|
| H1 2024 | 2024-01-01/2024-06-30 |
| H2 2024 | 2024-07-01/2024-12-31 |
| Q1 2024 | 2024-01-01/2024-03-31 |
| Q2 2024 | 2024-04-01/2024-06-30 |
| Q3 2024 | 2024-07-01/2024-09-30 |
| Q4 2024 | 2024-10-01/2024-12-31 |
| 2024 (Full Year) | 2024-01-01/2024-12-31 |

See `seo-accessibility.md` Section 2 for complete Schema.org requirements.

---

## 1b. Raw Text Passages (Stage 1 Extraction)

```json
{
  "rawTextPassages": {
    "headerText": "string (verbatim title/header from PDF)",
    "insightText": "string (callout boxes, highlighted insights from PDF)",
    "footnotes": "string (methodology notes, disclaimers, footer text)",
    "dataLabels": ["string (verbatim labels from charts providing context)"]
  }
}
```

Captures original text for content enhancement. Preserves source wording.

---

## 1c. Visual Descriptions (Stage 1 Extraction)

```json
{
  "visualDescriptions": {
    "chartTypes": ["string (e.g., 'line chart showing price trend')"],
    "colorCoding": "string (color schemes used in visualizations)",
    "highlightedMetrics": ["string (visually emphasized values)"],
    "layoutNotes": "string (general layout description)"
  }
}
```

Documents visual elements for content generation context.

---

## 2. Executive Summary

```json
{
  "executiveSummary": "string (1-3 sentences summarizing key findings)",
  "executiveSummaryId": "exec-summary",
  "executiveSummaryComponentId": "executive-summary-card",
  "executiveSummaryHeading": "Executive Summary",
  "executiveSummaryDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 3. Key Performance Indicators

```json
{
  "keyPerformance": {
    "pricePerSqFt": "string (e.g., 'AED 2,911')",
    "priceGrowth": "string (percentage, e.g., '33.5')",
    "resaleTransactions": "string (e.g., '78')",
    "totalResaleValue": "string (e.g., 'AED 918.2M')"
  },
  "keyPerformanceId": "kpi-strip",
  "keyPerformanceComponentId": "kpi-strip",
  "keyPerformanceHeading": "Key Performance Indicators",
  "keyPerformanceDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 4. Price Insights Table

```json
{
  "priceInsights": [
    {
      "bedrooms": "string (e.g., '3 Bedroom')",
      "averagePrice": "string (e.g., 'AED 8,024,889')",
      "transactions": "string (e.g., '15')",
      "yoyChange": "string (percentage, e.g., '-25')"
    }
  ],
  "priceInsightsId": "price-insights-table",
  "priceInsightsComponentId": "data-table",
  "priceInsightsHeading": "Price Data Insights",
  "priceInsightsFigcaption": "Table showing average prices and transaction volume by bedroom configuration.",
  "priceInsightsDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 5. Rental Metrics

```json
{
  "rentalMetrics": {
    "rentPerFt": "string (e.g., 'AED 102')",
    "yoyGrowth": "string (percentage, e.g., '10.4')"
  },
  "rentalMetricsId": "rental-metrics",
  "rentalMetricsComponentId": "indicators-block",
  "rentalMetricsHeading": "Rental Market Metrics",
  "rentalMetricsDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 6. Contract Distribution

```json
{
  "contactDistribution": {
    "newContracts": "string (percentage, e.g., '41.6')",
    "renewalContracts": "string (percentage, e.g., '58.4')"
  },
  "contactDistributionId": "contract-distribution",
  "contactDistributionComponentId": "comparison-cards",
  "contactDistributionHeading": "Contract Distribution",
  "contactDistributionDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 7. Market Insights

```json
{
  "marketInsights": "string (key insight paragraph)",
  "marketInsightsId": "metro-insights",
  "marketInsightsComponentId": "market-insight-block",
  "marketInsightsHeading": "Market Highlights",
  "marketInsightsDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 8. Additional Metrics

```json
{
  "totalTransactions": "string (e.g., '178')",
  "grossRentYield": "string (percentage, e.g., '5.3')"
}
```

---

## 9. Market Dynamics Analysis

```json
{
  "marketDynamicsAnalysisParagraphs": [
    "string (paragraph 1)",
    "string (paragraph 2)",
    "string (paragraph 3)"
  ],
  "marketDynamicsId": "market-dynamics",
  "marketDynamicsComponentId": "market-dynamics-block",
  "marketDynamicsHeading": "Market Dynamics Analysis",
  "marketDynamicsDataSource": "Property Monitor, Your Company Name Analysis"
}
```

---

## 10. Investor Considerations

```json
{
  "investorConsiderations": {
    "entryTiming": "string",
    "configurationSelection": "string",
    "rentalStrategy": "string",
    "holdingPeriod": "string",
    "exitFlexibility": "string"
  },
  "investorConsiderationsId": "investor-considerations",
  "investorConsiderationsComponentId": "investor-considerations-grid",
  "investorConsiderationsHeading": "Investor Considerations",
  "investorConsiderationsDataSource": "Your Company Name Analysis"
}
```

---

## 11. Key Differences Table

```json
{
  "keyDifferences": {
    "headings": ["string", "string", "string"],
    "body": [
      ["string", "string", "string"],
      ["string", "string", "string"]
    ]
  },
  "keyDifferencesId": "key-differences",
  "keyDifferencesComponentId": "comparison-table",
  "keyDifferencesHeading": "Key Differences Summary",
  "keyDifferencesFigcaption": "Table comparing key metrics between areas or periods.",
  "keyDifferencesDataSource": "string (defaults to metadata.dataSource)"
}
```

---

## 12. Graph Components

All graphs follow this pattern:

```json
{
  "graphName": {
    "id": "string (unique identifier for ARIA)",
    "componentId": "string (REQUIRED - component ID from chart-component-reference.md)",
    "titleBlack": "string (main title)",
    "titleBlue": "string (subtitle/context)",
    "titleDelimeter": "string (e.g., '-' or ':')",
    "summary": "string (prose description for SEO)",
    "figcaption": "string (accessibility description for aria-describedby)",
    "dataSource": "string (source citation, defaults to metadata.dataSource)",
    "points": [ ... ],
    "dataTable": {
      "caption": "string",
      "headers": ["string", "string", ...],
      "rows": [["string", "string", ...], ...]
    }
  }
}
```

### componentId Field (CRITICAL FOR CMS INTEGRATION)

The `componentId` field tells developers exactly which HTML component to render for this data. This is the **primary key for CMS mapping**.

**Valid componentId values:**
| componentId | HTML Component | CSS Container Class |
|-------------|----------------|---------------------|
| `area-line` | Area Line Chart | `.chart-card` |
| `multi-line` | Multi-Line Chart | `.chart-card` |
| `column` | Column Chart (vertical bars) | `.chart-card` |
| `grouped-column` | Grouped Column Chart | `.chart-card` |
| `stacked-column` | Stacked Column Chart | `.chart-card` |
| `bar` | Bar Chart (horizontal) | `.horizontal-chart` |
| `data-table` | Data Table | `.price-data-insights` |
| `comparison-cards` | Comparison Cards (binary ratio) | `.comparison-metrics` |
| `stacked-bar` | Stacked Bar (horizontal part-to-whole) | `.stacked-bar-section` |
| `stacked-bar-dual` | Stacked Bar Dual (two related splits) | `.stacked-bar-section` |

**Selection is determined by data pattern, not graph name.** For example, `distributionByCategoryGraph` may have `componentId: "comparison-cards"` if the data is a binary ratio, or `componentId: "column"` if it's a multi-category distribution.

See `prompts/chart-component-reference.md` for complete selection rules.

### dataTable Structure

The `dataTable` provides companion data for SEO crawlability. Tables render inside a toggleable `<details>` element with "View Data Table" button.

**Column Flexibility:**
- `headers`: Array of 2-6 column headers
- `rows`: Each row must have same number of elements as headers
- First column typically Period (time-series) or Category (distribution)

**Extended Columns for Time-Series Charts:**

Time-series graphs (`trendOverTimeGraph`, `transactionsOverTimeGraph`, `rentalPriceOverTimeGraph`) support extended columns beyond the chart data:

| Column | Source | Description |
|--------|--------|-------------|
| Period | `points[].xAxis` | Time period from chart |
| Value | `points[].yAxis` | Primary metric (price, transactions, etc.) |
| Transactions | Additional data | Volume/count for that period (if available) |
| Change | Calculated | QoQ/YoY percentage change (e.g., "+7.3%", "-2.1%") |

**Column Structure by Graph Type:**

| Graph Type | Columns | Extended? |
|------------|---------|-----------|
| `trendOverTimeGraph` | Period, Value, Transactions, Change | YES |
| `transactionsOverTimeGraph` | Period, Transactions, Value, Change | YES |
| `rentalPriceOverTimeGraph` | Period, Rental Price, Change | YES |
| `multiSeriesComparisonGraph` | Period, Series1, Series2, ... | NO |
| `distributionByCategoryGraph` | Category, Value | NO |
| `periodOverPeriodComparisonGraph` | Category, Period1, Period2 | NO |
| `topEntitiesByVolumeGraph` | Rank, Entity, Value | NO |
| `compositionSplitByEntityGraph` | Entity, Segment1%, Segment2% | NO |

**Change Column Formatting:**
- Format as percentage with +/- sign: "+7.3%", "-2.1%"
- Use "-" for first period (no baseline to compare)

### Figcaption Format

The `figcaption` field provides the text for the `<figcaption>` element and `aria-describedby` reference. Format:

```
"[Chart type] showing [what the chart displays] from [time period]."
```

**Chart type mapping:**
| Graph Object | Chart Type Text |
|--------------|-----------------|
| `trendOverTimeGraph` | "Line chart" |
| `transactionsOverTimeGraph` | "Line chart" |
| `rentalPriceOverTimeGraph` | "Line chart" |
| `multiSeriesComparisonGraph` | "Multi-line chart" |
| `distributionByCategoryGraph` | "Bar chart" |
| `periodOverPeriodComparisonGraph` | "Grouped bar chart" |
| `topEntitiesByVolumeGraph` | "Horizontal bar chart" |
| `compositionSplitByEntityGraph` | "Stacked bar chart" |

### 12.1 Trend Over Time Graph (Single Line Chart)

```json
{
  "trendOverTimeGraph": {
    "id": "price-trend",
    "componentId": "area-line",
    "titleBlack": "Average Price per Sq. Ft",
    "titleBlue": "The Meadows Villas",
    "titleDelimeter": "-",
    "summary": "Villa prices increased 33.5% year-over-year, rising from AED 2,180/sq.ft in Q1 2024 to AED 2,911/sq.ft in H1 2025",
    "figcaption": "Line chart showing quarterly price per square foot from Q1 2024 through H1 2025.",
    "dataSource": "Property Monitor",
    "points": [
      { "xAxis": "Q1 2024", "yAxis": "2180" },
      { "xAxis": "Q2 2024", "yAxis": "2340" },
      { "xAxis": "Q3 2024", "yAxis": "2520" },
      { "xAxis": "Q4 2024", "yAxis": "2710" },
      { "xAxis": "H1 2025", "yAxis": "2911" }
    ],
    "dataTable": {
      "caption": "Average Price per Sq. Ft - The Meadows Villas",
      "headers": ["Period", "Avg. Price (AED/SQ.FT)", "Transactions", "QoQ Change"],
      "rows": [
        ["Q1 2024", "AED 2,180", "42", "-"],
        ["Q2 2024", "AED 2,340", "38", "+7.3%"],
        ["Q3 2024", "AED 2,520", "45", "+7.7%"],
        ["Q4 2024", "AED 2,710", "41", "+7.5%"],
        ["H1 2025", "AED 2,911", "78", "+7.4%"]
      ]
    }
  }
}
```

**Note:** Time-series charts support extended columns (Transactions, QoQ Change) beyond the chart data points. See "dataTable Structure" above for column guidelines.

### 12.2 Multi-Series Comparison Graph (Multi-Line Chart)

```json
{
  "multiSeriesComparisonGraph": {
    "id": "multi-series-comparison",
    "componentId": "multi-line",
    "titleBlack": "Price Trend Comparison",
    "titleBlue": "Multiple Communities",
    "titleDelimeter": "-",
    "summary": "Comparison of price trends across communities",
    "figcaption": "Multi-line chart comparing price trends across multiple communities from Q1 2024 to Q2 2024.",
    "dataSource": "Property Monitor",
    "graphs": [
      {
        "title": "Community Name",
        "color": "#57CE9F",
        "points": [
          { "xAxis": "Q1 2024", "yAxis": "1750" },
          { "xAxis": "Q2 2024", "yAxis": "2000" }
        ]
      }
    ],
    "dataTable": {
      "caption": "Price Trend Comparison - Multiple Communities",
      "headers": ["Period", "Community 1", "Community 2"],
      "rows": [
        ["Q1 2024", "1,750", "1,800"],
        ["Q2 2024", "2,000", "2,100"]
      ]
    }
  }
}
```

### 12.3 Distribution By Category Graph (Vertical Bar Chart)

**Note:** The `componentId` for this graph type varies based on data pattern:
- Binary ratio (2 categories summing to 100%): use `"componentId": "comparison-cards"`
- Multi-category distribution (3-7 categories): use `"componentId": "column"`

```json
{
  "distributionByCategoryGraph": {
    "id": "distribution-category",
    "componentId": "column",
    "titleBlack": "Transaction Volume by Bedroom Type",
    "titleBlue": "Q3 2025",
    "titleDelimeter": "-",
    "summary": "Distribution of transactions across bedroom configurations",
    "figcaption": "Bar chart showing transaction volume by bedroom type for Q3 2025.",
    "dataSource": "Property Monitor",
    "points": [
      { "xAxis": "Studio", "yAxis": "10" },
      { "xAxis": "1 Bed", "yAxis": "39" },
      { "xAxis": "2 Bed", "yAxis": "73" }
    ],
    "dataTable": {
      "caption": "Transaction Volume by Bedroom Type - Q3 2025",
      "headers": ["Bedroom Type", "Transactions"],
      "rows": [
        ["Studio", "10"],
        ["1 Bed", "39"],
        ["2 Bed", "73"]
      ]
    }
  }
}
```

### 12.4 Period Over Period Comparison Graph (Multi-Bar Chart)

```json
{
  "periodOverPeriodComparisonGraph": {
    "id": "period-comparison",
    "componentId": "grouped-column",
    "titleBlack": "Average Price Comparison",
    "titleBlue": "2024 vs 2025",
    "titleDelimeter": ":",
    "summary": "Year-over-year price comparison by bedroom type",
    "figcaption": "Grouped bar chart comparing average prices between Q3 2024 and Q3 2025 by bedroom type.",
    "dataSource": "Property Monitor",
    "item1": "Q3 2024",
    "item2": "Q3 2025",
    "units": "AED",
    "points": [
      { "title": "Studio", "itemValue1": "1600000", "itemValue2": "1600000" },
      { "title": "1 Bed", "itemValue1": "1250000", "itemValue2": "1900000" }
    ],
    "dataTable": {
      "caption": "Average Price Comparison - 2024 vs 2025",
      "headers": ["Bedroom Type", "Q3 2024", "Q3 2025"],
      "rows": [
        ["Studio", "AED 1,600,000", "AED 1,600,000"],
        ["1 Bed", "AED 1,250,000", "AED 1,900,000"]
      ]
    }
  }
}
```

### 12.5 Top Entities By Volume Graph (Horizontal Bar Chart)

```json
{
  "topEntitiesByVolumeGraph": {
    "id": "top-entities",
    "componentId": "bar",
    "titleBlack": "Top 5 Communities by Transaction Volume",
    "titleBlue": "Q3 2025",
    "titleDelimeter": "-",
    "summary": "Ranking of communities by transaction count",
    "figcaption": "Horizontal bar chart ranking top 5 communities by transaction volume for Q3 2025.",
    "dataSource": "Property Monitor",
    "points": [
      { "title": "Sobha Hartland", "value": "293" },
      { "title": "Palm Jumeirah Apartments", "value": "189" }
    ],
    "dataTable": {
      "caption": "Top 5 Communities by Transaction Volume - Q3 2025",
      "headers": ["Rank", "Community", "Transactions"],
      "rows": [
        ["1", "Sobha Hartland", "293"],
        ["2", "Palm Jumeirah Apartments", "189"]
      ]
    }
  }
}
```

### 12.6 Composition Split By Entity Graph (Stacked Bar Chart)

**Note:** The `componentId` for this graph type varies based on data pattern:
- Single entity with binary split: use `"componentId": "comparison-cards"`
- Multiple entities with composition breakdown: use `"componentId": "stacked-column"`

```json
{
  "compositionSplitByEntityGraph": {
    "id": "composition-split",
    "componentId": "stacked-column",
    "titleBlack": "Transaction Composition: Off-plan vs Ready",
    "titleBlue": "Multiple Communities",
    "titleDelimeter": "-",
    "summary": "Breakdown of off-plan versus ready property transactions by community",
    "figcaption": "Stacked bar chart showing off-plan vs ready property transaction composition across communities.",
    "dataSource": "Property Monitor",
    "item1": "Off-plan",
    "item2": "Ready",
    "points": [
      { "title": "Mudon", "item1": "26", "item2": "74" },
      { "title": "The Meadows", "item1": "50", "item2": "50" }
    ],
    "dataTable": {
      "caption": "Transaction Composition - Off-plan vs Ready",
      "headers": ["Community", "Off-plan %", "Ready %"],
      "rows": [
        ["Mudon", "26%", "74%"],
        ["The Meadows", "50%", "50%"]
      ]
    }
  }
}
```

### 12.7 Stacked Bar Graph (Horizontal Part-to-Whole)

Use `stacked-bar` when presenting a binary split where visual proportion is desired.

**Selection Conditions:**
- Exactly 2 categories (off-plan/ready, new/renewal)
- Neither category exceeds 90% (if >90%, use `indicators-block` instead)
- Visual proportion adds value over simple text display

**Variants:**
- `stacked-bar`: Single horizontal bar showing binary split
- `stacked-bar-dual`: Two related bars side-by-side (e.g., transactions AND value)

```json
{
  "stackedBarGraph": {
    "id": "completion-status",
    "componentId": "stacked-bar",
    "titleBlack": "Transactions by Completion Status",
    "titleBlue": "",
    "titleDelimeter": "",
    "summary": "Off-plan transactions dominated at 69.3% of total volume, with ready properties comprising 30.7%",
    "figcaption": "Horizontal bar showing transaction split: 69.3% off-plan and 30.7% ready.",
    "dataSource": "Property Monitor",
    "cardTitle": "Transaction Distribution",
    "segment1": {
      "label": "Off-plan",
      "value": "69.3",
      "displayValue": "69.3%"
    },
    "segment2": {
      "label": "Ready",
      "value": "30.7",
      "displayValue": "30.7%"
    },
    "dataTable": {
      "caption": "Transactions by Completion Status",
      "headers": ["Completion Status", "Percentage"],
      "rows": [
        ["Off-plan", "69.3%"],
        ["Ready", "30.7%"]
      ]
    }
  }
}
```

**Dual Variant (stacked-bar-dual):**

```json
{
  "stackedBarDualGraph": {
    "id": "completion-status-dual",
    "componentId": "stacked-bar-dual",
    "titleBlack": "Completion Status",
    "titleBlue": "Transactions vs Value",
    "titleDelimeter": ":",
    "summary": "Off-plan properties accounted for 69.3% of transactions and 71.9% of value",
    "figcaption": "Two horizontal bars comparing transaction and value splits by completion status.",
    "dataSource": "Property Monitor",
    "bar1": {
      "cardTitle": "Transactions (665 Total)",
      "segment1": { "label": "Off-plan", "value": "69.3", "displayValue": "461" },
      "segment2": { "label": "Ready", "value": "30.7", "displayValue": "204" }
    },
    "bar2": {
      "cardTitle": "Value (AED 2.14B Total)",
      "segment1": { "label": "Off-plan", "value": "71.9", "displayValue": "AED 1.54B" },
      "segment2": { "label": "Ready", "value": "28.1", "displayValue": "AED 0.60B" }
    },
    "dataTable": {
      "caption": "Completion Status - Transactions vs Value",
      "headers": ["Metric", "Off-plan", "Ready", "Total"],
      "rows": [
        ["Transactions", "461 (69.3%)", "204 (30.7%)", "665"],
        ["Value", "AED 1.54B (71.9%)", "AED 0.60B (28.1%)", "AED 2.14B"]
      ]
    }
  }
}
```

**Note:** `value` contains the numeric percentage for calculating bar widths (flex-basis). `displayValue` contains the formatted string for legend display (can be percentage OR absolute value).

---

## 13. Enhanced Content (Stage 2 Output)

Generated by the Content Enhancement stage. These fields contain SEO-optimized, analyst-quality content.

### 13.1 Enhanced Object Structure

```json
{
  "enhanced": {
    "executiveSummaryEnhanced": "string (2-3 sentences, leads with key metric)",

    "chartSummaries": {
      "trendOverTime": "string (1-2 sentences, references line chart)",
      "distributionByCategory": "string (references bar chart)",
      "periodOverPeriodComparison": "string (references multi-bar)",
      "topEntitiesByVolume": "string (references horizontal bars)",
      "compositionSplit": "string (references stacked bars)"
    },

    "marketDynamicsEnhanced": {
      "supplyDemand": "string (paragraph on inventory/demand)",
      "priceDrivers": "string (paragraph on price factors)",
      "investmentContext": "string (paragraph on yields/returns)"
    },

    "marketInsightsEnhanced": "string (2-3 sentences, key callout)",

    "investorConsiderationsEnhanced": {
      "entryTiming": "string (1-2 sentences)",
      "configurationSelection": "string (1-2 sentences)",
      "rentalStrategy": "string (1-2 sentences)",
      "holdingPeriod": "string (1-2 sentences)",
      "exitFlexibility": "string (1-2 sentences)"
    },

    "seoMetaContent": {
      "titleTag": "string (max 60 chars)",
      "metaDescription": "string (max 155 chars)",
      "h1Primary": "string (max 70 chars)",
      "h1Variations": ["string", "string"]
    },

    "componentSelections": {
      "kpiDisplay": "kpi-strip | indicators-block",
      "priceTrend": "area-line | multi-line",
      "volumeDistribution": "column | grouped-column",
      "periodComparison": "grouped-column | comparison-cards",
      "rankings": "bar | data-table",
      "composition": "stacked-column",
      "binaryRatio": "stacked-bar | comparison-cards | indicators-block",
      "binaryRatioDual": "stacked-bar-dual",
      "priceBreakdown": "data-table | comparison-table",
      "keyInsight": "market-insight-block",
      "analysis": "market-dynamics-block",
      "considerations": "investor-considerations-grid",
      "rentalMetrics": "indicators-block | kpi-strip"
    },

    "sectionOrder": [
      "executiveSummary",
      "kpiStrip",
      "priceTrendChart",
      "distributionChart",
      "priceInsightsTable",
      "rankingChart",
      "rentalMetrics",
      "marketInsight",
      "marketDynamics",
      "investorConsiderations",
      "sourceCitation"
    ],

    "narrativeStyle": {
      "priceTrend": "trajectory | comparative | insight-first | data-point",
      "distribution": "trajectory | comparative | insight-first | data-point",
      "ranking": "trajectory | comparative | insight-first | data-point",
      "composition": "trajectory | comparative | insight-first | data-point"
    },

    "conditionalSections": {
      "includeRentalMetrics": "boolean",
      "includeKeyDifferences": "boolean",
      "includeCompositionChart": "boolean",
      "includeRankingChart": "boolean",
      "includeMultilineChart": "boolean",
      "includePeriodComparison": "boolean",
      "includeComparisonMetricsCards": "boolean"
    },

    "componentSelectionRationale": {
      "kpiDisplay": "string (why this component was chosen)",
      "priceTrend": "string (why this visualization was chosen)",
      "volumeDistribution": "string",
      "periodComparison": "string"
    }
  }
}
```

### 13.2 Component IDs Reference

| Component ID | Standard Name | Category | CSS Class |
|--------------|---------------|----------|-----------|
| `kpi-strip` | KPI Strip | Metrics | `.kpi-card` |
| `indicators-block` | Indicators Block | Metrics | `.indicator-card` |
| `comparison-cards` | Comparison Cards | Metrics | `.metrics-card` |
| `area-line` | Area Line Chart | Charts | `.line-chart` |
| `multi-line` | Multi-Line Chart | Charts | `.line-chart` |
| `column` | Column Chart | Charts | `.bar` |
| `grouped-column` | Grouped Column Chart | Charts | `.bar-group` |
| `stacked-column` | Stacked Column Chart | Charts | `.stacked-bar` |
| `bar` | Bar Chart | Charts | `.horizontal-bar` |
| `data-table` | Data Table | Tables | `.insights-table` |
| `comparison-table` | Comparison Table | Tables | `.differences-table` |
| `market-insight-block` | Market Insight Block | Content | - |
| `executive-summary-card` | Executive Summary Card | Content | - |
| `market-dynamics-block` | Market Dynamics Block | Content | - |
| `investor-considerations-grid` | Investor Considerations Grid | Content | - |
| `source-citation` | Source Citation | Footer | - |

**Reference**: See `prompts/chart-component-reference.md` for complete selection rules and CSS class mappings.

### 13.3 Variability Fields

These fields enable report diversity while maintaining accuracy:

| Field | Purpose | Example Values |
|-------|---------|----------------|
| `sectionOrder` | Controls section sequence in HTML | Array of section IDs |
| `narrativeStyle` | Determines prose style per chart | "trajectory", "comparative", "insight-first", "data-point" |
| `conditionalSections` | Includes/excludes sections based on data | Boolean flags |
| `componentSelectionRationale` | Documents why each component was chosen | Prose explanations |

**sectionOrder** can be reordered based on data emphasis (e.g., move rental metrics earlier for yield-focused reports).

**narrativeStyle** values:
- `trajectory`: "The line traces a steady upward trajectory from..."
- `comparative`: "Compared to H1 2024, prices have risen..."
- `insight-first`: "The 9.4% appreciation reflects..."
- `data-point`: "Starting at AED 1,980 in January..."

See `prompts/content-enhancement-prompt.md` for detailed selection criteria.

### 13.4 Quality Standards

Enhanced content must:
- Use specific numbers with AED formatting
- Include YoY comparisons where applicable
- Integrate SEO keywords naturally
- Avoid promotional language or CTAs
- Provide genuine analytical value
- **Chart summaries must reference their selected visualization type**
- **componentSelections must include all data types present**

See `prompts/content-enhancement-prompt.md` for detailed writing guidelines and Component Selection Matrix.

---

## Validation Rules

### Stage 1 (Extraction)
1. **metadata**: Required. Must include community, propertyType, period, canonicalUrl
2. **rawTextPassages**: Required. headerText must be non-empty
3. **visualDescriptions**: Required. chartTypes array must list all visualizations
4. **IDs**: Every section/graph must have a unique ID for ARIA attributes
5. **componentId**: Required on ALL renderable sections and graphs. Must be a valid ID from chart-component-reference.md
6. **dataTable**: Required on all graphs for SEO crawlability
7. **summary**: Required on all graphs for accessibility
8. **String values**: All numeric values stored as strings for consistent formatting

### componentId Validation
- **Required fields**: Every section with `*ComponentId` suffix must be populated
- **Valid values**: Must exactly match one of the component IDs in chart-component-reference.md
- **Consistency**: The componentId must match the data pattern (e.g., binary ratio = `comparison-cards`, segment metrics = `data-table`)

### Stage 2 (Content Enhancement + SEO Generation)
8. **schemaOrg**: Required. Must include all fields per Section 1a
9. **schemaOrg.name**: Must match format "[Community] [PropertyType] Resale Market Report [Period]"
10. **schemaOrg.temporalCoverage**: Must be valid ISO date range matching metadata.period
11. **schemaOrg.description**: Must be derived from executiveSummaryEnhanced (1-2 sentences)
12. **enhanced.executiveSummaryEnhanced**: Must lead with most impactful metric
13. **enhanced.chartSummaries**: Each summary must explain trend AND reference visualization type
14. **enhanced.marketDynamicsEnhanced**: All three paragraphs required
15. **enhanced.seoMetaContent**: titleTag max 60 chars, metaDescription max 155 chars
16. **enhanced.componentSelections**: Must include all data types present in extraction
17. **Component coherence**: Chart summaries must match selected visualization types
18. **No promotional content**: enhanced fields must not contain CTAs or sales language

### SEO/Accessibility Validation (Pre-HTML Generation)
19. **dataTable objects**: Every graph must have dataTable with caption, headers, rows
20. **dataTable.rows**: Must contain all data from graph points array, plus optional extended columns
21. **schemaOrg completeness**: Validate against seo-accessibility.md Section 2 requirements
22. **ID uniqueness**: All IDs must be unique within the document for ARIA references

### Accessibility Field Requirements
23. **figcaption**: Required on all graphs and tables. Format: "[Chart/Table type] showing [description] from [period]."
24. **figcaption prefix**: Must begin with component type (Line chart, Bar chart, Horizontal bar chart, Stacked bar chart, Table, etc.)
25. **dataSource**: Optional on graphs/sections. Defaults to `metadata.dataSource` if omitted. Explicitly required when source differs from default.
26. **Heading fields**: Required on all non-graph sections (`*Heading`). Must be unique across the document.
27. **Heading consistency**: Section heading fields must match ARIA `aria-labelledby` target text in HTML

### Data Table Extended Columns
28. **dataTable.headers**: Array of 2-6 column headers. First column typically Period/Category.
29. **dataTable.rows**: Each row must have same number of elements as headers array.
30. **Change columns**: Format as percentage with +/- sign (e.g., "+7.3%", "-2.1%"). Use "-" for first period with no baseline.
31. **Extended columns**: Only time-series graphs support extended columns (Transactions, Change). Distribution/ranking charts use standard 2-3 columns.

---

## File Naming Convention

For a report at URL `https://your-company.com/resale-reports/business-bay-apartments-h1-2024/`:
- JSON: `business-bay-apartments-h1-2024.json`
- HTML: `business-bay-apartments-h1-2024.html`

---

## Complete Example

See `sample-input-output/1.sample-input-pdf-output-html/resale_report_data_json_scheme.json` for a complete working example.

---

*Version 1.3 - January 2026*
*v1.0: Initial JSON schema specification*
*v1.1: Standardized component IDs per chart-component-reference.md*
*v1.2: Added componentId field to all renderable sections and graphs for CMS integration*
*v1.3: Added stackedBarGraph and stackedBarDualGraph for horizontal part-to-whole visualization*
