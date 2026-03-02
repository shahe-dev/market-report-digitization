# Section Order -> Template -> JSON Source Mapping

This is the core reference for the rendering engine. For each `sectionOrder` entry in the enhanced JSON, this document specifies which HTML template renders it and which JSON fields feed it.

## Mapping Table

| `sectionOrder` value | HTML Template | Component Class | JSON Data Source |
|---|---|---|---|
| `executiveSummary` | `executive-summary.html` | `.executive-summary-card` | `enhanced.executiveSummaryEnhanced`, `enhanced.seoMetaContent.h1Primary` |
| `kpiStrip` | `kpi-strip.html` | `.key-performance` + `.kpi-grid` | `keyPerformance.*`, `grossRentYield`, `enhanced.chartSummaries.kpiStrip` or generated |
| `completionStatusDual` | `stacked-bar-dual.html` | `.stacked-bar-dual` | `stackedBarDualGraph.*` |
| `completionStatus` | `completion-status-indicators.html` | `.indicators-block` | Fallback when >=90% dominance; data from `dataEvaluation.binaryRatio` |
| `supplyDemandSnippet` | `market-dynamics-snippet.html` | `.market-dynamics-snippet` | `enhanced.marketDynamicsSnippets.supplyDemand.*` |
| `priceInsightsTable` | `data-table.html` | `.price-data-insights` + `.insights-table` | `priceInsights[]`, `enhanced.chartSummaries.priceInsightsTable` |
| `priceDriversSnippet` | `market-dynamics-snippet.html` | `.market-dynamics-snippet` | `enhanced.marketDynamicsSnippets.priceDrivers.*` |
| `marketInsight` | `market-insight.html` | `.market-insight` | `enhanced.marketInsightsEnhanced` |
| `rentalMetrics` | `rental-metrics.html` | `.indicators-block` | `rentalMetrics.*`, `totalRentalTransactions`, `totalRentalValue`, `grossRentYield`, `rentalTransactionGrowth`, `rentalValueGrowth` |
| `rentalInsightsTable` | `data-table.html` | `.price-data-insights` + `.insights-table` | `rentalInsights[]`, `enhanced.chartSummaries.rentalInsightsTable` |
| `contractDistribution` | `contract-distribution.html` | `.stacked-bar-section` | `contactDistribution.*`, `enhanced.chartSummaries.contractDistribution` |
| `investmentContextSnippet` | `market-dynamics-snippet.html` | `.market-dynamics-snippet` | `enhanced.marketDynamicsSnippets.investmentContext.*` |
| `offPlanPrimary` | `off-plan-comparison-cards.html` OR `off-plan-indicators.html` | `.comparison-metrics` OR `.indicators-block` | `offPlanPrimary.*`, check `enhanced.componentSelections.offPlanPrimary` |
| `dubaiOverallMarket` | `dubai-overall-market.html` | `.comparison-metrics` | `dubaiOverallMarket.*` |
| `investorConsiderations` | `investor-considerations.html` | `.investor-considerations` | `enhanced.investorConsiderationsEnhanced.*` |
| `sourceCitation` | `source-citation.html` | `.source-citation` | `metadata.*`, `rawTextPassages.footnotes` |

## Conditional Branching Rules (only 4)

| Condition | Check | Result |
|---|---|---|
| Stacked-bar-dual vs indicators-block | If `enhanced.componentSelections` has key `binaryRatioDual` -> render `stacked-bar-dual`. If it has key `completionStatus` -> render `indicators-block`. | `sectionOrder` will contain `completionStatusDual` or `completionStatus` accordingly. |
| Contract distribution present/absent | `enhanced.conditionalSections.includeContractDistribution` | If `false`, skip `contractDistribution` in section order (it won't appear in `sectionOrder` array). |
| Off-plan component type | `enhanced.componentSelections.offPlanPrimary` value | `"comparison-cards"` -> use `.comparison-metrics` template. `"indicators-block"` -> use `.indicators-block` template. |
| Dubai market sub-splits | Check for keys `dubaiSalesSplit`, `dubaiRentalSplit` in `enhanced.componentSelections` | If present, render additional stacked bars before the main Dubai market comparison cards. |
