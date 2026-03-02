# Developer Handoff: JSON to CMS Component Mapping

This document provides a direct mapping between JSON keys and their corresponding CMS components for programmatic page generation.

---

## How to Use This Document

Every renderable section in the JSON output includes a `componentId` field. Use this field to:
1. Identify which HTML/CSS component to render
2. Map data to the correct CMS template
3. Reference the CSS class for styling

**Pattern**: `[sectionName]ComponentId` contains the component ID value.

---

## Quick Reference: JSON Key to Component Mapping

| JSON Key | componentId Field | Component ID | CSS Container |
|----------|-------------------|--------------|---------------|
| `executiveSummary` | `executiveSummaryComponentId` | `executive-summary-card` | `.executive-summary-card` |
| `keyPerformance` | `keyPerformanceComponentId` | `kpi-strip` | `.key-performance` |
| `priceInsights` | `priceInsightsComponentId` | `data-table` | `.price-data-insights` |
| `rentalMetrics` | `rentalMetricsComponentId` | `indicators-block` | `.indicators-block` |
| `contactDistribution` | `contactDistributionComponentId` | `comparison-cards` | `.comparison-metrics` |
| `marketInsights` | `marketInsightsComponentId` | `market-insight-block` | `.market-insight` |
| `marketDynamicsAnalysisParagraphs` | `marketDynamicsComponentId` | `market-dynamics-block` | `.market-dynamics` |
| `investorConsiderations` | `investorConsiderationsComponentId` | `investor-considerations-grid` | `.investor-considerations` |
| `keyDifferences` | `keyDifferencesComponentId` | `comparison-table` | `.key-differences` |

---

## Graph Objects

Graph objects have `componentId` nested inside the object:

| JSON Key | componentId Location | Component ID (varies) | CSS Container |
|----------|---------------------|----------------------|---------------|
| `trendOverTimeGraph` | `.componentId` | `area-line` | `.chart-card` |
| `multiSeriesComparisonGraph` | `.componentId` | `multi-line` | `.chart-card` |
| `distributionByCategoryGraph` | `.componentId` | `column` or `comparison-cards` | varies |
| `periodOverPeriodComparisonGraph` | `.componentId` | `grouped-column` | `.chart-card` |
| `topEntitiesByVolumeGraph` | `.componentId` | `bar` | `.horizontal-chart` |
| `compositionSplitByEntityGraph` | `.componentId` | `stacked-column` or `comparison-cards` | varies |
| `bedroomPriceTable` | `.componentId` | `data-table` | `.price-data-insights` |
| `rentalBedroomPriceTable` | `.componentId` | `data-table` | `.price-data-insights` |

**Note**: Some graph types have variable `componentId` based on data pattern. Always read the `componentId` value directly from the JSON rather than assuming based on the graph object name.

---

## Component ID Master List

### Chart Components
| componentId | Renders As | Use Case |
|-------------|-----------|----------|
| `area-line` | Area/Line Chart | Single-series time trend |
| `multi-line` | Multi-Line Chart | Multiple series comparison |
| `column` | Vertical Bar Chart | Category distribution (3-7 items) |
| `grouped-column` | Grouped Bar Chart | Period-over-period comparison |
| `stacked-column` | Stacked Bar Chart | Composition breakdown |
| `bar` | Horizontal Bar Chart | Rankings (5-15 items) |

### Metric Components
| componentId | Renders As | Use Case |
|-------------|-----------|----------|
| `kpi-strip` | 4-column KPI strip | 4 peer-level metrics |
| `indicators-block` | Metrics cards | Hierarchical metrics (hero + supporting) |
| `comparison-cards` | Side-by-side cards | Binary ratios (100% split) |

### Table Components
| componentId | Renders As | Use Case |
|-------------|-----------|----------|
| `data-table` | Data table | Segment-metrics (bedrooms x metrics) |
| `comparison-table` | Comparison table | Entity comparison (qualitative) |

### Content Block Components
| componentId | Renders As | Use Case |
|-------------|-----------|----------|
| `executive-summary-card` | Summary card with mini-chart | Report introduction |
| `market-insight-block` | Insight callout | Key differentiating observation |
| `market-dynamics-block` | Multi-paragraph block | Market analysis |
| `market-dynamics-snippet` | Single paragraph snippet | Contextual analysis (interleaved) |
| `investor-considerations-grid` | 5-cell grid | Investment considerations |
| `source-citation` | Footer citation | Data attribution |

---

## CMS Integration Approach

### Option 1: Direct Component Lookup
```javascript
// Read componentId directly from JSON
const componentType = jsonData.keyPerformanceComponentId; // "kpi-strip"
const template = getTemplate(componentType);
render(template, jsonData.keyPerformance);
```

### Option 2: Graph Component Lookup
```javascript
// For graph objects, componentId is nested
const graph = jsonData.trendOverTimeGraph;
if (graph && graph.componentId) {
  const template = getTemplate(graph.componentId); // "area-line"
  render(template, graph);
}
```

### Option 3: Section Order-Driven Rendering
```javascript
// Use enhanced.sectionOrder to control render sequence
jsonData.enhanced.sectionOrder.forEach(sectionKey => {
  const componentId = getComponentIdForSection(sectionKey);
  const data = getSectionData(sectionKey, jsonData);
  render(getTemplate(componentId), data);
});
```

---

## Validation Checklist

Before importing JSON into CMS:

- [ ] Every section has `*ComponentId` field populated
- [ ] Every graph object has nested `componentId` field
- [ ] All `componentId` values match entries in this document
- [ ] `conditionalSections` flags checked before rendering optional sections
- [ ] Null graph objects (`null`) are skipped

---

## Reference Files

| File | Purpose |
|------|---------|
| `chart-component-reference.md` | Complete component selection rules |
| `json-schema.md` | Full JSON structure specification |
| `MPP-COMPONENTS-LIBRARY-v5-SEO.html` | CSS source for all components |
| `html-generation-prompt.md` | HTML rendering templates |

---

*Version 1.0 - January 2026*
