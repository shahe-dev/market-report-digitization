# Rendering Engine Pseudocode

The complete algorithm for converting an enhanced JSON file into a self-contained HTML report.

## Main Entry Point

```
FUNCTION renderReport(jsonPath):
  data = parseJSON(readFile(jsonPath))
  css = readFile("mpp-report-styles.css")

  html = ""
  html += renderDocumentHead(data, css)
  html += renderReportHeader(data)

  FOR EACH sectionKey IN data.enhanced.sectionOrder:
    SWITCH sectionKey:
      CASE "executiveSummary":
        html += renderTemplate("executive-summary.html", data)

      CASE "kpiStrip":
        html += renderTemplate("kpi-strip.html", data)

      CASE "completionStatusDual":
        html += renderTemplate("stacked-bar-dual.html", data)

      CASE "completionStatus":
        html += renderTemplate("completion-status-indicators.html", data)

      CASE "supplyDemandSnippet":
        html += renderSnippet("supplyDemand", data)

      CASE "priceInsightsTable":
        html += renderDataTable("price", data)

      CASE "priceDriversSnippet":
        html += renderSnippet("priceDrivers", data)

      CASE "marketInsight":
        html += renderTemplate("market-insight.html", data)

      CASE "rentalMetrics":
        html += renderTemplate("rental-metrics.html", data)

      CASE "rentalInsightsTable":
        html += renderDataTable("rental", data)

      CASE "contractDistribution":
        html += renderTemplate("contract-distribution.html", data)

      CASE "investmentContextSnippet":
        html += renderSnippet("investmentContext", data)

      CASE "offPlanPrimary":
        componentType = data.enhanced.componentSelections.offPlanPrimary
        IF componentType == "comparison-cards":
          html += renderTemplate("off-plan-comparison-cards.html", data)
        ELSE IF componentType == "indicators-block":
          html += renderTemplate("off-plan-indicators.html", data)

      CASE "dubaiOverallMarket":
        html += renderTemplate("dubai-overall-market.html", data)

      CASE "investorConsiderations":
        html += renderTemplate("investor-considerations.html", data)

      CASE "sourceCitation":
        html += renderTemplate("source-citation.html", data)

  html += "</body></html>"
  RETURN html
```

## Supporting Functions

### renderDocumentHead(data, css)

```
FUNCTION renderDocumentHead(data, css):
  RETURN concat(
    '<!DOCTYPE html><html lang="en"><head>',
    '<meta charset="UTF-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    '<title>' + HTML_ESCAPE(data.enhanced.seoMetaContent.titleTag) + '</title>',
    '<meta name="description" content="' + HTML_ESCAPE(data.enhanced.seoMetaContent.metaDescription) + '">',
    '<link rel="canonical" href="' + data.metadata.canonicalUrl + '">',
    '<link rel="preconnect" href="https://fonts.googleapis.com">',
    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
    '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">',
    '<script type="application/ld+json">' + JSON.stringify(data.schemaOrg) + '</script>',
    '<style>' + css + '</style>',
    '</head><body>'
  )
```

### renderReportHeader(data)

```
FUNCTION renderReportHeader(data):
  h1Text = data.enhanced.seoMetaContent.h1Primary
  // Split on " - " and wrap the last part in <span class="highlight">
  parts = h1Text.split(" - ")
  IF parts.length > 1:
    titleHtml = HTML_ESCAPE(parts[0]) + ' - <span class="highlight">' + HTML_ESCAPE(parts[1]) + '</span>'
  ELSE:
    titleHtml = HTML_ESCAPE(h1Text)

  RETURN concat(
    '<header class="report-header">',
    '<h1 class="report-header__title">' + titleHtml + '</h1>',
    '<p class="report-header__subtitle">' + HTML_ESCAPE(data.rawTextPassages.headerText) + '</p>',
    '<p class="report-header__period">' + HTML_ESCAPE(data.metadata.periodRange) + '</p>',
    '</header>'
  )
```

### renderSnippet(snippetKey, data)

