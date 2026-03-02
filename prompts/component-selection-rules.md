# Component Selection Rules
## Algorithmic Framework for MPP Real Estate Reports

**Purpose**: Deterministic component selection using mandatory evaluation steps. Execute in order - no skipping.

**Reference**: See `chart-selection-rulebook.md` for research citations and thresholds.

---

## MANDATORY EXECUTION ORDER

You MUST complete Steps 1-4 in sequence. Populate output fields as you go.

```
STEP 1: Data Inventory  -->  dataInventory{}
STEP 2: Evaluate Each   -->  dataEvaluation{}
STEP 3: Select Components --> componentSelections{}
STEP 4: Validate        -->  validationPassed: true/false
```

If `validationPassed: false`, return to Step 3 and correct.

---

## STEP 1: Data Inventory

Scan the extracted JSON and record what data types are present.

```json
{
  "dataInventory": {
    "hasTrendOverTime": true/false,
    "hasDistributionByCategory": true/false,
    "hasPeriodComparison": true/false,
    "hasTopEntitiesRanking": true/false,
    "hasCompositionSplit": true/false,
    "hasRentalMetrics": true/false,
    "hasPriceInsightsTable": true/false,
    "hasBinaryRatio": true/false,
    "hasEntityComparison": true/false,
    "hasVolumeWithYield": true/false,
    "hasSegmentMetrics": true/false
  }
}
```

**Rule**: Only proceed to Step 2 for data types marked `true`.

---

## STEP 2: Evaluate Data Characteristics

For EACH data type present, calculate these metrics BEFORE selecting a component.

### 2A. Time-Series Data (trendOverTimeGraph)

```
COUNT points array length -> pointCount
CALCULATE consecutive changes:
  - IF all changes same sign -> trendDirection: "consistent"
  - IF mixed signs -> trendDirection: "volatile"
COUNT distinct series -> seriesCount
IDENTIFY metric type:
  - "price" (price per sqft, average price)
  - "yield" (rental yield percentage)
  - "index" (price index, growth index)
  - "growth_rate" (YoY growth, appreciation rate)
  - "volume" (transaction count, total value)
  - "other"
CHECK if cumulative/trajectory emphasis desired -> continuityEmphasis
  - true: filled area reinforces magnitude over time
  - false: line-only sufficient
CHECK if exact period values are primary need -> exactValuesPreferred
  - true: reader needs to read specific numbers
  - false: reader wants to see the shape/trend
IF seriesCount >= 2:
  CHECK if trend comparison between entities is the insight -> trendComparisonDesired
    - true: reader wants to see "who's outperforming?"
    - false: reader just needs to see individual trends
  IDENTIFY series entities:
    - "communities" (Dubai Marina, Business Bay, etc.)
    - "property_types" (apartment, villa, townhouse)
    - "bedroom_types" (Studio, 1BR, 2BR, etc.)
    - "other"
```

**Output**:
```json
{
  "dataEvaluation": {
    "trendOverTime": {
      "pointCount": 6,
      "trendDirection": "consistent",
      "seriesCount": 2,
      "metricType": "price",
      "continuityEmphasis": true,
      "exactValuesPreferred": false,
      "trendComparisonDesired": true,
      "seriesEntityType": "communities"
    }
  }
}
```

### 2B. Categorical Data (distributionByCategoryGraph)

```
COUNT categories in points array -> categoryCount
CALCULATE max(values) / min(values) -> varianceRatio
MEASURE longest label character count -> maxLabelLength
COUNT periods in data -> periodCount (1 = snapshot, 2+ = comparison)
IDENTIFY metric type:
  - "transactions" (count of deals)
  - "volume" (total value)
  - "count" (inventory, listings)
  - "other"
CHECK if relative ranking is the insight -> rankingVisibilityDesired
  - true: reader wants to see "who's biggest/smallest"
  - false: reader just needs the numbers
```

**Output**:
```json
{
  "dataEvaluation": {
    "distribution": {
      "categoryCount": 5,
      "varianceRatio": 3.2,
      "maxLabelLength": 12,
      "periodCount": 1,
      "metricType": "transactions",
      "rankingVisibilityDesired": true
    }
  }
}
```

### 2C. Composition Data (compositionSplitByEntityGraph)

```
COUNT distinct components (segments within each bar) -> componentCount
COUNT categories (bars on x-axis) -> categoryCount
CALCULATE max component percentage -> dominantComponentPct
CHECK if all components within 10% of each other -> isBalanced
CHECK if components sum to 100% -> sumsTo100
CHECK if comparing composition across categories -> crossCategoryComparison
  - true: multiple bars, comparing mix patterns
  - false: single bar showing one entity's composition
```

**Output**:
```json
{
  "dataEvaluation": {
    "composition": {
      "componentCount": 2,
      "categoryCount": 5,
      "dominantComponentPct": 78,
      "isBalanced": false,
      "sumsTo100": true,
      "crossCategoryComparison": true
    }
  }
}
```

### 2D. Ranking Data (topEntitiesByVolumeGraph)

