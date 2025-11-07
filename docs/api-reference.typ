#import "../src/ribbons.typ": *

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  numbering: "1",
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
)

#set heading(numbering: "1.1")
#show link: underline

#align(center)[
  #text(size: 24pt, weight: "bold")[typst-ribbons]
  
  #v(0.5em)
  
  #text(size: 18pt)[Complete API Reference]
  
  #v(1em)
  
  #text(size: 14pt)[A comprehensive library for creating ribbon diagrams in Typst]
  
  #v(2em)
  
  Version 0.1.0 (Development)
  
  #v(0.5em)
  
  #datetime.today().display()
]

#pagebreak()

#outline(indent: auto, depth: 3)

#pagebreak()

= Introduction

typst-ribbons is a powerful library for creating various types of ribbon/flow diagrams in Typst, including:

- *Sankey diagrams* - for visualizing flow and distribution through a system
- *Chord diagrams* - for showing relationships between entities in a circular layout  
- Custom ribbon diagrams with flexible layouts and styling

Built on top of #link("https://github.com/cetz-package/cetz")[cetz], typst-ribbons provides a high-level, declarative API for creating beautiful flow visualizations with minimal code.

== Installation

For development, use local import:

```typ
#import "src/ribbons.typ": *
```

== Quick Start

```typ
// Simple Sankey diagram
#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))
```

#pagebreak()

= Main Diagram Functions

These are the primary functions you'll use to create diagrams.

== ribbon-diagram()

The base function for creating any ribbon diagram. Most users will use `sankey-diagram()` or `chord-diagram()` instead.

=== Signature

```typ
ribbon-diagram(
  data,
  aliases: (:),
  categories: (:),
  layout: layout.auto-linear(),
  tinter: tinter.default-tinter(),
  ribbon-stylizer: ribbon-stylizer.default(),
  draw-label: none,
)
```

=== Parameters

/ data (various): Input data in one of the supported formats. See Data Formats section.

/ aliases (dictionary): Map of node IDs to display names. Default: `(:)`
  - *Type:* `dictionary<string, string>`
  - *Purpose:* Show user-friendly names instead of IDs
  - *Example:* `("prod_a": "Product A")`

/ categories (dictionary): Map of node IDs to category names for categorical coloring. Default: `(:)`
  - *Type:* `dictionary<string, string>`
  - *Purpose:* Group nodes by category for coloring
  - *Example:* `("coal": "fossil", "solar": "renewable")`

/ layout (function): Layout algorithm function. Default: `layout.auto-linear()`
  - *Type:* `(function, function)` - tuple of (layouter, drawer)
  - *Purpose:* Controls node positioning and rendering

/ tinter (function): Color assignment function. Default: `tinter.default-tinter()`
  - *Type:* `function: nodes -> nodes`
  - *Purpose:* Assigns colors to nodes

/ ribbon-stylizer (function): Styling function for ribbons. Default: `ribbon-stylizer.default()`
  - *Type:* `function: (color, color, string, string, ...) -> dictionary`
  - *Purpose:* Defines ribbon appearance (color, borders, etc.)

/ draw-label (function or none): Label drawing function. Default: `none`
  - *Type:* `function | none`
  - *Purpose:* If `none`, no labels are drawn

=== Return Value

Returns: *content* - The rendered diagram

=== Example

```typ
#ribbon-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 8),
  ),
  aliases: (
    "A": "Input",
    "B": "Process", 
    "D": "Output",
  ),
)
```

#pagebreak()

== sankey-diagram()

Creates a Sankey diagram with linear (left-to-right or top-to-bottom) layout.

=== Signature

```typ
sankey-diagram(
  data,
  aliases: (:),
  categories: (:),
  layout: layout.auto-linear(),
  tinter: tinter.default-tinter(),
  ribbon-stylizer: ribbon-stylizer.default(),
  draw-label: label.default-linear-label-drawer(),
  ..args
)
```

=== Parameters

Same as `ribbon-diagram()`, with defaults optimized for Sankey diagrams.

=== Return Value

Returns: *content* - The rendered Sankey diagram

=== Example 1: Basic Sankey

```typ
#sankey-diagram((
  "A": ("B": 5, "C": 3),
  "B": ("D": 2, "E": 4),
  "C": ("D": 3, "E": 4),
))
```

//#image("../demo-images/sankey-basic.png", width: 80%) (if rendered)

