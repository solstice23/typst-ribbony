#import "../src/ribbons.typ": *

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
)

#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 24pt, weight: "bold")[typst-ribbons]
  
  #v(0.5em)
  
  #text(size: 16pt)[Quick Start Guide]
  
  #v(2em)
]

= Introduction

typst-ribbons makes it easy to create beautiful flow diagrams in Typst. This guide will get you started in 5 minutes.

= Installation

Import the library:

```typ
#import "src/ribbons.typ": *
```

= Your First Diagram

== Simple Sankey

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

That's it! You created a Sankey diagram showing flow from A through B and C to D.

#pagebreak()

== Simple Chord

```typ
#chord-diagram((
  "X": ("X": 100, "Y": 50),
  "Y": ("X": 50, "Y": 80),
))
```

#chord-diagram((
  "X": ("X": 100, "Y": 50),
  "Y": ("X": 50, "Y": 80),
))

A circular chord diagram showing relationships between X and Y.

= Common Customizations

== Vertical Layout

```typ
#sankey-diagram(
  (
    "Top": ("Middle": 100),
    "Middle": ("Bottom": 100),
  ),
  layout: layout.auto-linear(vertical: true)
)
```

#sankey-diagram(
  (
    "Top": ("Middle": 100),
    "Middle": ("Bottom": 100),
  ),
  layout: layout.auto-linear(vertical: true)
)

#pagebreak()

== Custom Colors

```typ
#sankey-diagram(
  (
    "Red": ("Green": 50),
    "Green": ("Blue": 50),
  ),
  tinter: tinter.dict-tinter((
    "Red": red,
    "Green": green,
    "Blue": blue,
  ))
)
```

#sankey-diagram(
  (
    "Red": ("Green": 50),
    "Green": ("Blue": 50),
  ),
  tinter: tinter.dict-tinter((
    "Red": red,
    "Green": green,
    "Blue": blue,
  ))
)

== Prettier Ribbons

```typ
#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 10),
    "C": ("D": 5),
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
  )
)
```

#sankey-diagram(
  (
    "A": ("B": 10, "C": 5),
    "B": ("D": 10),
    "C": ("D": 5),
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
  )
)

#pagebreak()

= Real-World Example

Here's a complete example showing a company budget:

```typ
#sankey-diagram(
  (
    "Revenue": ("Expenses": 800, "Profit": 200),
    "Expenses": (
      "Salaries": 500,
      "Marketing": 200,
      "Operations": 100,
    ),
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 2.5,
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, orange, green)
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 60%,
  )
)
```

#sankey-diagram(
  (
    "Revenue": ("Expenses": 800, "Profit": 200),
    "Expenses": (
      "Salaries": 500,
      "Marketing": 200,
      "Operations": 100,
    ),
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 2.5,
  ),
  tinter: tinter.layer-tinter(
    palette: (blue, orange, green)
  ),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 60%,
  )
)

#pagebreak()

= Next Steps

== Learn More

- Read `api-reference.typ` for complete documentation
- Browse `examples.typ` for more use cases
- Check out `demo.typ` for complex examples

== Key Parameters to Explore

*Layout:*
- `vertical: true` - Top-to-bottom flow
- `layer-gap` - Space between columns
- `node-gap` - Space between nodes

*Colors:*
- `tinter.layer-tinter()` - Color by stage
- `tinter.dict-tinter()` - Custom colors
- `palette.tableau` - Use different color schemes

*Ribbons:*
- `gradient-from-to()` - Gradient ribbons
- `transparency` - Adjust transparency (0-100%)
- `stroke-width` - Add borders

*Labels:*
- `draw-label: none` - Hide labels
- Custom label content and styling

== Common Patterns

*Budget/Finance:*
```typ
layout: layout.auto-linear(vertical: true)
tinter: tinter.layer-tinter()
```

*Energy/Flow:*
```typ
tinter: tinter.categorical-tinter()
ribbon-stylizer: ribbon-stylizer.gradient-from-to()
```

*Relationships:*
```typ
chord-diagram(...)
tinter: tinter.node-tinter()
```

= Tips

1. Start simple, add styling gradually
2. Use `vertical: true` for top-down processes
3. Use dict-tinter for brand colors
4. Adjust `transparency` to 50-70% for readability
5. Add `stroke-width: 0.5pt` for clearer separation

= Getting Help

- Check the API reference for function details
- Look at examples.typ for similar use cases
- Experiment with parameters - most are optional!

#align(center)[
  #v(2em)
  Happy diagramming! 🎨
]