```
COUNT entities -> entityCount
MEASURE longest entity name character count -> maxNameLength
COUNT periods in data -> periodCount (should be 1 for pure rankings)
COUNT metrics per entity -> metricCount (should be 1 for bar chart)
CHECK if data is pre-sorted by rank -> isPreSorted
IDENTIFY metric type:
  - "transactions" (count of deals)
  - "volume" (total value)
  - "price" (price per sqft, average price)
  - "yield" (rental yield percentage)
  - "other"
```

**Output**:
```json
{
  "dataEvaluation": {
    "rankings": {
      "entityCount": 10,
      "maxNameLength": 24,
      "periodCount": 1,
      "metricCount": 1,
      "isPreSorted": true,
      "metricType": "transactions"
    }
  }
}
```

### 2E. Period Comparison Data (periodOverPeriodComparisonGraph)

```
COUNT periods being compared -> periodCount
COUNT categories within each period -> categoriesPerPeriod
IDENTIFY metric type:
  - "price" (average price, price per sqft)
  - "volume" (transaction count, total value)
  - "rate" (yield, growth rate)
CHECK if visual comparison is primary intent -> visualComparisonDesired
  - true: reader wants to SEE the change at a glance
  - false: reader needs exact numbers for calculation/reporting
IDENTIFY comparison granularity:
  - "yoy" (year-over-year)
  - "qoq" (quarter-over-quarter)
  - "hoh" (half-over-half)
```

**Output**:
```json
{
  "dataEvaluation": {
    "periodComparison": {
      "periodCount": 2,
      "categoriesPerPeriod": 5,
      "metricType": "price",
      "visualComparisonDesired": true,
      "comparisonGranularity": "yoy"
    }
  }
}
```

### 2F. Binary Ratio Data (contract splits, property type splits)

```
CHECK if two values sum to 100% -> isBinaryRatio
IDENTIFY ratio type:
  - "contract" (new vs renewal)
  - "property" (off-plan vs ready)
  - "other"
CHECK if YoY change data available -> hasYoYContext
CHECK if visual proportion is desired -> visualProportionDesired
  - true: reader wants to SEE the proportional split
  - false: reader just needs the numbers
CALCULATE max value percentage -> dominantCategoryPct
CHECK if related split exists (e.g., transactions AND value) -> hasRelatedSplit
```

**Output**:
```json
{
  "dataEvaluation": {
    "binaryRatio": {
      "isBinaryRatio": true,
      "ratioType": "property",
      "hasYoYContext": false,
      "values": [69.3, 30.7],
      "visualProportionDesired": true,
      "dominantCategoryPct": 69.3,
      "hasRelatedSplit": true
    }
  }
}
```

### 2G. Entity Comparison Data (community vs community, property type comparisons)

```
COUNT entities being compared -> entityCount
COUNT attributes per entity -> attributeCount
CHECK if attributes are qualitative -> isQualitative
CHECK if purpose is option evaluation -> isOptionEvaluation
```

**Output**:
```json
{
  "dataEvaluation": {
    "entityComparison": {
      "entityCount": 2,
      "attributeCount": 6,
      "isQualitative": true,
      "isOptionEvaluation": true,
      "entities": ["Business Bay", "Dubai Marina"]
    }
  }
}
```

### 2H. Volume-Yield Pairing Data (transactions with yield metrics)

```
CHECK if primary metric is volume-based -> hasVolumePrimary
  - transactions count
  - total value
CHECK if secondary metric is efficiency-based -> hasEfficiencySecondary
  - yield percentage
  - growth rate
DETERMINE hierarchy -> metricsHierarchy: "volume-first" | "yield-first"
```

**Output**:
```json
{
  "dataEvaluation": {
    "volumeYield": {
      "hasVolumePrimary": true,
      "hasEfficiencySecondary": true,
      "metricsHierarchy": "volume-first",
      "primaryMetric": "178 transactions",
      "secondaryMetric": "5.3% yield"
    }
  }
}
```

### 2I. Segment-Metrics Data (structured numeric tables)

```
IDENTIFY row dimension type:
  - "bedroom" (Studio, 1BR, 2BR, 3BR, etc.)
  - "property_type" (apartment, villa, townhouse)
  - "community" (sub-community names)
  - "time_period" (months, quarters, years)
COUNT rows -> rowCount
IDENTIFY column metrics:
  - price (AED values, price per sqft)
  - volume (transaction count, total value)
  - change (YoY %, MoM %)
  - yield (rental yield %)
COUNT numeric columns -> metricCount
CHECK cell value types -> cellValueType: "numeric" | "mixed" | "text"
```

**Output**:
```json
{
  "dataEvaluation": {
    "segmentMetrics": {
      "rowDimension": "bedroom",
      "rowCount": 5,
      "metricColumns": ["price", "transactions", "yoy_change", "yield"],
      "metricCount": 4,
      "cellValueType": "numeric",
      "isStructuredNumeric": true
    }
  }
}
```

---

## STEP 3: Select Components Using Decision Rules

Apply these rules IN ORDER. First matching rule wins.

### 3A. Time-Series Selection (area-line)