=== Example 2: Vertical Layout

```typ
#sankey-diagram(
  (
    "Revenue": ("Gross": 1000, "COGS": 600),
    "Gross": ("Net": 300, "Expenses": 700),
  ),
  layout: layout.auto-linear(vertical: true)
)
```

=== Example 3: Multiple Edges

```typ
#sankey-diagram((
  ("A", "B", 2),
  ("A", "B", 3),  // Second edge A -> B
  ("A", "C", 3),
  ("B", "D", 5),
))
```

=== Example 4: Custom Styled

```typ
#sankey-diagram(
  (
    "Input": ("Process": 100),
    "Process": ("Output": 80, "Waste": 20),
  ),
  tinter: tinter.dict-tinter((
    "Input": blue,
    "Process": green,
    "Output": purple,
    "Waste": red,
  )),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
  )
)
```

#pagebreak()

== chord-diagram()

Creates a circular chord diagram showing relationships between nodes.

=== Signature

```typ
chord-diagram(
  data,
  aliases: (:),
  categories: (:),
  layout: layout.circular(),
  tinter: tinter.default-tinter(),
  ribbon-stylizer: ribbon-stylizer.default(),
  draw-label: label.default-circular-label-drawer(),
  ..args
)
```

=== Parameters

Same as `ribbon-diagram()`, with defaults optimized for chord diagrams.

=== Return Value

Returns: *content* - The rendered chord diagram

=== Example 1: Symmetric Relationships

```typ
#chord-diagram((
  "A": ("A": 100, "B": 50, "C": 30),
  "B": ("A": 50, "B": 80, "C": 40),
  "C": ("A": 30, "B": 40, "C": 60),
))
```

=== Example 2: Directed Flow

```typ
#chord-diagram(
  (
    "Export": ("Import": 500),
    "Import": ("Export": 300),
  ),
  layout: layout.circular(directed: true)
)
```

=== Example 3: Matrix Format

```typ
#chord-diagram((
  matrix: (
    (100, 50, 30),
    (50, 80, 40),
    (30, 40, 60),
  ),
  ids: ("A", "B", "C")
))
```

=== Example 4: Custom Colors

```typ
#chord-diagram(
  (
    "black": ("black": 11975, "blond": 5871, "brown": 8916, "red": 2868),
    "blond": ("black": 1951, "blond": 10048, "brown": 2060, "red": 6171),
    "brown": ("black": 8010, "blond": 16145, "brown": 8090, "red": 8045),
    "red": ("black": 1013, "blond": 990, "brown": 940, "red": 6907)
  ),
  tinter: tinter.dict-tinter((
    "black": rgb("#000000"),
    "blond": rgb("#ffdd89"),
    "brown": rgb("#957244"),
    "red": rgb("#f26223"),
  ))
)
```

#pagebreak()

= Data Formats

typst-ribbons supports three input data formats.

== Format 1: Adjacency Dictionary (Recommended)

A dictionary where keys are node IDs and values define outgoing edges.

=== Simple Format

```typ
(
  "source": ("target": size, ...),
  ...
)
```

*Type signature:* `dictionary<string, dictionary<string, number | array<number>>>`

=== Example: Basic

```typ
#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))
```

=== Example: Multiple Edges

```typ
#sankey-diagram((
  "A": ("B": (3, 5, 2)),  // Three edges from A to B
  "B": ("C": 10),
))
```

=== Detailed Format with Attributes

```typ
(
  "source": (
    (to: "target", size: value, styles: ...),
    ...
  ),
)
```

*Type signature:* `dictionary<string, array<dictionary>>`

=== Example: Per-Edge Styling

```typ
#sankey-diagram((
  "A": (
    (to: "B", size: 10, styles: (fill: red.transparentize(80%))),
    (to: "C", size: 5, styles: (fill: blue.transparentize(80%))),
  ),
  "B": ((to: "D", size: 10),),
))
```

#pagebreak()

== Format 2: Adjacency List

An array of edge tuples.

=== Signature

```typ
(
  (from, to, size),
  (from, to, size, attributes),
  ...
)
```

*Type signature:* `array<(string, string, number, ?dictionary)>`

=== Example: Basic

```typ
#sankey-diagram((
  ("A", "B", 10),
  ("A", "C", 5),
  ("B", "D", 8),
  ("C", "D", 7),
))
```

=== Example: With Attributes

