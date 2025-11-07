#import "../src/ribbons.typ": *
#import "../src/palette.typ"

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  numbering: "1",
)

#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 24pt, weight: "bold")[typst-ribbons Examples]
  
  #v(1em)
  
  #text(size: 14pt)[A gallery of practical examples]
  
  #v(2em)
  
  #datetime.today().display()
]

#pagebreak()

#outline(indent: auto)

#pagebreak()

= Basic Examples

== Simple Sankey Diagram

A minimal example showing basic flow from sources to targets.

```typ
#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))
```

#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))

#pagebreak()

== Simple Chord Diagram

A basic circular diagram showing relationships.

```typ
#chord-diagram((
  "A": ("A": 100, "B": 50, "C": 30),
  "B": ("A": 50, "B": 80, "C": 40),
  "C": ("A": 30, "B": 40, "C": 60),
))
```

#chord-diagram((
  "A": ("A": 100, "B": 50, "C": 30),
  "B": ("A": 50, "B": 80, "C": 40),
  "C": ("A": 30, "B": 40, "C": 60),
))

#pagebreak()

= Layout Examples

== Vertical Sankey Diagram

Top-to-bottom flow instead of left-to-right.

```typ
#sankey-diagram(
  (
    "Revenue": ("Gross Profit": 1000, "COGS": 600),
    "Gross Profit": ("Net Income": 300, "Expenses": 700),
  ),
  layout: layout.auto-linear(vertical: true)
)
```

#sankey-diagram(
  (
    "Revenue": ("Gross Profit": 1000, "COGS": 600),
    "Gross Profit": ("Net Income": 300, "Expenses": 700),
  ),
  layout: layout.auto-linear(vertical: true)
)

#pagebreak()

== Directed Chord Diagram

Showing asymmetric flow in circular layout.

```typ
#chord-diagram(
  (
    "Export": ("Import": 500, "Export": 200),
    "Import": ("Export": 300, "Import": 400),
  ),
  layout: layout.circular(directed: true)
)
```

#chord-diagram(
  (
    "Export": ("Import": 500, "Export": 200),
    "Import": ("Export": 300, "Import": 400),
  ),
  layout: layout.circular(directed: true)
)

#pagebreak()

== Compact Sankey

Tight spacing for fitting more in less space.

```typ
#sankey-diagram(
  (
    "A": ("B": 10, "C": 8, "D": 5),
    "B": ("E": 8, "F": 2),
    "C": ("E": 3, "F": 5),
    "D": ("F": 5),
  ),
  layout: layout.auto-linear(
    layer-gap: 1,
    node-gap: 0.5,
    node-width: 0.15,
    base-node-height: 2,
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 10, "C": 8, "D": 5),
    "B": ("E": 8, "F": 2),
    "C": ("E": 3, "F": 5),
    "D": ("F": 5),
  ),
  layout: layout.auto-linear(
    layer-gap: 1,
    node-gap: 0.5,
    node-width: 0.15,
    base-node-height: 2,
  )
)

#pagebreak()

= Color and Style Examples

== Layer-Based Coloring

Different color for each layer.

```typ
#sankey-diagram(
  (
    "Source": ("Process": 100),
    "Process": ("Output A": 60, "Output B": 40),
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, green, purple)
  )
)
```

#sankey-diagram(
  (
    "Source": ("Process": 100),
    "Process": ("Output A": 60, "Output B": 40),
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, green, purple)
  )
)

#pagebreak()

== Custom Node Colors

Manually specified colors for each node.

```typ
#sankey-diagram(
  (
    "Input": ("Process": 100),
    "Process": ("Good": 80, "Waste": 20),
  ),
  tinter: tinter.dict-tinter((
    "Input": blue,
    "Process": green,
    "Good": purple,
    "Waste": red,
  ))
)
```

#sankey-diagram(
  (
    "Input": ("Process": 100),
    "Process": ("Good": 80, "Waste": 20),
  ),
  tinter: tinter.dict-tinter((
    "Input": blue,
    "Process": green,
    "Good": purple,
    "Waste": red,
  ))
)

#pagebreak()

== Gradient Ribbons

Ribbons with gradients from source to target.

```typ
#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 8),
    "C": ("D": 7),
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
    stroke-color: white,
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 8),
    "C": ("D": 7),
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
    stroke-color: white,
  )
)

#pagebreak()

== Categorical Coloring

Grouping nodes by category.

```typ
#sankey-diagram(
  (
    "Coal": ("Power": 100),
    "Solar": ("Power": 50),
    "Power": ("City": 150),
  ),
  categories: (
    "Coal": "fossil",
    "Solar": "renewable",
    "Power": "processing",
    "City": "consumption",
  ),
  tinter: tinter.categorical-tinter(
    palette: (gray, green, yellow, purple)
  )
)
```

#sankey-diagram(
  (
    "Coal": ("Power": 100),
    "Solar": ("Power": 50),
    "Power": ("City": 150),
  ),
  categories: (
    "Coal": "fossil",
    "Solar": "renewable",
    "Power": "processing",
    "City": "consumption",
  ),
  tinter: tinter.categorical-tinter(
    palette: (gray, green, yellow, purple)
  )
)