Use `area-line` when presenting a single metric's trajectory over 3+ time periods where:
- The visual story is "what's the trend direction and momentum?"
- Continuous progression matters (quarterly, monthly, yearly)
- The filled area emphasizes cumulative growth or magnitude
- Single series, single metric

**Structure**: X-axis = time periods, Y-axis = values, Area fill reinforces trend

```
IF pointCount == 1:
    SKIP chart, use KPI only
    NOTE: "Single data point - no trend to visualize"

ELSE IF pointCount == 2:
    // Redirect to grouped-column for 2-period comparison
    GOTO 3E
    NOTE: "Two periods detected - use grouped-column for comparison"

ELSE IF pointCount >= 3:
    IF exactValuesPreferred == true:
        SELECT "data-table"
        NOTE: "Exact values primary need - table format preferred"

    ELSE IF seriesCount == 1:
        SELECT "area-line"
        NOTE: "Single-series trend over {pointCount} periods"

        IF trendDirection == "consistent" AND continuityEmphasis == true:
            ADD areaFill: true
            NOTE: "Consistent trend - area fill reinforces magnitude"
        ELSE:
            ADD areaFill: false
            NOTE: "Volatile trend - line-only for clarity"

    ELSE IF seriesCount == 2 OR seriesCount == 3:
        SELECT "multi-line"
        NOTE: "Multiple series ({seriesCount}) - no area fill, lines only"

    ELSE IF seriesCount >= 4:
        SELECT "data-table"
        NOTE: "Exceeds 3-line limit for readability ({seriesCount} series)"
```

**area-line vs grouped-column vs data-table vs column**:
| Aspect | area-line | grouped-column | data-table | column |
|--------|-----------|----------------|------------|--------|
| Purpose | Trend over 3+ periods | 2-period comparison | Exact values | Single period distribution |
| Question | "What's the trajectory?" | "How did it change?" | "What are all the numbers?" | "What's the spread?" |
| Structure | Continuous flow | Discrete comparison | Rows = time | Categories on X-axis |
| Time axis | X-axis | Categories (not time) | Rows | N/A |
| Series | 1 (with area fill) | 1 metric, 2 periods | Any | 1 |

**Real estate area-line use cases**:
- Price per sqft trend over quarters
- Rental yield progression over years
- Transaction volume trend by quarter
- Price index movement over time
- Average sales price trajectory

**When NOT to use area-line**:
| Scenario | Use Instead |
|----------|-------------|
| Only 2 time periods | `grouped-column` |
| Multiple series to compare | `multi-line` (no fill) |
| Comparing categories, not time | `column` or `bar` |
| Exact values matter more than shape | `data-table` |
| Single data point | KPI display |

### 3A-2. Multi-Series Time-Series Selection (multi-line)

Use `multi-line` when presenting the same metric's trajectory across 2-4 entities over 3+ time periods where:
- The visual story is "how do these compare over time?"
- Trend comparison between entities is the insight (convergence, divergence, volatility)
- Relative performance matters more than absolute values
- Limited series count (2-4) to maintain readability

**Structure**: X-axis = time periods, Y-axis = values, Color = entities (no area fill)

```
IF pointCount >= 3 AND seriesCount >= 2:
    IF exactValuesPreferred == true:
        SELECT "data-table"
        NOTE: "Exact values primary need - table format preferred"

    ELSE IF seriesCount >= 2 AND seriesCount <= 4:
        IF trendComparisonDesired == true:
            SELECT "multi-line"
            NOTE: "Trend comparison of {seriesCount} {seriesEntityType} over {pointCount} periods"
        ELSE:
            // Consider separate area-line charts or data-table
            SELECT "multi-line"
            NOTE: "Multiple series - lines only, no area fill"

    ELSE IF seriesCount > 4:
        SELECT "data-table"
        NOTE: "Too many series ({seriesCount} > 4) - lines become unreadable"
        ADD narrativeNote: "Consider splitting into multiple charts or grouping entities"

ELSE IF pointCount == 2 AND seriesCount >= 2:
    // Redirect to grouped-column for 2-period comparison
    GOTO 3E
    NOTE: "Two periods with multiple categories - use grouped-column"
```

**multi-line vs area-line vs grouped-column vs stacked-column**:
| Aspect | multi-line | area-line | grouped-column | stacked-column |
|--------|------------|-----------|----------------|----------------|
| Purpose | Multiple series over time | Single series over time | 2 periods, multiple categories | Composition over categories |
| Question | "Who's outperforming?" | "What's the trend?" | "How did each change?" | "What's the mix?" |
| Insight | Trajectory comparison | Single trajectory | Point-in-time delta | Part-to-whole |
| Series | 2-4 series | 1 series | 2 time periods | 2-3 components |
| Time points | 3+ periods | 3+ periods | 2 periods | N/A (categories) |

**Real estate multi-line use cases**:
- Price trends across communities (Dubai Marina vs Business Bay vs JBR)
- Yield comparison across property types over quarters
- Transaction volume trends by sub-community
- Rental growth trajectories by bedroom type
- Price index comparison across areas