```typ
#sankey-diagram((
  ("A", "B", 10, (styles: (fill: red.transparentize(80%)))),
  ("A", "C", 5),
  ("B", "D", 10),
))
```

== Format 3: Adjacency Matrix

A dictionary with `matrix` and `ids` keys.

=== Signature

```typ
(
  matrix: ((values...), (values...), ...),
  ids: ("node1", "node2", ...)
)
```

*Type signature:* `(matrix: array<array<number>>, ids: array<string>)`

=== Example

```typ
#chord-diagram((
  matrix: (
    (0, 10, 5),
    (0, 0, 8),
    (0, 0, 7),
  ),
  ids: ("A", "B", "D")
))
```

Where `matrix[i][j]` = flow from `ids[i]` to `ids[j]`.

#pagebreak()

= Layout Functions

== layout.auto-linear()

Creates left-to-right or top-to-bottom Sankey diagram.

=== Signature

```typ
layout.auto-linear(
  layer-gap: 2,
  node-gap: 1.5,
  node-width: 0.25,
  base-node-height: 3,
  min-node-height: 0.1,
  centerize-layer: false,
  vertical: false,
  layers: (:),
  radius: 2pt,
  curve-factor: 0.3,
)
```

=== Parameters

/ layer-gap (number): Horizontal space between layers. Default: `2`
  - *Type:* `number`
  - *Purpose:* Controls spacing in flow direction
  - *Typical range:* 1-4

/ node-gap (number): Minimum vertical space between nodes. Default: `1.5`
  - *Type:* `number`
  - *Purpose:* Prevents node overlap
  - *Typical range:* 0.5-3

/ node-width (number): Width of node rectangles. Default: `0.25`
  - *Type:* `number`
  - *Purpose:* Thickness in flow direction
  - *Typical range:* 0.1-0.5

/ base-node-height (number): Height for largest node. Default: `3`
  - *Type:* `number`
  - *Purpose:* Scales all node heights
  - *Typical range:* 2-5

/ min-node-height (number): Minimum node height. Default: `0.1`
  - *Type:* `number`
  - *Purpose:* Ensures tiny nodes are visible

/ centerize-layer (boolean): Center nodes within each layer. Default: `false`
  - *Type:* `boolean`
  - *Effect:* `true` = symmetrical, `false` = force-directed

/ vertical (boolean): Use top-to-bottom layout. Default: `false`
  - *Type:* `boolean`
  - *Effect:* Rotates entire diagram 90°

/ layers (dictionary): Manual layer assignments. Default: `(:)`
  - *Type:* `dictionary<string, integer>`
  - *Purpose:* Override automatic layer calculation
  - *Example:* `("A": 0, "B": 1, "C": 2)`

/ radius (length): Corner radius for nodes. Default: `2pt`
  - *Type:* `length`
  - *Common values:* `0pt` (sharp), `2pt` (subtle), `4pt` (rounded)

/ curve-factor (number): Ribbon curvature. Default: `0.3`
  - *Type:* `number`
  - *Range:* 0.0 (straight) to 1.0 (very curved)

=== Return Value

Returns: `(layouter: function, drawer: function)`

=== Example 1: Default

```typ
#sankey-diagram(
  data,
  layout: layout.auto-linear()
)
```

=== Example 2: Vertical with Wide Gaps

```typ
#sankey-diagram(
  data,
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 3,
    node-gap: 2,
  )
)
```

=== Example 3: Manual Layers

```typ
#sankey-diagram(
  (
    "A": ("B": 10),
    "B": ("C": 10),
    "X": ("C": 5),
  ),
  layout: layout.auto-linear(
    layers: (
      "A": 0,
      "X": 0,  // Force X to same layer as A
      "B": 1,
      "C": 2,
    )
  )
)
```

=== Example 4: Sharp and Straight

```typ
#sankey-diagram(
  data,
  layout: layout.auto-linear(
    radius: 0pt,
    curve-factor: 0,
  )
)
```

=== Example 5: Compact

```typ
#sankey-diagram(
  data,
  layout: layout.auto-linear(
    layer-gap: 1,
    node-gap: 0.5,
    node-width: 0.15,
    base-node-height: 2,
  )
)
```

#pagebreak()

== layout.circular()

Creates circular chord diagram.

=== Signature