```
FUNCTION renderSnippet(snippetKey, data):
  snippet = data.enhanced.marketDynamicsSnippets[snippetKey]
  idMap = {
    "supplyDemand": "supply-demand-title",
    "priceDrivers": "price-drivers-title",
    "investmentContext": "investment-context-title"
  }
  RETURN concat(
    '<div class="market-dynamics-snippet" aria-labelledby="' + idMap[snippetKey] + '">',
    '<h3 id="' + idMap[snippetKey] + '" class="market-dynamics-snippet__title">' + HTML_ESCAPE(snippet.title) + '</h3>',
    '<p class="market-dynamics-snippet__content">' + HTML_ESCAPE(snippet.content) + '</p>',
    '</div>'
  )
```

### renderDataTable(type, data)

```
FUNCTION renderDataTable(type, data):
  IF type == "price":
    config = {
      sectionId: "price-insights",
      heading: "Average Resale Price by",
      chartSummary: data.enhanced.chartSummaries.priceInsightsTable,
      priceColumnHeader: "Average Price",
      priceYoyHeader: "Price YoY",
      dataRows: data.priceInsights,
      priceField: "averagePrice",
      priceYoyField: "priceYoyChange",
      transYoyField: "transactionYoyChange",
      figcaption: data.priceInsightsFigcaption,
      dataSource: data.priceInsightsDataSource
    }
  ELSE IF type == "rental":
    config = {
      sectionId: "rental-insights",
      heading: "Average Rental Price by",
      chartSummary: data.enhanced.chartSummaries.rentalInsightsTable,
      priceColumnHeader: "Average Rent",
      priceYoyHeader: "Rent YoY",
      dataRows: data.rentalInsights,
      priceField: "averageRent",
      priceYoyField: "rentYoyChange",
      transYoyField: "transactionYoyChange",
      figcaption: data.rentalInsightsFigcaption,
      dataSource: data.rentalInsightsDataSource
    }

  // Render table rows from config.dataRows array
  rowsHtml = ""
  FOR EACH row IN config.dataRows:
    rowsHtml += '<tr>'
    rowsHtml += '<td class="bedroom-label">' + row.bedrooms + '</td>'
    rowsHtml += '<td>' + row[config.priceField] + '</td>'
    rowsHtml += '<td class="yoy-value ' + SIGN(row[config.priceYoyField]) + '">' + FORMAT_YOY(row[config.priceYoyField]) + '</td>'
    rowsHtml += '<td>' + row.transactions + '</td>'
    rowsHtml += '<td class="yoy-value ' + SIGN(row[config.transYoyField]) + '">' + FORMAT_YOY(row[config.transYoyField]) + '</td>'
    rowsHtml += '</tr>'

  // Assemble full section (see data-table.html template for structure)
  RETURN renderTemplateWithConfig("data-table.html", config, rowsHtml)
```

## Batch Processing

```
FUNCTION renderAllReports(inputDir, outputDir):
  // Find all enhanced JSON files (exclude *-extracted.json)
  jsonFiles = glob(inputDir + "/*-resale-report.json")

  FOR EACH jsonPath IN jsonFiles:
    htmlContent = renderReport(jsonPath)
    outputPath = outputDir + "/" + basename(jsonPath).replace(".json", ".html")
    writeFile(outputPath, htmlContent)
    print("Rendered: " + outputPath)
```

## Key Implementation Notes

1. **CSS is inlined** -- read `mpp-report-styles.css` once and inject into every HTML file's `<style>` tag. No external stylesheet reference.

2. **Section order is authoritative** -- only render sections that appear in `data.enhanced.sectionOrder`. Do not hardcode section presence.

3. **Conditional branching is minimal** -- only 4 conditions exist (see SECTION-TEMPLATE-MAP.md). The JSON already encodes all decisions.

4. **All text content must be HTML-escaped** before injection, especially ampersands in "Supply & Demand" titles.

5. **Schema.org JSON-LD** is serialized directly from `data.schemaOrg` -- no manual construction needed.
