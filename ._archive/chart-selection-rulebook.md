# MPP Chart Selection Rulebook
## Deterministic Framework for Data Visualization Component Selection

**Version:** 1.0
**Last Updated:** 2026-01-20
**Purpose:** Eliminate subjective chart selection by providing hard thresholds and decision rules backed by perceptual research and cognitive science.

---

## Table of Contents
1. [Perceptual Accuracy Foundation](#perceptual-accuracy-foundation)
2. [Component Inventory](#component-inventory)
3. [Decision Matrix](#decision-matrix)
4. [Threshold Rules](#threshold-rules)
5. [Real Estate-Specific Guidelines](#real-estate-specific-guidelines)
6. [Anti-Patterns](#anti-patterns)

---

## Perceptual Accuracy Foundation

### Cleveland & McGill Hierarchy (1984)
Ranked from **most accurate** to **least accurate** perception:

1. **Position along common scale** - Error rate: ~5%
2. **Position along non-aligned scales** - Error rate: ~10%
3. **Length** - Error rate: ~15%
4. **Angle/Slope** - Error rate: ~20-25%
5. **Area** - Error rate: ~25-30%
6. **Volume/Color saturation** - Error rate: >30%

**Implication:** Bar charts (length encoding) consistently outperform pie charts (angle/area encoding) for quantitative comparison tasks by 15-20% in accuracy.

### Miller's Law (Working Memory Constraints)
- **5-9 chunks** maximum in working memory
- **5 chunks** for complex information
- **9 chunks** for simple information

**Implication:** Charts with >7 categories require chunking/grouping strategies or component type change.

---

## Component Inventory

Your MPP library contains:

### Summary Components
- Executive Summary Card (with mini sparkline)
- Market Insight Block
- Source Citation

### KPI & Metrics
- Key Performance Indicators (4-column strip)
- Indicators Block (gradient + chart)
- Comparison Metrics Cards

### Data Tables
- Price Data Insights Table
- Key Differences Summary Table

### Chart Types
1. **Vertical Multi-bar Chart** - Side-by-side comparison
2. **Vertical Single-bar Chart** - Volume/magnitude display
3. **Vertical Stacked Bar Chart** - Part-to-whole composition
4. **Horizontal Bar Chart** - Rankings with labels
5. **Single Line Chart** - Time series trend (with area fill)
6. **Multi-line Chart** - Comparative time series (max 3 lines)

### Content Blocks
- Market Dynamics (text + image)
- Investor Considerations (icon cards grid)

---

## Decision Matrix

### Primary Decision Tree

```
START: What are you trying to communicate?

A. SINGLE METRIC VALUE
   -> Categories: 1
   -> Use: KPI Card (if critical) OR Indicator Card (if supplementary)
   -> Example: "AED 2,911 avg price per sq.ft"

B. COMPARISON (Item-to-Item)
   |
   +-- Categories: 2-4
   |   -> Use: Vertical Multi-bar Chart
   |   -> Example: "H1 2024 vs H1 2025 prices by bedroom type"
   |
   +-- Categories: 5-10
   |   |
   |   +-- Label length: <15 characters
   |   |   -> Use: Vertical Single-bar Chart
   |   |
   |   +-- Label length: >15 characters
   |       -> Use: Horizontal Bar Chart
   |
   +-- Categories: 11+
       -> Use: Data Table (sortable)
       -> Rationale: Exceeds working memory capacity

C. PART-TO-WHOLE (Composition)
   |
   +-- Total categories: 2-4
   |   -> Use: Vertical Stacked Bar Chart
   |   -> Example: "Off-plan vs Ready property mix by community"
   |
   +-- Total categories: 5+
       -> Use: Data Table with percentage column
       -> Rationale: Stacked segments become unreadable >4

D. RANKING/ORDERING
   -> Use: Horizontal Bar Chart (descending order)
   -> Max categories: 10 (beyond this, show "Top 10")
   -> Example: "Top 5 communities by transaction volume"

E. TIME SERIES TREND
   |
   +-- Data points: 3-8
   |   |
   |   +-- Single series
   |   |   -> Use: Single Line Chart (with area fill)
   |   |   -> Example: "Q1 2024 - H1 2025 price trend"
   |   |
   |   +-- Multiple series: 2-3
   |       -> Use: Multi-line Chart
   |       -> Example: "Price comparison: Meadows vs Mudon vs Reem"
   |
   +-- Multiple series: 4+
   |   -> Use: Data Table with sparklines
   |   -> Rationale: >3 lines create visual clutter
   |
   +-- Data points: 9+
       |
       +-- Emphasis: Overall trend/pattern
       |   -> Use: Line Chart (continuous encoding)
       |
       +-- Emphasis: Individual period values
           -> Use: Vertical Bar Chart (discrete encoding)

F. DISTRIBUTION/FREQUENCY
   -> Not in current library
   -> Workaround: Use Data Table with sorted values
   -> Future: Add histogram component

G. CORRELATION/RELATIONSHIP
   -> Not in current library
   -> Workaround: Use Data Table with calculated metrics
   -> Future: Add scatter plot component

H. COMPLEX MULTI-DIMENSIONAL
   -> Categories: >10 OR Dimensions: >3
   -> Use: Data Table (always)
   -> Rationale: Cognitive load exceeds comprehension threshold
```

---

## Threshold Rules

### Hard Thresholds (Research-Backed)

| Threshold | Value | Source | Application |
|-----------|-------|--------|-------------|
| **Maximum categories for vertical bar chart** | 10 | FusionCharts Best Practices | Beyond 10, switch to horizontal or table |
| **Maximum categories for horizontal bar chart** | 15 | Perceptual Edge | Beyond 15, show "Top 15" or paginate |
| **Minimum categories for chart (vs table)** | 3 | Stephen Few | <3 categories: use KPI cards instead |
| **Maximum stacked segments** | 4 | Cognitive Load Research | Beyond 4, segments become unreadable |
| **Maximum line series** | 3 | Few's "Show Me Numbers" | >3 lines create spaghetti charts |
| **Maximum data points for bar chart** | 20 | Visual density analysis | >20: switch to line chart or aggregate |
| **Working memory limit** | 7±2 | Miller's Law | Group/chunk categories beyond 7 |
| **Label character threshold (vertical)** | 15 | UX readability | >15 chars: switch to horizontal |
| **Label character threshold (horizontal)** | 50 | Layout constraints | >50 chars: abbreviate or use table |
| **Decimal precision display** | 2 | Cognitive processing | More precision increases cognitive load |
| **Color distinction limit** | 6 | Color perception | Beyond 6 colors, users cannot differentiate |

### Conditional Thresholds

**When to use TABLE instead of CHART:**

```
IF (categories > 10)
   OR (data_dimensions > 3)
   OR (precision_required = "exact values")
   OR (comparison_type = "lookup")
   OR (variance_within_series < 10%)
THEN use_data_table()
```

**When to use HORIZONTAL vs VERTICAL bars:**

```
IF (label_avg_length > 15 characters)
   OR (categories > 7)
   OR (purpose = "ranking")
   OR (mobile_primary = TRUE)
THEN use_horizontal_bar_chart()
ELSE use_vertical_bar_chart()
```

**When to use LINE vs BAR for time series:**

```
IF (data_points >= 9)
   AND (time_interval = "continuous" OR "regular")
   AND (focus = "trend/pattern")
THEN use_line_chart()
ELSE IF (data_points <= 8)
   AND (focus = "individual_values")
THEN use_bar_chart()
```

---

## Real Estate-Specific Guidelines

### Property Metrics by Type

| Metric Type | Best Component | Rationale |
|-------------|----------------|-----------|
| **Price per sq.ft (single period)** | KPI Card | Critical metric, deserves prominence |
| **Price per sq.ft (trend)** | Line Chart (with area fill) | Shows appreciation trajectory |
| **YoY Price Growth** | KPI Card with directional indicator | Percentage change, single value |
| **Transaction Volume** | KPI Card OR Vertical Bar (if by period) | Depends on time granularity |
| **Rental Yield** | Indicator Card with mini chart | Secondary metric with context |
| **Community Rankings** | Horizontal Bar Chart | Long community names, ranking context |
| **Bedroom Type Comparison** | Vertical Multi-bar Chart | 3-5 bedroom types, short labels |
| **Off-plan vs Ready Mix** | Stacked Bar Chart | Binary composition, multiple communities |
| **Price by Quarter (6+ periods)** | Line Chart | Time series, trend focus |
| **Top Communities (5-10)** | Horizontal Bar Chart | Rankings with transaction counts |
| **Market Share Distribution** | Data Table (if >5) OR Stacked Bar (if 2-4) | Composition analysis |

### Dubai Real Estate Context

**Community Names:** Typically 15-40 characters
- "The Meadows Villas" (19 chars)
- "Palm Jumeirah Apartments" (24 chars)
- "Sobha Hartland" (14 chars)

**Decision:** Default to horizontal bars for community comparisons.

**Bedroom Configurations:** 3-7 categories typically
- Studio, 1BR, 2BR, 3BR, 4BR, 5BR, 6BR+
- Decision: Vertical bars acceptable if <=5 types shown

**Time Periods:** Standard reporting intervals
- Quarterly (Q1-Q4): 4 data points -> Bar or Line acceptable
- Half-yearly (H1, H2): 2 data points -> KPI comparison or Multi-bar
- Annual trend (5+ years): Line Chart preferred

---

## Anti-Patterns

### NEVER Do This

| Anti-Pattern | Why It Fails | What To Use Instead |
|--------------|--------------|---------------------|
| **Pie charts** | Area/angle encoding 20% less accurate than length | Horizontal bar chart (ranking) or Stacked bar (composition) |
| **3D charts** | Perspective distorts perception by 30-50% | Flat 2D equivalents |
| **Dual-axis charts** | 70% of users misinterpret scale relationships | Separate charts or normalized index |
| **>3 line series** | Spaghetti chart - cannot track individual lines | Small multiples or data table |
| **Stacked bars >4 segments** | Middle segments impossible to compare | Grouped bars or table |
| **Vertical bars with rotated labels** | 40% slower to read than horizontal | Horizontal bar chart |
| **Charts for <3 data points** | Wastes space, use exact values | KPI cards or inline text |
| **Line charts for categorical data** | Implies false continuity | Bar chart (discrete categories) |
| **Bars not starting at zero** | Distorts magnitude perception | Always anchor at zero or use dot plot |
| **>7 categories without grouping** | Exceeds working memory | Chunk into groups or filter to "Top N" |

### Research-Backed Failure Modes

**Stacked Bar Readability (Thudt et al., 2016):**
- Only bottom segment accurately comparable
- Middle segments: 35% error rate in value estimation
- Recommendation: Limit to 2-3 segments max, 4 absolute maximum

**Multi-line Cognitive Load (Few, 2012):**
- 2 lines: 95% comprehension
- 3 lines: 75% comprehension
- 4 lines: 45% comprehension
- 5+ lines: <30% comprehension

**Category Limit Studies:**
- Accessibility guidelines: 5 categories (strict)
- Best practices: 5-10 categories (optimal)
- Upper limit: 12 categories (before readability collapse)

---

## Decision Flowchart Summary

```
Input: Data Characteristics
  |
  V
How many data points/categories?
  |
  +-- 1 -> KPI Card
  |
  +-- 2-4 -> What comparison?
  |           |
  |           +-- Side-by-side -> Vertical Multi-bar
  |           +-- Part-to-whole -> Stacked Bar
  |           +-- Ranking -> Horizontal Bar
  |
  +-- 5-10 -> Label length?
  |            |
  |            +-- Short (<15 char) -> Vertical Bar
  |            +-- Long (>15 char) -> Horizontal Bar
  |
  +-- 11+ -> Data Table (or show "Top 10")

Input: Time Series?
  |
  V
How many periods?
  |
  +-- 2-3 -> Multi-bar comparison
  |
  +-- 4-8 -> Line chart (if trend focus)
  |          Bar chart (if value focus)
  |
  +-- 9+ -> Line chart (always)

Input: Multiple series?
  |
  V
How many series?
  |
  +-- 1 -> Line Chart (area fill)
  |
  +-- 2-3 -> Multi-line Chart
  |
  +-- 4+ -> Data Table with sparklines
```

---

## Implementation Checklist

Before finalizing any chart, verify:

- [ ] Category count within threshold for selected chart type
- [ ] Label lengths appropriate for orientation (vertical <15 char, horizontal <50 char)
- [ ] Color count <=6 distinct colors
- [ ] Stacked segments <=4 (if applicable)
- [ ] Line series <=3 (if applicable)
- [ ] Bars anchored at zero (no truncated y-axis)
- [ ] Decimal precision <=2 places
- [ ] Chart type matches comparison intent (ranking/trend/composition/magnitude)
- [ ] Working memory load within 7±2 chunk limit
- [ ] Accessible alternative provided (data table in sr-only)

---

## References & Sources

### Perceptual Research
- Cleveland, W. S., & McGill, R. (1984). Graphical Perception: Theory, Experimentation, and Application to the Development of Graphical Methods. *Journal of the American Statistical Association*.
- Thudt, A., Walny, J., et al. (2016). Assessing the Readability of Stacked Graphs. *Graphics Interface Conference*.

### Cognitive Science
- Miller, G. A. (1956). The Magical Number Seven, Plus or Minus Two: Some Limits on Our Capacity for Processing Information. *Psychological Review*.

### Visualization Best Practices
- Few, S. (2012). *Show Me the Numbers: Designing Tables and Graphs to Enlighten*. Analytics Press.
- Few, S. (2008). Graph Selection Matrix. Perceptual Edge.
- FusionCharts. Bar Chart vs Column Chart: Best Practices.
- Government Analysis Function (UK). Accessible Charts Checklist.

### Web Sources
- [Cleveland & McGill Study](https://creativeartsadventure.wordpress.com/2017/01/02/cleveland-mcgill-graphical-perception-theory-experimentation-and-application-to-the-development-of-graphical-methods/)
- [Miller's Law Applications](https://instructionaldesignjunction.com/2021/08/23/george-a-millers-7-plus-or-minus-2-rule-and-simon-and-chases-chunking-principle/)
- [Horizontal vs Vertical Bar Charts](https://depictdatastudio.com/when-to-use-horizontal-bar-charts-vs-vertical-column-charts/)
- [Line Charts vs Bar Charts for Time Series](https://observablehq.com/blog/bars-vs-lines-time-series-data)
- [Stacked Bar Chart Cognitive Load](https://medium.com/swlh/storytelling-with-data-part-2-6f4ec8a13585)
- [Stephen Few's Graph Selection](https://www.perceptualedge.com/articles/ie/the_right_graph.pdf)

---

**End of Rulebook**