```typ
layout.circular(
  radius: 4,
  node-width: 0.5,
  node-gap: 1deg,
  angle-offset: 0deg,
  directed: false,
)
```

=== Parameters

/ radius (number): Circle radius. Default: `4`
  - *Type:* `number`
  - *Purpose:* Overall diagram size
  - *Typical range:* 3-6

/ node-width (number): Radial width of node arcs. Default: `0.5`
  - *Type:* `number`
  - *Purpose:* Thickness of arc segments
  - *Typical range:* 0.3-0.8

/ node-gap (angle): Angular gap between nodes. Default: `1deg`
  - *Type:* `angle`
  - *Purpose:* Spacing between nodes
  - *Common values:* `0.5deg`-`3deg`

/ angle-offset (angle): Starting angle for first node. Default: `0deg`
  - *Type:* `angle`
  - *Purpose:* Rotates entire diagram
  - *Common values:* `0deg` (top), `90deg` (right)

/ directed (boolean): Show directional flow. Default: `false`
  - *Type:* `boolean`
  - *Effect:* `false` = merge both directions, `true` = show asymmetry

=== Return Value

Returns: `(layouter: function, drawer: function)`

=== Example 1: Basic

```typ
#chord-diagram(
  data,
  layout: layout.circular()
)
```

=== Example 2: Larger

```typ
#chord-diagram(
  data,
  layout: layout.circular(
    radius: 6,
    node-width: 0.8,
  )
)
```

=== Example 3: Directed

```typ
#chord-diagram(
  (
    "A": ("B": 100, "C": 50),
    "B": ("C": 80, "A": 30),
  ),
  layout: layout.circular(directed: true)
)
```

=== Example 4: Rotated

```typ
#chord-diagram(
  data,
  layout: layout.circular(
    angle-offset: 90deg,
    node-gap: 2deg,
  )
)
```

#pagebreak()

= Tinter Functions

Tinters assign colors to nodes.

== tinter.default-tinter()

Automatically chooses `layer-tinter()` or `node-tinter()`.

=== Signature

```typ
tinter.default-tinter(
  palette: palette.default-palette
)
```

=== Parameters

/ palette (array): Array of colors. Default: `palette.default-palette`
  - *Type:* `array<color>`

=== Return Value

Returns: `function: nodes -> nodes`

=== Example

```typ
#sankey-diagram(
  data,
  tinter: tinter.default-tinter()
)
```

== tinter.layer-tinter()

Colors nodes by layer index.

=== Signature

```typ
tinter.layer-tinter(
  palette: palette.default-palette
)
```

=== Parameters

/ palette (array): Array of colors.
  - *Type:* `array<color>`
  - *Algorithm:* `color[layer_index mod palette.length]`

=== Return Value

Returns: `function: nodes -> nodes`

=== Example 1: Default Palette

```typ
#sankey-diagram(
  data,
  tinter: tinter.layer-tinter()
)
```

=== Example 2: Custom Palette

```typ
#sankey-diagram(
  data,
  tinter: tinter.layer-tinter(
    palette: (red, orange, yellow, green, blue)
  )
)
```

== tinter.node-tinter()

Colors each node uniquely by index.

=== Signature

```typ
tinter.node-tinter(
  palette: palette.default-palette
)
```

=== Parameters

/ palette (array): Array of colors.
  - *Type:* `array<color>`
  - *Algorithm:* `color[node_index mod palette.length]`

=== Return Value

Returns: `function: nodes -> nodes`

=== Example

```typ
#chord-diagram(
  data,
  tinter: tinter.node-tinter(
    palette: palette.tableau
  )
)
```

== tinter.categorical-tinter()

Colors nodes by category.

=== Signature

```typ
tinter.categorical-tinter(
  palette: palette.default-palette
)
```

=== Parameters

/ palette (array): Array of colors.
  - *Type:* `array<color>`
  - *Note:* Requires `categories` parameter in main diagram function

=== Return Value

Returns: `function: nodes -> nodes`

=== Example

```typ
#sankey-diagram(
  (
    "Coal": ("Power": 100),
    "Solar": ("Grid": 50),
    "Power": ("Grid": 100),
    "Grid": ("City": 150),
  ),
  categories: (
    "Coal": "fossil",
    "Solar": "renewable",
    "Power": "processing",
    "Grid": "distribution",
    "City": "consumption",
  ),
  tinter: tinter.categorical-tinter(
    palette: (gray, green, yellow, blue, purple)
  )
)
```