**When NOT to use multi-line**:
| Scenario | Use Instead |
|----------|-------------|
| Single entity trend | `area-line` |
| Only 2 time periods | `grouped-column` |
| More than 4 series | `data-table` (or split into multiple charts) |
| Composition comparison | `stacked-column` |
| Exact values at each point critical | `data-table` |
| Series don't share same metric | Separate charts |

### 3B. Categorical/Distribution Selection (column)

Use `column` when presenting a single metric distributed across categories for one time period where:
- The visual story is "which segment has the most/least?"
- Categories are discrete and limited (3-7 segments ideal)
- Relative magnitude between categories is the insight
- No time comparison needed - just a snapshot

**Structure**: X-axis = categories, Y-axis = values, Single color

```
IF periodCount == 1:
    IF categoryCount >= 3 AND categoryCount <= 7:
        IF maxLabelLength <= 15:
            IF rankingVisibilityDesired == true:
                SELECT "column"
                NOTE: "Single-period distribution: {categoryCount} categories, visual ranking"
            ELSE:
                SELECT "data-table"
                NOTE: "Exact values preferred over visual ranking"
        ELSE:
            SELECT "bar"
            NOTE: "Labels too long for vertical bars ({maxLabelLength} chars > 15)"

    ELSE IF categoryCount >= 8 AND categoryCount <= 12:
        SELECT "bar"
        NOTE: "Approaching cognitive load limit - horizontal for readability"

    ELSE IF categoryCount > 12:
        SELECT "data-table"
        NOTE: "Exceeds chart readability threshold ({categoryCount} > 12)"

    ELSE IF categoryCount < 3:
        SKIP chart, use inline KPIs
        NOTE: "Too few categories for meaningful chart"

ELSE IF periodCount == 2:
    // Redirect to grouped-column selection (3E)
    GOTO 3E
    NOTE: "Two periods detected - use grouped-column for comparison"

ELSE IF periodCount > 2:
    SELECT "multi-line" OR "data-table"
    NOTE: "Multiple periods - treat as time series"
```

**column vs grouped-column vs data-table**:
| Aspect | column | grouped-column | data-table |
|--------|--------|----------------|------------|
| Periods | 1 (snapshot) | 2 (comparison) | Any |
| Question | "Who's biggest?" | "Who changed most?" | "What are all the numbers?" |
| Insight | Visual ranking | Visual delta | Precision lookup |
| Colors | Single | Two (period) | N/A |

**Real estate column use cases**:
- Transaction volume by bedroom type (single period)
- Number of listings by sub-community
- Total sales value by property type
- Inventory count by price band

**When NOT to use column**:
| Scenario | Use Instead |
|----------|-------------|
| Comparing two time periods | `grouped-column` |
| Binary ratio summing to 100% | `comparison-cards` or `stacked-column` |
| More than 7 categories | `bar` (horizontal) |
| Labels longer than 15 chars | `bar` (horizontal) |
| More than 12 categories | `data-table` |
| Multiple metrics per category | `data-table` |
| Exact values matter more than visual | `data-table` |

### 3C. Composition Selection (stacked-column)

Use `stacked-column` when presenting part-to-whole composition across multiple categories where:
- The visual story is "how does the mix vary across segments?"
- Each bar represents 100% of a category, split into 2-3 components
- Comparing composition patterns across categories is the insight
- Binary or ternary splits (not 5+ segments stacked)

**Structure**: X-axis = categories, Y-axis = percentage (0-100%), Color = components

```
IF sumsTo100 == true:
    IF crossCategoryComparison == true:
        IF categoryCount >= 2:
            IF componentCount == 2 OR componentCount == 3:
                SELECT "stacked-column"
                NOTE: "Composition comparison: {componentCount} components across {categoryCount} categories"

            ELSE IF componentCount == 4:
                SELECT "stacked-column"
                NOTE: "At maximum component limit - consider simplifying to 3"

            ELSE IF componentCount > 4:
                SELECT "data-table"
                NOTE: "Too many components ({componentCount} > 4) - stacked bars become unreadable"

    ELSE IF crossCategoryComparison == false:
        // Single category with binary split
        IF categoryCount == 1 AND componentCount == 2:
            SELECT "comparison-cards"
            NOTE: "Single binary split - use card display instead of chart"

IF dominantComponentPct > 90:
    ADD narrativeNote: "Near-total dominance ({dominantComponentPct}%) - chart may be visually misleading"

IF isBalanced == true:
    ADD narrativeNote: "Balanced split - visual differences will be subtle"
```

**stacked-column vs column vs grouped-column vs comparison-cards**:
| Aspect | stacked-column | column | grouped-column | comparison-cards |
|--------|----------------|--------|----------------|------------------|
| Purpose | Composition across categories | Single metric distribution | Period comparison | Single binary ratio |
| Question | "How does the mix differ?" | "Who's biggest?" | "Who changed most?" | "What's the split?" |
| Structure | Multiple categories, 2-3 components | Multiple categories, 1 metric | Multiple categories, 2 periods | 1 category, 2 values |
| Insight type | Part-to-whole | Absolute values | Before/after | Text display |

**Real estate stacked-column use cases**:
- Off-plan vs Ready split across communities
- New vs Renewal contracts by sub-community
- Buyer nationality composition by area
- Transaction type mix (cash vs mortgage) by property type

