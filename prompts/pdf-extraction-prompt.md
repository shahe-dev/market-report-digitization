# PDF Data Extraction Prompt

Use this prompt when reading PDF reports to extract structured data in the extended schema format.

---

## System Context

You are extracting data from a Dubai real estate resale report infographic. The PDF is a single-page visual document containing KPIs, charts, tables, and text. Extract ALL visible data into the JSON structure below, which includes SEO-required fields (metadata, IDs, dataTables).

---

## Extraction Instructions

1. **Read the entire PDF carefully** - scan all sections from top to bottom
2. **Extract exact values** - copy numbers exactly as shown (e.g., "AED 1,744" not "1744")
3. **Capture percentage changes** - note the direction (+/-) and comparison period (YoY, MoM)
4. **Extract chart data points** - read values from chart labels, axis markers, and data labels
5. **Generate IDs** - create URL-safe IDs for each section (e.g., "price-trend", "kpi-strip")
6. **Build dataTables** - convert chart points arrays into table format for SEO

---

## Output JSON Structure (Extended Schema)

```json
{
  "metadata": {
    "community": "string (e.g., 'Business Bay')",
    "propertyType": "Apartments | Villas | Townhouses | Mixed",
    "period": "string (e.g., 'H1 2024')",
    "periodRange": "string (e.g., '1st January - 30th June')",
    "canonicalUrl": "string (from CSV lookup - leave empty if unknown)",
    "dataSource": "string (e.g., 'Property Monitor')",
    "dataAccessDate": "string (from PDF footer, e.g., '2024-07-04')"
  },

  "rawTextPassages": {
    "headerText": "string (verbatim title/header text from PDF)",
    "insightText": "string (any callout boxes, highlighted insights, or commentary from PDF)",
    "footnotes": "string (methodology notes, disclaimers, or footer text)",
    "dataLabels": ["string (verbatim labels from charts/tables that provide context)"]
  },

  "visualDescriptions": {
    "chartTypes": ["string (describe each chart: 'line chart showing price trend', 'bar chart showing transactions by bedroom')"],
    "colorCoding": "string (note any color schemes: 'blue for current period, gray for previous')",
    "highlightedMetrics": ["string (any circled, bolded, or visually emphasized values)"],
    "layoutNotes": "string (general layout: 'KPIs at top, charts in middle, table at bottom')"
  },

  "executiveSummary": "string (1-3 sentences from PDF intro text)",
  "executiveSummaryId": "exec-summary",

  "keyPerformance": {
    "pricePerSqFt": "string (e.g., 'AED 1,744')",
    "priceGrowth": "string (percentage, e.g., '12')",
    "resaleTransactions": "string (e.g., '2,023')",
    "totalResaleValue": "string (e.g., 'AED 3.292 Bn')"
  },
  "keyPerformanceId": "kpi-strip",

  "priceInsights": [
    {
      "bedrooms": "string (e.g., 'Studio', '1 Bed', '2 Bed')",
      "averagePrice": "string (e.g., 'AED 597,047')",
      "priceYoyChange": "string (percentage next to price, e.g., '11.9' or '-5.1')",
      "transactions": "string (e.g., '230')",
      "transactionYoyChange": "string (percentage next to transactions, e.g., '-8.4' or '15')"
    }
  ],
  "priceInsightsId": "price-insights-table",

  "rentalMetrics": {
    "rentPerFt": "string (e.g., 'AED 108')",
    "yoyGrowth": "string (percentage, e.g., '21')"
  },
  "rentalMetricsId": "rental-metrics",

  "contactDistribution": {
    "newContracts": "string (percentage)",
    "renewalContracts": "string (percentage)"
  },
  "contactDistributionId": "contract-distribution",

  "marketInsights": "string (key callout text if present)",
  "marketInsightsId": "metro-insights",

  "totalTransactions": "string",
  "grossRentYield": "string (percentage)",

  "marketDynamicsAnalysisParagraphs": [
    "string (paragraph 1)",
    "string (paragraph 2)",
    "string (paragraph 3)"
  ],
  "marketDynamicsId": "market-dynamics",

  "investorConsiderations": {
    "entryTiming": "string",
    "configurationSelection": "string",
    "rentalStrategy": "string",
    "holdingPeriod": "string",
    "exitFlexibility": "string"
  },
  "investorConsiderationsId": "investor-considerations",

  "trendOverTimeGraph": {
    "id": "price-trend",
    "titleBlack": "string (main title)",
    "titleBlue": "string (subtitle)",
    "titleDelimeter": "-",
    "summary": "string (1-2 sentence description of trend)",
    "points": [
      { "xAxis": "string (period)", "yAxis": "string (value)" }
    ],
    "dataTable": {
      "caption": "string (title combined)",
      "headers": ["Period", "Value"],
      "rows": [
        ["string", "string"]
      ]
    }
  },

  "distributionByCategoryGraph": {
    "id": "distribution-category",
    "titleBlack": "string",
    "titleBlue": "string",
    "titleDelimeter": "-",
    "summary": "string",
    "points": [
      { "xAxis": "string (category)", "yAxis": "string (value)" }
    ],
    "dataTable": {
      "caption": "string",
      "headers": ["Category", "Value"],
      "rows": [["string", "string"]]
    }
  },

  "periodOverPeriodComparisonGraph": {
    "id": "period-comparison",
    "titleBlack": "string",
    "titleBlue": "string",
    "titleDelimeter": ":",
    "summary": "string",
    "item1": "string (first period label)",
    "item2": "string (second period label)",
    "units": "AED",
    "points": [
      { "title": "string (category)", "itemValue1": "string", "itemValue2": "string" }
    ],
    "dataTable": {
      "caption": "string",
      "headers": ["Category", "Period 1", "Period 2"],
      "rows": [["string", "string", "string"]]
    }
  },

  "topEntitiesByVolumeGraph": {
    "id": "top-entities",
    "titleBlack": "string",
    "titleBlue": "string",
    "titleDelimeter": "-",
    "summary": "string",
    "points": [
      { "title": "string (entity name)", "value": "string" }
    ],
    "dataTable": {
      "caption": "string",
      "headers": ["Rank", "Entity", "Value"],
      "rows": [["1", "string", "string"]]
    }
  },

  "compositionSplitByEntityGraph": {
    "id": "composition-split",
    "titleBlack": "string",
    "titleBlue": "string",
    "titleDelimeter": "-",
    "summary": "string",
    "item1": "string (first segment label)",
    "item2": "string (second segment label)",
    "points": [
      { "title": "string (entity)", "item1": "string (%)", "item2": "string (%)" }
    ],
    "dataTable": {
      "caption": "string",
      "headers": ["Entity", "Segment 1 %", "Segment 2 %"],
      "rows": [["string", "string", "string"]]
    }
  },

  "rentalInsights": [
    {
      "bedrooms": "string (e.g., 'Studio', '1 Bed', '2 Bed')",
      "averageRent": "string (e.g., 'AED 70,495')",
      "rentYoyChange": "string (percentage next to rent, e.g., '4.9' or '-7.6')",
      "transactions": "string (e.g., '4,015')",
      "transactionYoyChange": "string (percentage next to transactions, e.g., '10.4' or '-5')"
    }
  ],
  "rentalInsightsId": "rental-insights-table",

  "totalRentalTransactions": "string (e.g., '17,134')",
  "totalRentalValue": "string (e.g., 'AED 1.863B')",
  "rentalTransactionGrowth": "string (percentage, e.g., '10.4')",
  "rentalValueGrowth": "string (percentage, e.g., '16.6')",

  "offPlanPrimary": {
    "totalValue": "string (e.g., 'AED 20.615B')",
    "valueGrowth": "string (percentage, e.g., '25.8')",
    "transactions": "string (e.g., '8,125')",
    "transactionGrowth": "string (percentage, e.g., '28.9')"
  },
  "offPlanPrimaryId": "off-plan-primary",

  "dubaiOverallMarket": {
    "totalSaleValue": "string (if present)",
    "saleValueGrowth": "string (percentage)",
    "totalTransactions": "string",
    "transactionGrowth": "string (percentage)",
    "initialSalePercentage": "string",
    "resalePercentage": "string",
    "totalRentalValue": "string",
    "rentalValueGrowth": "string (percentage)",
    "rentalTransactions": "string",
    "rentalTransactionGrowth": "string (percentage)",
    "newRentalPercentage": "string",
    "renewalPercentage": "string"
  },
  "dubaiOverallMarketId": "dubai-overall-market"
}
```