== tinter.dict-tinter()

Manual color specification.

=== Signature

```typ
tinter.dict-tinter(
  color-map,
  override: none
)
```

=== Parameters

/ color-map (dictionary): Node ID to color mapping.
  - *Type:* `dictionary<string, color>`
  - *Purpose:* Explicit color control

/ override (function or none): Fallback tinter. Default: `none`
  - *Type:* `function | none`
  - *Purpose:* Colors unspecified nodes

=== Return Value

Returns: `function: nodes -> nodes`

=== Example 1: Basic

```typ
#sankey-diagram(
  data,
  tinter: tinter.dict-tinter((
    "A": red,
    "B": blue,
    "C": green,
  ))
)
```

=== Example 2: With Fallback

```typ
#sankey-diagram(
  data,
  tinter: tinter.dict-tinter(
    (
      "Critical": red,
      "Warning": orange,
    ),
    override: tinter.layer-tinter()
  )
)
```

=== Example 3: RGB Colors

```typ
#chord-diagram(
  data,
  tinter: tinter.dict-tinter((
    "A": rgb("#FF5733"),
    "B": rgb("#33FF57"),
    "C": rgb("#3357FF"),
  ))
)
```

#pagebreak()

= Color Palettes

Pre-defined color palettes.

== palette.default-palette

Alias for `palette.color-brewer-palette`.

== palette.color-brewer-palette

ColorBrewer Set2 (8 colors).

*Colors:*
```typ
(
  rgb("#66C2A5"), rgb("#FC8D62"), rgb("#8DA0CB"), rgb("#E78AC3"),
  rgb("#A6D854"), rgb("#FFD92F"), rgb("#E5C494"), rgb("#B3B3B3")
)
```

=== Example

```typ
tinter: tinter.layer-tinter(
  palette: palette.color-brewer-palette
)
```

== palette.tableau

Tableau 10 (10 colors).

*Colors:*
```typ
(
  rgb("#1F77B4"), rgb("#FF7F0E"), rgb("#2CA02C"), rgb("#D62728"),
  rgb("#9467BD"), rgb("#8C564B"), rgb("#E377C2"), rgb("#7F7F7F"),
  rgb("#BCBD22"), rgb("#17BECF")
)
```

=== Example

```typ
tinter: tinter.node-tinter(
  palette: palette.tableau
)
```

== palette.catppuccin

Catppuccin Frappé (13 colors).

*Colors:*
```typ
(
  rgb("#e78284"), rgb("#a6d189"), rgb("#e5c890"), rgb("#8caaee"),
  rgb("#f4b8e4"), rgb("#81c8be"), rgb("#ca9ee6"), rgb("#ea999c"),
  rgb("#85c1dc"), rgb("#ef9f76"), rgb("#99d1db"), rgb("#eebebe"),
  rgb("#f2d5cf")
)
```

=== Example

```typ
tinter: tinter.layer-tinter(
  palette: palette.catppuccin
)
```

#pagebreak()

= Ribbon Stylizer Functions

Control ribbon appearance.

== ribbon-stylizer.default()

Auto-selects appropriate styling.

=== Signature

```typ
ribbon-stylizer.default()
```

=== Logic

- Chord diagrams: `gradient-from-to()` with white border
- Others: `match-from()` with no border

=== Return Value

Returns: `function: (...) -> dictionary`

=== Example

```typ
ribbon-stylizer: ribbon-stylizer.default()
```

== ribbon-stylizer.match-from()

Ribbons match source node color.

=== Signature

```typ
ribbon-stylizer.match-from(
  transparency: 75%,
  stroke-width: 0pt,
  stroke-color: auto,
)
```

=== Parameters

/ transparency (percentage): Ribbon transparency. Default: `75%`
  - *Type:* `percentage`
  - *Range:* `0%` (opaque) to `100%` (invisible)

/ stroke-width (length): Border width. Default: `0pt`
  - *Type:* `length`
  - *Common values:* `0pt`, `0.5pt`, `1pt`

/ stroke-color (color or auto): Border color. Default: `auto`
  - *Type:* `color | auto`
  - *Auto:* Matches fill color

=== Return Value

Returns: `function: (from-color, to-color, from-node, to-node, ...) -> dictionary`

Returns dictionary with `fill` and `stroke` keys.

=== Example 1: Basic