**When NOT to use stacked-column**:
| Scenario | Use Instead |
|----------|-------------|
| Single category binary split | `comparison-cards` |
| Absolute values matter more than proportions | `grouped-column` or `column` |
| More than 3 components | `data-table` |
| Time series composition | Stacked area chart (if available) or `data-table` |
| Components don't sum to 100% | `grouped-column` |

### 3D. Ranking Selection (bar)

Use `bar` (horizontal) when presenting ranked data where category labels are long or numerous where:
- The visual story is "who's #1, #2, #3...?"
- Categories have text labels that need horizontal space (community names, property names)
- Pre-sorted ranking order matters
- Single metric, single time period

**Structure**: Y-axis = categories (ranked top-to-bottom), X-axis = values, Horizontal orientation

```
IF visualization_goal == "ranking":
    IF periodCount == 1 AND metricCount == 1:
        IF entityCount >= 5 AND entityCount <= 15:
            SELECT "bar"
            NOTE: "Ranking of {entityCount} entities by {metricType}"

        ELSE IF entityCount > 15:
            SELECT "bar"
            TRUNCATE to top 10
            ADD note: "Showing top 10 of {entityCount} - full list in data table"

        ELSE IF entityCount < 5:
            IF maxNameLength <= 10:
                SELECT "column"
                NOTE: "Few entities with short labels - vertical works"
            ELSE:
                SELECT "bar"
                NOTE: "Long labels require horizontal orientation"

    ELSE IF periodCount == 2:
        // Redirect to grouped-column for period comparison
        GOTO 3E
        NOTE: "Two periods detected - use grouped-column for comparison"

    ELSE IF metricCount > 1:
        SELECT "data-table"
        NOTE: "Multiple metrics per entity requires table format"

// Label length override
IF maxNameLength > 10:
    PREFER "bar" over "column"
    NOTE: "Labels exceed 10 chars - horizontal for readability"

// Always ensure data is sorted
IF isPreSorted == false:
    ADD narrativeNote: "Data should be sorted by rank before rendering"
```

**bar vs column vs data-table**:
| Aspect | bar (horizontal) | column (vertical) | data-table |
|--------|------------------|-------------------|------------|
| Purpose | Rankings with long labels | Distribution with short labels | Multi-metric detail |
| Question | "Who's the leader?" | "What's the spread?" | "What are all the numbers?" |
| Reading direction | Top-to-bottom | Left-to-right | Row scanning |
| Entity count | 5-15 categories | 3-7 categories | Any number |
| Label length | >10 characters | <=10 characters | Any length |

**Real estate bar use cases**:
- Top communities by transaction volume
- Top developers by units sold
- Top buildings by price per sqft
- Sub-community ranking by rental yield
- Top projects by total sales value

**When NOT to use bar**:
| Scenario | Use Instead |
|----------|-------------|
| Short labels with few categories (<=5, labels <=10 chars) | `column` |
| Period-over-period comparison | `grouped-column` |
| Multiple metrics per category | `data-table` |
| Composition/part-to-whole | `stacked-column` |
| More than 15 entities | `data-table` (with top 10 bar chart summary) |

### 3E. Period Comparison Selection (grouped-column)

Use `grouped-column` when presenting the same metric across categories, compared between exactly 2 time periods where:
- The visual story is "how did each segment change year-over-year?"
- Categories are discrete and limited (3-6 segments ideal)
- Both absolute values and relative change matter
- Side-by-side bar comparison reveals the pattern faster than reading a table

**Structure**: X-axis = categories, Y-axis = values, Color = time period

```
IF periodCount == 2:
    IF categoriesPerPeriod >= 3 AND categoriesPerPeriod <= 6:
        IF visualComparisonDesired == true:
            SELECT "grouped-column"
            NOTE: "Visual comparison of 2 periods across {categoriesPerPeriod} categories"
        ELSE:
            SELECT "data-table"
            NOTE: "Exact values preferred over visual comparison"

    ELSE IF categoriesPerPeriod > 6:
        SELECT "data-table"
        NOTE: "Too many categories for grouped bars ({categoriesPerPeriod} > 6)"

    ELSE IF categoriesPerPeriod < 3:
        SELECT "grouped-column"
        NOTE: "Minimal categories - consider if chart adds value"

ELSE IF periodCount > 2:
    SELECT "multi-line"
    NOTE: "Treat as time series - periods become x-axis points"

ELSE IF periodCount == 1:
    SELECT "column"
    NOTE: "Single period - no comparison needed"
```

**grouped-column vs alternatives**:
| Aspect | grouped-column | data-table | multi-line |
|--------|----------------|------------|------------|
| Purpose | Visual comparison of 2 periods | Exact numbers for many periods | Trend over many periods |
| Reader intent | "See the change" | "Read the change" | "Follow the trajectory" |
| Categories | 3-6 categories | Any number of rows | Continuous time series |
| Insight type | Direction + magnitude at a glance | Precision lookup | Pattern recognition |