#pagebreak()

= Practical Use Cases

== Budget Breakdown

Company budget allocation visualization.

```typ
#sankey-diagram(
  (
    "Budget": ("Development": 500, "Marketing": 300, "Operations": 200),
    "Development": ("Salaries": 400, "Tools": 100),
    "Marketing": ("Advertising": 200, "Events": 100),
    "Operations": ("Rent": 100, "Utilities": 50, "Other": 50),
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 2.5,
    curve-factor: 0.4,
  ),
  tinter: tinter.layer-tinter(
    palette: palette.tableau
  ),
  ribbon-stylizer: ribbon-stylizer.match-from(
    transparency: 70%,
  )
)
```

#sankey-diagram(
  (
    "Budget": ("Development": 500, "Marketing": 300, "Operations": 200),
    "Development": ("Salaries": 400, "Tools": 100),
    "Marketing": ("Advertising": 200, "Events": 100),
    "Operations": ("Rent": 100, "Utilities": 50, "Other": 50),
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 2.5,
    curve-factor: 0.4,
  ),
  tinter: tinter.layer-tinter(
    palette: palette.tableau
  ),
  ribbon-stylizer: ribbon-stylizer.match-from(
    transparency: 70%,
  )
)

#pagebreak()

== Energy Flow

Renewable energy distribution.

```typ
#sankey-diagram(
  (
    "Solar": ("Battery": 100, "Grid": 50),
    "Wind": ("Battery": 80, "Grid": 60),
    "Battery": ("Homes": 150, "Industry": 30),
    "Grid": ("Homes": 80, "Industry": 30),
  ),
  aliases: (
    "Solar": "Solar Panels",
    "Wind": "Wind Turbines",
    "Battery": "Battery Storage",
    "Grid": "Power Grid",
    "Homes": "Residential",
    "Industry": "Industrial",
  ),
  categories: (
    "Solar": "source",
    "Wind": "source",
    "Battery": "storage",
    "Grid": "distribution",
    "Homes": "consumption",
    "Industry": "consumption",
  ),
  tinter: tinter.categorical-tinter(
    palette: (green, yellow, blue, purple)
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 60%,
    stroke-width: 0.5pt,
  )
)
```

#sankey-diagram(
  (
    "Solar": ("Battery": 100, "Grid": 50),
    "Wind": ("Battery": 80, "Grid": 60),
    "Battery": ("Homes": 150, "Industry": 30),
    "Grid": ("Homes": 80, "Industry": 30),
  ),
  aliases: (
    "Solar": "Solar Panels",
    "Wind": "Wind Turbines",
    "Battery": "Battery Storage",
    "Grid": "Power Grid",
    "Homes": "Residential",
    "Industry": "Industrial",
  ),
  categories: (
    "Solar": "source",
    "Wind": "source",
    "Battery": "storage",
    "Grid": "distribution",
    "Homes": "consumption",
    "Industry": "consumption",
  ),
  tinter: tinter.categorical-tinter(
    palette: (green, yellow, blue, purple)
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 60%,
    stroke-width: 0.5pt,
  )
)

#pagebreak()

== User Journey

Website user flow funnel.

```typ
#sankey-diagram(
  (
    "Visitors": ("Homepage": 10000),
    "Homepage": ("Product Page": 5000, "Blog": 3000, "Exit": 2000),
    "Product Page": ("Cart": 2000, "Exit": 3000),
    "Blog": ("Product Page": 1000, "Exit": 2000),
    "Cart": ("Checkout": 1500, "Exit": 500),
    "Checkout": ("Purchase": 1200, "Exit": 300),
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, cyan, green, yellow, orange, red)
  )
)
```

#sankey-diagram(
  (
    "Visitors": ("Homepage": 10000),
    "Homepage": ("Product": 5000, "Blog": 3000, "Exit": 2000),
    "Product": ("Cart": 2000, "Exit": 3000),
    "Blog": ("Product": 1000, "Exit": 2000),
    "Cart": ("Checkout": 1500, "Exit": 500),
    "Checkout": ("Purchase": 1200, "Exit": 300),
  ),
  aliases: (
    "Product": "Product Page",
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, eastern, green, yellow, orange, red)
  )
)

#pagebreak()

== Trade Flows

International trade between regions.

```typ
#chord-diagram(
  (
    "Asia": ("Asia": 50000, "Europe": 5000, "Americas": 8000, "Africa": 2000),
    "Europe": ("Asia": 4000, "Europe": 30000, "Americas": 6000, "Africa": 1000),
    "Americas": ("Asia": 3000, "Europe": 5000, "Americas": 40000, "Africa": 500),
    "Africa": ("Asia": 1000, "Europe": 8000, "Americas": 2000, "Africa": 25000),
  ),
  tinter: tinter.node-tinter(
    palette: palette.tableau
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 80%,
    stroke-width: 0.5pt,
    stroke-color: white,
  )
)
```