```typ
ribbon-stylizer: ribbon-stylizer.match-from()
```

=== Example 2: With Border

```typ
ribbon-stylizer: ribbon-stylizer.match-from(
  transparency: 60%,
  stroke-width: 0.5pt,
  stroke-color: white,
)
```

=== Example 3: Vivid

```typ
ribbon-stylizer: ribbon-stylizer.match-from(
  transparency: 30%,
)
```

== ribbon-stylizer.match-to()

Ribbons match target node color.

=== Signature

```typ
ribbon-stylizer.match-to(
  transparency: 75%,
  stroke-width: 0pt,
  stroke-color: auto,
)
```

=== Parameters

Same as `match-from()`.

=== Return Value

Returns: `function: (...) -> dictionary`

=== Example

```typ
ribbon-stylizer: ribbon-stylizer.match-to(
  transparency: 70%,
)
```

== ribbon-stylizer.gradient-from-to()

Gradient from source to target color.

=== Signature

```typ
ribbon-stylizer.gradient-from-to(
  transparency: 75%,
  stroke-width: 0pt,
  stroke-color: auto,
)
```

=== Parameters

Same as `match-from()` and `match-to()`.

=== Return Value

Returns: `function: (...) -> dictionary`

=== Example 1: Basic

```typ
ribbon-stylizer: ribbon-stylizer.gradient-from-to()
```

=== Example 2: With Border

```typ
ribbon-stylizer: ribbon-stylizer.gradient-from-to(
  transparency: 50%,
  stroke-width: 0.5pt,
  stroke-color: white,
)
```

=== Example 3: Subtle

```typ
ribbon-stylizer: ribbon-stylizer.gradient-from-to(
  transparency: 85%,
  stroke-width: 0.2pt,
)
```

== ribbon-stylizer.solid-color()

All ribbons use single color.

=== Signature

```typ
ribbon-stylizer.solid-color(
  color: black,
  transparency: 90%,
  stroke-width: 0pt,
  stroke-color: auto,
)
```

=== Parameters

/ color (color): Ribbon color. Default: `black`
  - *Type:* `color`

/ transparency (percentage): Transparency. Default: `90%`
  - *Type:* `percentage`

/ stroke-width (length): Border width. Default: `0pt`
  - *Type:* `length`

/ stroke-color (color or auto): Border color. Default: `auto`
  - *Type:* `color | auto`

=== Return Value

Returns: `function: (...) -> dictionary`

=== Example 1: Gray

```typ
ribbon-stylizer: ribbon-stylizer.solid-color(
  color: gray,
  transparency: 80%,
)
```

=== Example 2: Subtle Black

```typ
ribbon-stylizer: ribbon-stylizer.solid-color(
  color: black,
  transparency: 95%,
  stroke-width: 0.2pt,
)
```

#pagebreak()

= Label Drawer Functions

== label.default-linear-label-drawer()

Labels for Sankey diagrams.

=== Signature

```typ
label.default-linear-label-drawer(
  snap: auto,
  offset: auto,
  width-limit: auto,
  styles: (
    inset: 0.2em,
    fill: white.transparentize(50%),
    radius: 2pt
  ),
  draw-content: (properties) => { ... }
)
```

=== Parameters

/ snap (position or auto): Label position. Default: `auto`
  - *Type:* `position | auto`
  - *Options:* `left`, `right`, `top`, `bottom`, `center`, `auto`
  - *Auto:* `right` for horizontal, `bottom` for vertical

/ offset (array or auto): Label offset. Default: `auto`
  - *Type:* `(number, number) | auto`
  - *Auto:* `(0.05, 0)` for right/bottom, `(-0.05, 0)` for left/top

/ width-limit (length, auto, or false): Max label width. Default: `auto`
  - *Type:* `length | auto | false`
  - *Auto:* 95% of `layer-gap`
  - *False:* No limit

/ styles (dictionary): Box styling. Default shown above.
  - *Type:* `dictionary`
  - *Properties:* Any box properties (inset, fill, stroke, radius, etc.)

/ draw-content (function): Content renderer. Default shows name and size.
  - *Type:* `function: properties -> content`
  - *Parameter:* `properties` - node properties dictionary
  - *Fields:* `name`, `size`, `id`, `color`, etc.

=== Return Value

Returns: `function: (node-name, properties, ...) -> content`

=== Example 1: Default

