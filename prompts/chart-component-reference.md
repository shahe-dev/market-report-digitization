# Chart Component Reference

Standardized chart naming conventions across all MPP report generation documents.

---

## Component ID Cross-Reference

| Component ID | Standard Name | Use Case | Template Section |
|-------------|---------------|----------|------------------|
| `area-line` | Area Line Chart | Single-series time-series trend | html-generation-prompt.md #4 |
| `multi-line` | Multi-Line Chart | Multi-series time-series comparison (2-3 series) | html-generation-prompt.md #9 |
| `column` | Column Chart | Categorical distribution (vertical bars, short labels) | html-generation-prompt.md #5 |
| `grouped-column` | Grouped Column Chart | Period-over-period comparison (2 periods, categories) | html-generation-prompt.md #7 |
| `stacked-column` | Stacked Column Chart | Part-to-whole composition (2-4 segments) | html-generation-prompt.md #8 |
| `bar` | Bar Chart | Rankings, long labels (horizontal orientation) | html-generation-prompt.md #6 |
| `data-table` | Data Table | Segment-metrics: bedrooms/periods/communities with numeric columns | html-generation-prompt.md #10 |
| `kpi-strip` | KPI Strip | 4 peer-level KPIs (equal importance) | html-generation-prompt.md #3 |
| `indicators-block` | Indicators Block | Volume + yield pairing (hierarchical metrics) | html-generation-prompt.md #15 |
| `comparison-cards` | Comparison Cards | Binary ratios (100% splits), metric + YoY pairs | html-generation-prompt.md #16 |
| `comparison-table` | Comparison Table | Entity comparison (2-4 options, qualitative attributes) | html-generation-prompt.md #17 |
| `stacked-bar` | Stacked Bar | Horizontal part-to-whole (binary split, visual proportion) | html-generation-prompt.md #18 |

---

## Naming Convention Rules

### Orientation
- **Column** = Vertical bars (categories on x-axis)
- **Bar** = Horizontal bars (categories on y-axis)

### Modifiers
- **Grouped** = Multiple series side-by-side within each category
- **Stacked** = Segments stacked on each other (composition)
- **Area** = Filled region under line
- **Multi** = Multiple series overlaid on same axes

---

## Component Library HTML IDs

| Library Section ID | Library HTML ID | Maps to Component ID |
|-------------------|-----------------|---------------------|
| #column-charts | #grouped-column | `grouped-column` |
| #column-charts | #column | `column` |
| #column-charts | #stacked-column | `stacked-column` |
| #column-charts | #bar | `bar` |
| #line-charts | #area-line | `area-line` |
| #line-charts | #multi-line | `multi-line` |
| #kpi-metrics | #stacked-bar | `stacked-bar` |

---

## Selection Rules Quick Reference

### Chart Components
| Data Pattern | Component ID | Rule |
|--------------|-------------|------|
| Time-series, 1 series, 3+ points | `area-line` | Single-metric trajectory with area fill |
| Time-series, 2-4 series, 3+ points | `multi-line` | Multi-entity trend comparison |
| Categorical, 1 period, 3-7 items, short labels | `column` | Single-period snapshot, visual ranking |
| Rankings, 5-15 entities, labels >10 chars | `bar` | Horizontal for top-to-bottom ranking |
| Composition, 2+ categories, 2-3 components | `stacked-column` | Cross-category part-to-whole comparison |
| Period comparison, 2 periods, 3-6 categories | `grouped-column` | Visual "see the change" comparison |
| Segment-metrics (rows=bedrooms/periods, cols=metrics) | `data-table` | Structured numeric data for value scanning |

### Non-Chart Components
| Data Pattern | Component ID | Rule |
|--------------|-------------|------|
| 4 peer-level KPIs | `kpi-strip` | Equal importance metrics |
| Volume + yield/rate pairing | `indicators-block` | Hierarchical: 1 hero + 1-2 supporting |
| Binary ratio (sums to 100%), visual proportion desired | `stacked-bar` | Horizontal bar showing off-plan/ready, new/renewal |
| Binary ratio (sums to 100%), text display only | `comparison-cards` | e.g., 41.6% new vs 58.4% renewal |
| Metric + its YoY change | `comparison-cards` | Primary value + change annotation |
| 2-4 entities, qualitative attributes | `comparison-table` | Side-by-side option evaluation |
| Bedroom/period breakdown with metrics | `data-table` | "What are the numbers for each segment?" |