**Real estate grouped-column use cases**:
- Average price by bedroom: Q3 2024 vs Q3 2025
- Transaction volume by property type: H1 vs H2
- Rental rates by community: 2024 vs 2025
- Price per sqft by sub-community: current vs prior year

**When NOT to use grouped-column**:
| Scenario | Use Instead |
|----------|-------------|
| Single period data | `column` |
| More than 2 periods | `multi-line` or `data-table` |
| Exact values matter more than visual comparison | `data-table` |
| Binary ratio (sums to 100%) | `comparison-cards` |
| More than 6 categories | `data-table` |

### 3F. KPI Display Selection

```
IF hasVolumeWithYield:
    // Volume + efficiency pairing with clear hierarchy
    IF metricsHierarchy == "volume-first":
        SELECT "indicators-block"
        NOTE: "Primary card = volume metric, secondary = yield/rate"
    ELSE:
        SELECT "kpi-strip"
        NOTE: "Metrics are peer-level, no hierarchy"

ELSE IF rentalMetrics.present AND rentalMetrics.isPrimaryFocus:
    SELECT "indicators-block"
    NOTE: "Rental-focused display with yield emphasis"

ELSE:
    SELECT "kpi-strip"
```

**indicators-block vs kpi-strip**:
| Condition | Component | Reason |
|-----------|-----------|--------|
| 1 headline + 1-2 supporting metrics | `indicators-block` | Clear primary/secondary hierarchy |
| Volume (transactions/value) + yield | `indicators-block` | "How much activity" + "how efficient" |
| 4 peer-level KPIs | `kpi-strip` | Equal importance, no hierarchy |
| Rental-focused report | `indicators-block` | Emphasize yield with gradient card |

### 3G. Binary Ratio Selection (stacked-bar or comparison-cards)

Use `stacked-bar` when presenting a two-category split where visual proportion is desired:
- The visual story is "see the proportional split at a glance"
- Binary split (exactly 2 categories summing to 100%)
- Neither category exceeds 90% (if >90%, bar becomes visually meaningless)
- Visual representation adds value over simple text display

**Structure**: Horizontal bar with two segments, widths proportional to percentages

```
IF hasBinaryRatio:
    IF isBinaryRatio AND values sum to 100%:
        IF dominantCategoryPct > 90:
            SELECT "indicators-block"
            NOTE: "Extreme ratio ({dominantCategoryPct}%) - use indicator card instead"

        ELSE IF visualProportionDesired == true:
            IF hasRelatedSplit:
                SELECT "stacked-bar" with variant "stacked-bar-dual"
                NOTE: "Two related binary splits - show side by side"
            ELSE:
                SELECT "stacked-bar"
                NOTE: "Binary split with visual proportion ({values[0]}% / {values[1]}%)"

        ELSE:
            SELECT "comparison-cards"
            NOTE: "Binary split display (e.g., 41.6% new vs 58.4% renewal)"

    IF hasYoYContext:
        ADD secondaryDisplay: "YoY change annotations"
```

**stacked-bar vs comparison-cards**:
| Aspect | stacked-bar | comparison-cards |
|--------|-------------|------------------|
| Purpose | Visual proportion of binary split | Text display of values |
| Question | "See the proportional split" | "What are the numbers?" |
| Structure | Horizontal bar with 2 colored segments | Two cards with values |
| Best when | Visual proportion adds insight | Numbers are sufficient |
| Avoid when | One category >90% | Visual comparison needed |

**stacked-bar use cases**:
| Scenario | Use stacked-bar? | Alternative |
|----------|------------------|-------------|
| "Off-plan vs ready transactions" (69/31) | YES | - |
| "New vs renewal contracts" (76/24) | YES | - |
| "99.5% Ready, 0.5% Off-plan" | NO | `indicators-block` |
| "Transactions AND value split side-by-side" | YES (`stacked-bar-dual`) | - |
| "How has the split changed over 5 years?" | NO | `stacked-column` or `area-line` |
| "Same split across 5 communities" | NO | `stacked-column` |
| Just need the numbers, no visual | NO | `comparison-cards` |

**comparison-cards use cases**:
| Scenario | Use comparison-cards? | Alternative |
|----------|----------------------|-------------|
| "What's the new vs renewal split?" (text only) | YES | `stacked-bar` (if visual desired) |
| Primary metric + its YoY change | YES | - |
| Two complementary KPIs (same category) | YES | - |

### 3H. Entity Comparison Selection (comparison-table)

```
IF hasEntityComparison:
    IF entityCount == 2:
        IF attributeCount >= 4 AND attributeCount <= 10:
            IF isQualitative OR isOptionEvaluation:
                SELECT "comparison-table"
                NOTE: "Side-by-side comparison: rows=attributes, cols=entities"

        ELSE IF attributeCount > 10:
            SELECT "data-table"
            NOTE: "Too many attributes for comparison format"

        ELSE IF attributeCount < 4:
            SKIP table, use inline comparison in narrative

    ELSE IF entityCount >= 3 AND entityCount <= 4:
        IF isQualitative:
            SELECT "comparison-table"
            NOTE: "Multi-option comparison (max 4 columns)"
        ELSE:
            SELECT "data-table"

    ELSE IF entityCount > 4:
        SELECT "data-table"
        NOTE: "Too many entities for side-by-side comparison"
```