```typ
draw-label: label.default-linear-label-drawer()
```

=== Example 2: Left-Aligned

```typ
draw-label: label.default-linear-label-drawer(
  snap: left,
)
```

=== Example 3: Name Only

```typ
draw-label: label.default-linear-label-drawer(
  draw-content: (properties) => {
    text(properties.name, weight: "bold")
  }
)
```

=== Example 4: Custom Styling

```typ
draw-label: label.default-linear-label-drawer(
  styles: (
    inset: 0.3em,
    fill: blue.transparentize(80%),
    stroke: blue,
    radius: 4pt,
  ),
  draw-content: (properties) => [
    #set text(fill: blue)
    #text(properties.name, size: 0.9em) \
    #text(str(properties.size), weight: "bold")
  ]
)
```

=== Example 5: Center on Nodes

```typ
draw-label: label.default-linear-label-drawer(
  snap: center,
  styles: (fill: white, radius: 0pt),
)
```

== label.default-circular-label-drawer()

Labels for chord diagrams.

=== Signature

```typ
label.default-circular-label-drawer(
  offset: 0.2,
  styles: (
    inset: 0.2em,
    fill: white.transparentize(50%),
    radius: 2pt
  ),
  draw-content: (properties) => { ... }
)
```

=== Parameters

/ offset (number): Distance from circle edge. Default: `0.2`
  - *Type:* `number`
  - *Units:* Same as radius

/ styles (dictionary): Box styling. Same as linear drawer.
  - *Type:* `dictionary`

/ draw-content (function): Content renderer. Same as linear drawer.
  - *Type:* `function: properties -> content`

=== Return Value

Returns: `function: (node-name, properties, ...) -> content`

=== Example 1: Default

```typ
draw-label: label.default-circular-label-drawer()
```

=== Example 2: Farther

```typ
draw-label: label.default-circular-label-drawer(
  offset: 0.5,
)
```

=== Example 3: Name Only

```typ
draw-label: label.default-circular-label-drawer(
  draw-content: (properties) => {
    text(properties.name, size: 0.8em)
  }
)
```

=== Example 4: No Labels

```typ
draw-label: none
```

#pagebreak()

= Advanced Features

== Per-Edge Custom Styling

=== Using Detailed Format

```typ
#sankey-diagram((
  "A": (
    (
      to: "B",
      size: 10,
      styles: (fill: red.transparentize(80%))
    ),
    (
      to: "C",
      size: 5,
      styles: (fill: blue.transparentize(80%))
    ),
  ),
  "B": ((to: "D", size: 10),),
))
```

=== Using Dynamic Functions

```typ
#sankey-diagram((
  "A": (
    (
      to: "B",
      size: 10,
      styles: (edge, from-props, to-id, to-props) => {
        if edge.size > 5 {
          (fill: red.transparentize(70%))
        } else {
          (fill: blue.transparentize(70%))
        }
      }
    ),
  ),
))
```

== Complex Example: Energy Flow

```typ
#sankey-diagram(
  (
    "Solar": ("Battery": 100, "Grid": 50),
    "Wind": ("Battery": 80, "Grid": 60),
    "Battery": ("Home": 150, "Industry": 30),
    "Grid": ("Home": 80, "Industry": 30),
  ),
  aliases: (
    "Solar": "Solar Panels",
    "Wind": "Wind Turbines",
    "Battery": "Battery Storage",
    "Grid": "Power Grid",
    "Home": "Residential",
    "Industry": "Industrial",
  ),
  categories: (
    "Solar": "source",
    "Wind": "source",
    "Battery": "storage",
    "Grid": "distribution",
    "Home": "consumption",
    "Industry": "consumption",
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 3,
    curve-factor: 0.4,
  ),
  tinter: tinter.categorical-tinter(
    palette: (green, yellow, blue, purple)
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 60%,
    stroke-width: 0.5pt,
    stroke-color: white,
  ),
  draw-label: label.default-linear-label-drawer(
    snap: right,
    width-limit: 2.5cm,
    draw-content: (p) => [
      #text(p.name, weight: "bold", size: 0.85em) \
      #text(str(p.size) + " MW", size: 0.75em)
    ]
  )
)
```

#pagebreak()

= Complete Examples

== Example 1: Company Revenue