---

## Data Extraction Rules

### For Metadata
- **community**: Extract from report title (e.g., "Business Bay" from "Business Bay H1 2024 Resale Report")
- **propertyType**: Determine from title or content (Apartments, Villas, Townhouses)
- **period**: Extract period code (H1 2024, Q3 2025, etc.)
- **dataSource**: Usually "Property Monitor" - check footer
- **dataAccessDate**: Check footer for date (convert to YYYY-MM-DD)

### For Raw Text Passages (Critical for Content Enhancement)
- **headerText**: Copy the exact main title/headline verbatim
- **insightText**: Capture any callout boxes, highlighted text, or analyst commentary - these often contain market context that's valuable for content generation
- **footnotes**: Include methodology notes (e.g., "Based on DLD registration data") and any caveats
- **dataLabels**: Extract labels from charts that provide context (e.g., "YoY Growth", "vs. Previous Period")

### For Visual Descriptions
- **chartTypes**: Describe each visualization type and what it represents
- **colorCoding**: Note color schemes used (helps understand comparative data)
- **highlightedMetrics**: Capture any visually emphasized values - these are often key findings
- **layoutNotes**: Brief description of overall layout structure

### For KPIs
- Look for large headline numbers with YoY change indicators
- Extract both the value and the percentage change
- Note: Price growth is usually shown as "+12%" - extract just "12"

### For Bedroom Price/Rental Breakdown Cards
These appear as cards with TWO rows per bedroom type:
```
[Bedroom Icon] AED 597,047    [Arrow] 11.9%   <- Row 1: Price + Price YoY
230 transactions | [Arrow] -8.4%              <- Row 2: Transactions + Transaction YoY
```

