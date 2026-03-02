# Helper Functions Reference

All helper functions referenced across the HTML templates. Implement these in your language of choice.

## SIGN(value)

```
Input:  string number (e.g., "14.9", "-0.3", "0")
Output: "positive" | "negative" | "neutral"
Logic:
  parseFloat(value) > 0  -> "positive"
  parseFloat(value) < 0  -> "negative"
  parseFloat(value) == 0 -> "neutral"
```

Used for: CSS class suffixes (e.g., `kpi-card__change--positive`, `metrics-row__value--green`, `yoy-value positive`)

Note: The CSS maps these to colors:
- `positive` / `--green` -> `var(--color-positive)` (#278702)
- `negative` -> `var(--color-negative)` (#E40000)
- `neutral` -> `var(--color-text-muted)` (#6B7280)

## FORMAT_SIGN(value)

```
Input:  string number (e.g., "14.9", "-0.3", "0")
Output: "+14.9" | "-0.3" | "0"
Logic:
  if parseFloat(value) > 0, prepend "+"
  if parseFloat(value) <= 0, return as-is (negative already has minus sign)
```

Used for: Displaying YoY changes with explicit sign prefix.

## FORMAT_YOY(value)

```
Input:  string number (e.g., "14.9", "-0.3", "0")
Output: "+14.9%" | "-0.3%" | "0%"
Logic:  FORMAT_SIGN(value) + "%"
```

Used for: Table cells showing year-over-year percentage changes.

## FORMAT_DATE(isoDate)

```
Input:  "2026-01-31"
Output: "31st January 2026"
Logic:
  1. Parse the ISO date string
  2. Get the day number and append ordinal suffix:
     - 1, 21, 31 -> "st"
     - 2, 22     -> "nd"
     - 3, 23     -> "rd"
     - all others -> "th"
  3. Get the full month name (January, February, etc.)
  4. Get the 4-digit year
  5. Concatenate: "{day}{suffix} {month} {year}"
```

Used for: Source citation footer date display.

## HTML_ESCAPE(text)

```
Input:  any string
Output: HTML-safe string
Logic:
  & -> &amp;
  < -> &lt;
  > -> &gt;
  " -> &quot;
```

Used for: All user-facing text content injected into templates. Particularly important for the "Supply & Demand" title which contains an ampersand.

## wrapLastIn(text, separator, className)

```
Input:  text = "Al Furjan Apartments Resale Market Report - 2025"
        separator = " - "
        className = "highlight"
Output: 'Al Furjan Apartments Resale Market Report - <span class="highlight">2025</span>'
Logic:
  1. Split text on the last occurrence of separator
  2. Wrap the part after the separator in <span class="{className}">
  3. Rejoin with separator
```

Used for: Report header title (h1) where the year/period after " - " gets the cyan highlight color.