### When NOT to Use
| Scenario | Avoid | Use Instead |
|----------|-------|-------------|
| Visual relationship IS the insight | `comparison-cards` | `stacked-column` or `bar` |
| Change over multiple periods | `comparison-cards` | `area-line` or `multi-line` |
| Numeric metrics by bedroom/period | `comparison-table` | `data-table` |
| >4 entities to compare | `comparison-table` | `data-table` |
| >2 periods to compare | `grouped-column` | `multi-line` or `data-table` |
| >6 categories in period comparison | `grouped-column` | `data-table` |
| Exact values matter more than visual | `grouped-column` | `data-table` |
| 2-period comparison | `column` | `grouped-column` |
| >7 categories | `column` | `bar` (horizontal) |
| Labels >15 chars | `column` | `bar` (horizontal) |
| Multiple metrics per category | `column` | `data-table` |
| Single category binary split | `stacked-column` | `comparison-cards` |
| >3 components in composition | `stacked-column` | `data-table` |
| Absolute values matter more than proportions | `stacked-column` | `grouped-column` or `column` |
| Short labels (<=10 chars), few entities (<=5) | `bar` | `column` (vertical) |
| Period-over-period comparison | `bar` | `grouped-column` |
| Multiple metrics per entity | `bar` | `data-table` |
| >15 entities to rank | `bar` | `data-table` (with top 10 bar summary) |
| Only 2 time periods | `area-line` | `grouped-column` |
| Multiple series to compare | `area-line` | `multi-line` |
| Comparing categories, not time | `area-line` | `column` or `bar` |
| Exact values matter more than trend shape | `area-line` | `data-table` |
| Single entity trend | `multi-line` | `area-line` |
| Only 2 time periods (multi-series) | `multi-line` | `grouped-column` |
| More than 4 series | `multi-line` | `data-table` or split charts |
| Composition comparison over categories | `multi-line` | `stacked-column` |
| Exact values at each point critical | `multi-line` | `data-table` |
| One category exceeds 90% | `stacked-bar` | `indicators-block` |
| More than 2 categories | `stacked-bar` | `stacked-column` or `data-table` |
| Comparing same ratio across entities | `stacked-bar` | `stacked-column` |
| No visual proportion needed | `stacked-bar` | `comparison-cards` |

---

## CSS Class Mapping

### Chart Components
| Component ID | Primary CSS Class | Container Class |
|-------------|------------------|-----------------|
| `area-line` | `.line-chart` | `.chart-card` |
| `multi-line` | `.line-chart` | `.chart-card` |
| `column` | `.bar`, `.bars-container--single` | `.chart-card` |
| `grouped-column` | `.bar-group`, `.bars-container--multibar` | `.chart-card` |
| `stacked-column` | `.stacked-bar`, `.bars-container--stacked` | `.chart-card` |
| `bar` | `.horizontal-bar` | `.horizontal-chart` |

### Metric Components
| Component ID | Primary CSS Class | Container Class |
|-------------|------------------|-----------------|
| `kpi-strip` | `.kpi-card` | `.key-performance` |
| `indicators-block` | `.indicator-card` | `.indicators-block` |
| `comparison-cards` | `.metrics-card` | `.comparison-metrics` |
| `stacked-bar` | `.stacked-bar` | `.stacked-bar-section` |

### Table Components
| Component ID | Primary CSS Class | Container Class |
|-------------|------------------|-----------------|
| `data-table` | `.insights-table` | `.price-data-insights` |
| `comparison-table` | `.differences-table` | `.key-differences` |

### Content Block Components
| Component ID | Primary CSS Class | Container Class |
|-------------|------------------|-----------------|
| `executive-summary-card` | `.executive-summary-card` | `.executive-summary-card` |
| `market-insight-block` | `.market-insight` | `.market-insight` |
| `market-dynamics-block` | `.market-dynamics` | `.market-dynamics` |
| `market-dynamics-snippet` | `.market-dynamics-snippet` | - |
| `investor-considerations-grid` | `.considerations-grid` | `.investor-considerations` |
| `source-citation` | `.source-citation` | `.source-citation` |

---

*Version 2.0 - January 2026*
*v1.0: Initial standardized chart naming conventions*
*v1.1: Added selection rules and CSS mappings for comparison-cards, comparison-table, indicators-block*
*v1.2: Updated data-table from fallback to primary segment-metrics use case*
*v1.3: Enhanced grouped-column rules with category limits and "When NOT to Use" entries*
*v1.4: Updated column rule to specify single-period snapshot; added "When NOT to Use" entries*
*v1.5: Updated stacked-column rule for cross-category composition; added "When NOT to Use" entries*
*v1.6: Consolidated bar rules for rankings; added "When NOT to Use" entries*
*v1.7: Updated area-line rule for 3+ points; added "When NOT to Use" entries*
*v1.8: Updated multi-line rule for 2-4 series, 3+ points; added "When NOT to Use" entries*
*v1.9: Reorganized CSS mapping by category; added Content Block Components section*
*v2.0: Added stacked-bar (horizontal part-to-whole) component for binary split visualization*