**Critical**: Each bedroom card has TWO YoY percentages:
1. **priceYoyChange**: The percentage to the RIGHT of the price (e.g., 11.9%)
2. **transactionYoyChange**: The percentage to the RIGHT of "transactions" (e.g., -8.4%)

Do NOT confuse these - they measure different things:
- Price YoY = how much the average price changed vs last year
- Transaction YoY = how much the transaction volume changed vs last year

Same pattern applies to rental breakdowns (rentalInsights).

### For Charts
- **points**: Extract each data point visible on the chart
- **dataTable**: Convert points to table format with formatted values
- **summary**: Write a brief description of what the chart shows
- **source (if different)**: Note if a specific chart shows a different data source (e.g., "Bayut" for search rankings vs default "Property Monitor")

### For Missing Data
- If a section is not present in the PDF, set it to `null`
- If a value is unclear, extract your best interpretation and note uncertainty

---

## Example: Extracting a Line Chart

**From PDF:**
```
Average Price per Sq. Ft - Business Bay
Trend shows: Jan: 1,714 | Feb: 1,749 | Mar: 1,717 | Apr: 1,686 | May: 1,732 | Jun: 1,840
```

**Extracted JSON:**
```json
{
  "trendOverTimeGraph": {
    "id": "price-trend",
    "titleBlack": "Average Price per Sq. Ft",
    "titleBlue": "Business Bay",
    "titleDelimeter": "-",
    "summary": "Price per square foot showed fluctuation throughout H1 2024, starting at AED 1,714 in January and ending at AED 1,840 in June.",
    "points": [
      { "xAxis": "January", "yAxis": "1714" },
      { "xAxis": "February", "yAxis": "1749" },
      { "xAxis": "March", "yAxis": "1717" },
      { "xAxis": "April", "yAxis": "1686" },
      { "xAxis": "May", "yAxis": "1732" },
      { "xAxis": "June", "yAxis": "1840" }
    ],
    "dataTable": {
      "caption": "Average Price per Sq. Ft - Business Bay",
      "headers": ["Month", "Price (AED/sqft)"],
      "rows": [
        ["January", "1,714"],
        ["February", "1,749"],
        ["March", "1,717"],
        ["April", "1,686"],
        ["May", "1,732"],
        ["June", "1,840"]
      ]
    }
  }
}
```

---

## Example: Extracting Raw Text and Visual Descriptions

**From PDF visual inspection:**
```
Title: "Business Bay Resale Report - H1 2024"
Callout box: "Business Bay continues to attract investor interest with
strong rental yields above 6%"
Footer: "Source: Property Monitor. Data as of July 2024."
```

**Extracted JSON:**
```json
{
  "rawTextPassages": {
    "headerText": "Business Bay Resale Report - H1 2024",
    "insightText": "Business Bay continues to attract investor interest with strong rental yields above 6%",
    "footnotes": "Source: Property Monitor. Data as of July 2024.",
    "dataLabels": ["YoY Change", "H1 2024 vs H1 2023", "Average Price per Sq. Ft"]
  },
  "visualDescriptions": {
    "chartTypes": [
      "Line chart showing monthly price per sqft trend (Jan-Jun)",
      "Horizontal bar chart showing top 5 buildings by transaction volume",
      "Vertical grouped bar chart comparing H1 2024 vs H1 2023 prices by bedroom"
    ],
    "colorCoding": "Cyan (#01AEE5) for current period, light gray for previous period, green for positive YoY, red for negative",
    "highlightedMetrics": ["AED 1,744 price per sqft (large hero number)", "+12% YoY growth (green badge)"],
    "layoutNotes": "Single-page infographic. KPI strip at top, price trend chart middle-left, bedroom breakdown table middle-right, top buildings chart at bottom."
  }
}
```

---

## Validation Checklist

Before finalizing extraction:

### Data Completeness
- [ ] All visible KPI values captured
- [ ] All chart data points extracted
- [ ] metadata object populated (community, period, propertyType)
- [ ] Every graph has an `id`, `summary`, and `dataTable`
- [ ] dataTable rows match points array data
- [ ] No placeholder text remaining
- [ ] String values properly formatted (commas in numbers, AED prefix where shown)

### Raw Text & Visual Context
- [ ] rawTextPassages.headerText contains verbatim title
- [ ] rawTextPassages.insightText captures any analyst commentary or callouts
- [ ] rawTextPassages.footnotes captures source attributions and methodology notes
- [ ] visualDescriptions.chartTypes lists all visualizations present
- [ ] visualDescriptions.highlightedMetrics captures emphasized values

### Source Attribution (For SEO/Accessibility)
- [ ] metadata.dataSource populated (usually "Property Monitor")
- [ ] metadata.dataAccessDate extracted from PDF footer
- [ ] Note any per-chart source variations (e.g., "Bayut" for search rankings)
- [ ] Source citations captured in rawTextPassages.footnotes