**comparison-table vs data-table**:
| Aspect | comparison-table | data-table |
|--------|------------------|------------|
| Purpose | "Which option fits my needs?" | "What are the numbers?" |
| Columns | 2-4 options being compared | Often many data columns |
| Rows | Features/criteria/attributes | Entities (bedrooms, periods) |
| Cell values | Primarily text/categorical | Primarily numeric |
| Structure | Feature x Option matrix | Entity x Metrics matrix |

**Real estate comparison-table use cases**:
- Community A vs Community B amenities/characteristics
- Developer payment plan options
- Property type comparisons (villa vs townhouse vs apartment)
- Investment strategy trade-offs

**NOT for**: Bedroom-by-bedroom price breakdowns (use `data-table`)

### 3I. Data Table Selection (segment-metrics)

Use `data-table` when presenting structured numeric data across a categorical dimension where:
- Rows represent segments of the same entity type
- Columns are consistent metrics repeated for each row
- The reader needs to scan/compare specific values, not evaluate qualitative trade-offs

```
IF isStructuredNumeric == true:
    IF rowDimension IN ["bedroom", "property_type", "community", "time_period"]:
        IF metricCount >= 2:
            IF cellValueType == "numeric":
                SELECT "data-table"
                NOTE: "Segment-metrics structure: rows={rowDimension}, cols={metricColumns}"

// Also use data-table as fallback when other components exceed limits:
IF categoryCount > 12:
    SELECT "data-table"
    NOTE: "Exceeds chart readability threshold"

IF segmentCount > 4:
    SELECT "data-table"
    NOTE: "Exceeds stacked bar segment limit"

IF seriesCount > 3:
    SELECT "data-table"
    NOTE: "Exceeds line chart series limit"

IF entityCount > 4 AND NOT isQualitative:
    SELECT "data-table"
    NOTE: "Too many entities for comparison format"
```

**data-table structure**:
| Component | Structure | Purpose |
|-----------|-----------|---------|
| Rows | Segments of same category (bedrooms, periods, communities) | "What are the numbers for each segment?" |
| Columns | Consistent metrics (price, transactions, YoY, yield) | Repeated measurement across segments |
| Cells | Numeric values (currency, percentage, count) | Scanning and value lookup |

**data-table vs comparison-table**:
| Aspect | data-table | comparison-table |
|--------|------------|------------------|
| Question answered | "What are the numbers for each segment?" | "Which option should I choose?" |
| Row content | Instances of same category | Evaluation criteria/features |
| Column content | Numeric metrics | Options being compared |
| Cell values | Homogeneous (all numeric) | Heterogeneous (text/categorical) |
| Reader intent | Scanning for values | Decision-making |

**Real estate data-table use cases**:
- Bedroom breakdown: price, transactions, YoY change
- Sub-community performance metrics
- Monthly/quarterly transaction summaries
- Rental vs sale metrics by property type
- Price per sqft by configuration
- Historical price trends (multi-period)

**NOT for**:
- Qualitative feature comparisons (use `comparison-table`)
- Binary splits (use `comparison-cards`)
- Rankings by single metric (use `bar`)

---

## STEP 4: Validation Checklist

Run these checks. ALL must pass.

```
CHECK 1: Category limits
  - Vertical bar categories <= 10
  - Horizontal bar categories <= 15
  - Stacked bar segments <= 4

CHECK 2: Series limits
  - Line chart series <= 3

CHECK 3: Label compatibility
  - Vertical bar labels <= 15 characters
  - Horizontal bar labels <= 50 characters

CHECK 4: No anti-patterns
  - No pie charts selected
  - No dual-axis charts
  - No 3D effects referenced
  - Bars anchored at zero (no truncated axis)

CHECK 5: Data-component match
  - Rankings use bar (horizontal)
  - Time series 6+ points use area-line or multi-line
  - Composition uses stacked-column (not pie)
```

**Output**:
```json
{
  "validation": {
    "categoryLimitsOK": true,
    "seriesLimitsOK": true,
    "labelCompatibilityOK": true,
    "noAntiPatterns": true,
    "dataComponentMatch": true,
    "validationPassed": true
  }
}
```

IF any check fails:
1. Log the failure in `validationErrors[]`
2. Return to Step 3
3. Select the next-best component per rules
4. Re-run validation

---

## STEP 5: Record Selection Rationale

For EACH component selected, document:

```json
{
  "componentSelectionRationale": {
    "priceTrend": {
      "evaluatedMetrics": "pointCount: 6, trendDirection: consistent, seriesCount: 1",
      "ruleApplied": "pointCount >= 6 AND seriesCount == 1 -> area-line",
      "selectedComponent": "area-line",
      "additionalConfig": "areaFill: true (consistent trend)",
      "alternativeRejected": "column (loses trend continuity with 6+ points)"
    }
  }
}
```

---

## Component ID Reference

Use these exact IDs in `componentSelections`:

| ID | Standard Name | Use For |
|----|---------------|---------|
| `kpi-strip` | KPI Strip | Primary metrics display (4 peer-level KPIs) |
| `indicators-block` | Indicators Block | Volume + yield pairing (hierarchical metrics) |
| `comparison-cards` | Comparison Cards | Binary ratios (text display), metric + YoY pairs |
| `stacked-bar` | Stacked Bar | Binary ratio with visual proportion (horizontal part-to-whole) |
| `area-line` | Area Line Chart | Time series trend (single series, 6+ points) |
| `multi-line` | Multi-Line Chart | Time series comparison (2-3 series) |
| `column` | Column Chart | Categorical distribution (3-7 items, short labels) |
| `grouped-column` | Grouped Column Chart | Period-over-period comparison (2 periods) |
| `stacked-column` | Stacked Column Chart | Part-to-whole composition across categories (2-4 segments) |
| `bar` | Bar Chart | Rankings, long labels (horizontal) |
| `data-table` | Data Table | Segment-metrics (bedrooms, periods, communities with numeric columns) |
| `comparison-table` | Comparison Table | Qualitative feature comparison (2-4 entities) |

---

## Real Estate Domain Overrides

These rules OVERRIDE generic selection when applicable:

| Condition | Override |
|-----------|----------|
| Bedroom type distribution | Order by bedroom count (Studio, 1BR, 2BR...), NOT by volume |
| Community rankings | ALWAYS use `bar` (names average 20 chars) |
| YoY comparison available | PREFER `grouped-column` over single-period chart |
| Rental yield > 7% | Use `indicators-block` to emphasize yield |
| Price trend declining | Use `area-line` WITHOUT area fill (avoid amplifying negative) |
| Transaction count shown | Include as secondary annotation, not separate chart |
| Off-plan vs ready split (visual) | Use `stacked-bar` for visual proportion (neither category >90%) |
| Off-plan vs ready split (text only) | Use `comparison-cards` for simple text display |
| Off-plan vs ready across communities | Use `stacked-column` for cross-entity comparison |
| New vs renewal contracts (visual) | Use `stacked-bar` for visual proportion display |
| Transactions AND value split | Use `stacked-bar-dual` for side-by-side related splits |
| Extreme ratio (>90% one category) | Use `indicators-block` (e.g., "99.5% Ready") |
| Community A vs B comparison | Use `comparison-table` for qualitative attributes |

---

## Output Schema

Your final output must include:

```json
{
  "dataInventory": {
    "hasTrendOverTime": true,
    "hasDistributionByCategory": true,
    "hasPeriodComparison": false,
    "hasTopEntitiesRanking": true,
    "hasCompositionSplit": true,
    "hasRentalMetrics": true,
    "hasPriceInsightsTable": true,
    "hasBinaryRatio": true,
    "hasEntityComparison": false,
    "hasVolumeWithYield": true,
    "hasSegmentMetrics": true
  },
  "dataEvaluation": {
    "periodComparison": {
      "periodCount": 2,
      "categoriesPerPeriod": 5,
      "metricType": "price",
      "visualComparisonDesired": true,
      "comparisonGranularity": "yoy"
    },
    "segmentMetrics": {
      "rowDimension": "bedroom",
      "rowCount": 5,
      "metricColumns": ["price", "transactions", "yoy_change"],
      "metricCount": 3,
      "cellValueType": "numeric",
      "isStructuredNumeric": true
    }
  },
  "componentSelections": {
    "kpiDisplay": "kpi-strip",
    "rentalMetrics": "indicators-block",
    "priceTrend": "area-line",
    "volumeDistribution": "column",
    "periodComparison": "grouped-column",
    "rankings": "bar",
    "composition": "stacked-column",
    "priceBreakdown": "data-table",
    "binaryRatioVisual": "stacked-bar",
    "binaryRatioText": "comparison-cards",
    "entityComparison": "comparison-table",
    "segmentMetrics": "data-table"
  },
  "componentSelectionRationale": { ... },
  "validation": {
    "validationPassed": true,
    "validationErrors": []
  }
}
```

**Note**: Only include component selections for data types present in dataInventory.

---

*Version 2.0 - January 2026*
*v1.1: Initial standardized component IDs*
*v1.2: Added selection rules for comparison-cards, comparison-table, indicators-block*
*v1.3: Added dedicated data-table selection rules (2I, 3I) with segment-metrics evaluation*
*v1.4: Enhanced grouped-column selection rules (2E, 3E) with visual comparison criteria*
*v1.5: Enhanced column selection rules (2B, 3B) with single-period snapshot criteria and ranking intent*
*v1.6: Enhanced stacked-column selection rules (2C, 3C) with cross-category composition criteria*
*v1.7: Enhanced bar selection rules (2D, 3D) with ranking criteria and label length thresholds*
*v1.8: Enhanced area-line selection rules (2A, 3A) with trend trajectory and continuity emphasis*
*v1.9: Added dedicated multi-line selection rules (3A-2) with trend comparison criteria*
*v2.0: Added stacked-bar selection rules (3G) for binary ratio with visual proportion*
*Reference: chart-component-reference.md for complete ID cross-reference and CSS class mappings*