#chord-diagram(
  (
    "Asia": ("Asia": 50000, "Europe": 5000, "Americas": 8000, "Africa": 2000),
    "Europe": ("Asia": 4000, "Europe": 30000, "Americas": 6000, "Africa": 1000),
    "Americas": ("Asia": 3000, "Europe": 5000, "Americas": 40000, "Africa": 500),
    "Africa": ("Asia": 1000, "Europe": 8000, "Americas": 2000, "Africa": 25000),
  ),
  tinter: tinter.node-tinter(
    palette: palette.tableau
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 80%,
    stroke-width: 0.5pt,
    stroke-color: white,
  )
)

#pagebreak()

= Advanced Styling

== Custom Labels

```typ
#sankey-diagram(
  (
    "A": ("B": 100, "C": 50),
    "B": ("D": 80),
    "C": ("D": 50),
  ),
  draw-label: label.default-linear-label-drawer(
    styles: (
      inset: 0.3em,
      fill: blue.transparentize(80%),
      stroke: blue + 0.5pt,
      radius: 4pt,
    ),
    draw-content: (properties) => [
      #set text(fill: blue)
      #text(properties.name, size: 0.9em, weight: "bold") \
      #text(str(properties.size) + " units", size: 0.75em)
    ]
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 100, "C": 50),
    "B": ("D": 80),
    "C": ("D": 50),
  ),
  draw-label: label.default-linear-label-drawer(
    styles: (
      inset: 0.3em,
      fill: blue.transparentize(80%),
      stroke: blue + 0.5pt,
      radius: 4pt,
    ),
    draw-content: (properties) => [
      #set text(fill: blue)
      #text(properties.name, size: 0.9em, weight: "bold") \
      #text(str(properties.size) + " units", size: 0.75em)
    ]
  )
)

#pagebreak()

== Sharp Corners

```typ
#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 8),
    "C": ("D": 7),
  ),
  layout: layout.auto-linear(
    radius: 0pt,
    curve-factor: 0,
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 8),
    "C": ("D": 7),
  ),
  layout: layout.auto-linear(
    radius: 0pt,
    curve-factor: 0,
  )
)

#pagebreak()

== Multiple Edges

Showing multiple connections between same nodes.

```typ
#sankey-diagram((
  ("A", "B", 2),
  ("A", "B", 3),
  ("A", "B", 5),
  ("A", "C", 3),
  ("B", "D", 10),
  ("C", "D", 3),
))
```

#sankey-diagram((
  ("A", "B", 2),
  ("A", "B", 3),
  ("A", "B", 5),
  ("A", "C", 3),
  ("B", "D", 10),
  ("C", "D", 3),
))

#pagebreak()

= Data Format Examples

== Adjacency Dictionary

```typ
#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))
```

== Adjacency List

```typ
#sankey-diagram((
  ("A", "B", 10),
  ("A", "C", 5),
  ("B", "D", 8),
  ("C", "D", 7),
))
```

== Adjacency Matrix

```typ
#chord-diagram((
  matrix: (
    (100, 50, 30),
    (50, 80, 40),
    (30, 40, 60),
  ),
  ids: ("X", "Y", "Z")
))
```

All three produce equivalent diagrams (shown above).

#pagebreak()

= Color Palette Showcase

== ColorBrewer Palette

```typ
#sankey-diagram(
  (
    "A": ("B": 10),
    "B": ("C": 10),
    "C": ("D": 10),
    "D": ("E": 10),
  ),
  tinter: tinter.layer-tinter(
    palette: palette.color-brewer-palette
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 10),
    "B": ("C": 10),
    "C": ("D": 10),
    "D": ("E": 10),
  ),
  tinter: tinter.layer-tinter(
    palette: palette.color-brewer-palette
  )
)

#pagebreak()

== Tableau Palette

```typ
#chord-diagram(
  (
    "A": ("A": 10, "B": 5, "C": 3),
    "B": ("A": 5, "B": 8, "C": 2),
    "C": ("A": 3, "B": 2, "C": 6),
  ),
  tinter: tinter.node-tinter(
    palette: palette.tableau
  )
)
```

#chord-diagram(
  (
    "A": ("A": 10, "B": 5, "C": 3),
    "B": ("A": 5, "B": 8, "C": 2),
    "C": ("A": 3, "B": 2, "C": 6),
  ),
  tinter: tinter.node-tinter(
    palette: palette.tableau
  )
)

#pagebreak()

== Catppuccin Palette

```typ
#sankey-diagram(
  (
    "L1a": ("L2a": 5),
    "L1b": ("L2b": 5),
    "L2a": ("L3": 5),
    "L2b": ("L3": 5),
  ),
  tinter: tinter.layer-tinter(
    palette: palette.catppuccin
  )
)
```

#sankey-diagram(
  (
    "L1a": ("L2a": 5),
    "L1b": ("L2b": 5),
    "L2a": ("L3": 5),
    "L2b": ("L3": 5),
  ),
  tinter: tinter.layer-tinter(
    palette: palette.catppuccin
  )
)

#pagebreak()

#align(center)[
  #v(2em)
  End of Examples Gallery
  #v(1em)
  See `api-reference.typ` for complete API documentation
]