```typ
#sankey-diagram(
  (
    "Products": ("Revenue": 10000),
    "Services": ("Revenue": 5000),
    "Revenue": ("Operating": 8000, "Profit": 7000),
    "Operating": ("Salaries": 5000, "Marketing": 2000, "Other": 1000),
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, green, yellow, orange)
  ),
)
```

== Example 2: Migration Patterns

```typ
#chord-diagram(
  (
    "Asia": ("Asia": 50000, "Europe": 5000, "Americas": 8000),
    "Europe": ("Asia": 4000, "Europe": 30000, "Americas": 6000),
    "Americas": ("Asia": 3000, "Europe": 5000, "Americas": 40000),
  ),
  tinter: tinter.node-tinter(palette: palette.tableau),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 80%,
    stroke-width: 0.5pt,
    stroke-color: white,
  ),
)
```

== Example 3: Vertical Budget

```typ
#sankey-diagram(
  (
    "Budget": ("Dev": 500, "Marketing": 300, "Ops": 200),
    "Dev": ("Salaries": 400, "Tools": 100),
    "Marketing": ("Ads": 200, "Events": 100),
    "Ops": ("Rent": 100, "Other": 100),
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 2.5,
  ),
)
```

#pagebreak()

= Troubleshooting

== Nodes Overlap

*Solution:* Increase `node-gap`
```typ
layout: layout.auto-linear(node-gap: 2.5)
```

== Labels Cut Off

*Solutions:*
```typ
// Option 1: Wider layers
layout: layout.auto-linear(layer-gap: 3)

// Option 2: Limit width
draw-label: label.default-linear-label-drawer(
  width-limit: 2cm
)

// Option 3: Shorter text
draw-label: label.default-linear-label-drawer(
  draw-content: (p) => text(p.name, size: 0.7em)
)
```

== Wrong Colors

*Solution:* Use explicit colors
```typ
tinter: tinter.dict-tinter((
  "A": red,
  "B": blue,
))
```

== Diagram Too Small

*Solutions:*
```typ
// Sankey
layout: layout.auto-linear(
  layer-gap: 3,
  base-node-height: 4,
)

// Chord
layout: layout.circular(radius: 6)
```

#pagebreak()

= API Quick Reference

== Function Signatures

```typ
// Main functions
sankey-diagram(data, aliases, categories, layout, tinter, ribbon-stylizer, draw-label) -> content
chord-diagram(data, aliases, categories, layout, tinter, ribbon-stylizer, draw-label) -> content

// Layouts
layout.auto-linear(layer-gap, node-gap, node-width, base-node-height, min-node-height,
                   centerize-layer, vertical, layers, radius, curve-factor) -> (function, function)
layout.circular(radius, node-width, node-gap, angle-offset, directed) -> (function, function)

// Tinters
tinter.default-tinter(palette) -> function
tinter.layer-tinter(palette) -> function
tinter.node-tinter(palette) -> function
tinter.categorical-tinter(palette) -> function
tinter.dict-tinter(color-map, override) -> function

// Stylizers
ribbon-stylizer.match-from(transparency, stroke-width, stroke-color) -> function
ribbon-stylizer.match-to(transparency, stroke-width, stroke-color) -> function
ribbon-stylizer.gradient-from-to(transparency, stroke-width, stroke-color) -> function
ribbon-stylizer.solid-color(color, transparency, stroke-width, stroke-color) -> function

// Labels
label.default-linear-label-drawer(snap, offset, width-limit, styles, draw-content) -> function
label.default-circular-label-drawer(offset, styles, draw-content) -> function
```

== Parameter Defaults

#table(
  columns: (1fr, 1fr, 1fr),
  [*Function*], [*Parameter*], [*Default*],
  [`auto-linear`], [`layer-gap`], [`2`],
  [], [`node-gap`], [`1.5`],
  [], [`vertical`], [`false`],
  [`circular`], [`radius`], [`4`],
  [], [`directed`], [`false`],
  [`match-from`], [`transparency`], [`75%`],
  [], [`stroke-width`], [`0pt`],
  [`linear-label`], [`snap`], [`auto`],
  [], [`width-limit`], [`auto`],
)

= Credits

- Built with #link("https://github.com/cetz-package/cetz")[CeTZ]
- Color palettes: ColorBrewer, Tableau, Catppuccin
- Demo data: SankeyMatic, D3.js examples

#align(center)[
  #v(2em)
  End of API Reference
  #v(1em)
  typst-ribbons v0.1.0
]
