# typst-ribbons

A comprehensive library for creating beautiful ribbon diagrams in Typst, including Sankey and Chord diagrams.

![Status](https://img.shields.io/badge/status-early%20development-yellow)
![License](https://img.shields.io/badge/license-TBD-blue)

## Features

- **Sankey Diagrams** - Visualize flows and distributions through systems
- **Chord Diagrams** - Show relationships in circular layouts
- **Flexible Layouts** - Horizontal, vertical, and circular arrangements
- **Rich Styling** - Gradients, custom colors, transparency, and borders
- **Multiple Data Formats** - Adjacency dictionary, list, or matrix
- **Automatic Layout** - Force-directed algorithm for optimal node positioning
- **Customizable Labels** - Full control over label appearance and content

Built on [cetz](https://github.com/cetz-package/cetz), the drawing library for Typst.

## Quick Start

```typst
#import "src/ribbons.typ": *

// Simple Sankey diagram
#sankey-diagram((
  "Input": ("Process": 100),
  "Process": ("Output": 80, "Waste": 20),
))

// Simple Chord diagram  
#chord-diagram((
  "A": ("A": 100, "B": 50),
  "B": ("A": 50, "B": 80),
))
```

## Gallery

### Sankey Diagrams

**Energy Flow**
```typst
#sankey-diagram(
  (
    "Solar": ("Battery": 100, "Grid": 50),
    "Wind": ("Battery": 80, "Grid": 60),
    "Battery": ("Homes": 150, "Industry": 30),
    "Grid": ("Homes": 80, "Industry": 30),
  ),
  tinter: tinter.categorical-tinter(),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(transparency: 60%)
)
```

**Budget Breakdown**
```typst
#sankey-diagram(
  (
    "Budget": ("Dev": 500, "Marketing": 300, "Ops": 200),
    "Dev": ("Salaries": 400, "Tools": 100),
    "Marketing": ("Ads": 200, "Events": 100),
  ),
  layout: layout.auto-linear(vertical: true)
)
```

### Chord Diagrams

**Trade Flows**
```typst
#chord-diagram(
  (
    "Asia": ("Europe": 5000, "Americas": 8000),
    "Europe": ("Asia": 4000, "Americas": 6000),
    "Americas": ("Asia": 3000, "Europe": 5000),
  ),
  tinter: tinter.node-tinter(palette: palette.tableau)
)
```

## Documentation

Comprehensive documentation is available in the `docs/` folder:

- **[API Reference](docs/api-reference.typ)** - Complete function signatures, parameters, and usage
- **[Examples Gallery](docs/examples.typ)** - Practical examples for every use case

### Key Concepts

#### Data Formats

Three formats supported:

1. **Adjacency Dictionary** (recommended)
```typst
("Source": ("Target": size, ...))
```

2. **Adjacency List**
```typst
(("from", "to", size), ...)
```

3. **Adjacency Matrix**
```typst
(matrix: ((values...), ...), ids: ("id1", "id2", ...))
```

#### Customization

**Layouts**
- `layout.auto-linear()` - Horizontal/vertical Sankey with automatic layering
- `layout.circular()` - Circular chord diagram

**Colors**
- `tinter.layer-tinter()` - Color by layer
- `tinter.node-tinter()` - Unique color per node
- `tinter.categorical-tinter()` - Color by category
- `tinter.dict-tinter()` - Manual color mapping

**Ribbon Styles**
- `ribbon-stylizer.match-from()` - Match source color
- `ribbon-stylizer.match-to()` - Match target color
- `ribbon-stylizer.gradient-from-to()` - Gradient between colors
- `ribbon-stylizer.solid-color()` - Single color for all ribbons

**Labels**
- `label.default-linear-label-drawer()` - For Sankey diagrams
- `label.default-circular-label-drawer()` - For chord diagrams

## Installation

### From Source (Current)

Clone this repository and import:

```typst
#import "path/to/typst-ribbons/src/ribbons.typ": *
```

### As Package (Coming Soon)

Once published to the Typst package registry:

```typst
#import "@preview/ribbons:0.1.0": *
```

## Examples

### Basic Sankey

```typst
#sankey-diagram((
  "A": ("B": 10, "C": 5),
  "B": ("D": 8),
  "C": ("D": 7),
))
```

### Customized Sankey

```typst
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
  )),
  ribbon-stylizer: ribbon-stylizer.gradient-from-to(
    transparency: 50%,
    stroke-width: 0.5pt,
  ),
  layout: layout.auto-linear(
    vertical: true,
    layer-gap: 3,
  )
)
```

### Chord Diagram with Custom Colors

```typst
#chord-diagram(
  (
    "black": ("black": 11975, "blond": 5871, "brown": 8916),
    "blond": ("black": 1951, "blond": 10048, "brown": 2060),
    "brown": ("black": 8010, "blond": 16145, "brown": 8090),
  ),
  tinter: tinter.dict-tinter((
    "black": rgb("#000000"),
    "blond": rgb("#ffdd89"),
    "brown": rgb("#957244"),
  ))
)
```

## Common Use Cases

- **Finance**: Budget flows, income/expense breakdowns, financial waterfalls
- **Energy**: Power generation and distribution, energy balance diagrams
- **Business**: User funnels, conversion flows, process optimization
- **Science**: Material flows, ecological networks, particle interactions
- **Demographics**: Migration patterns, population movements
- **Trade**: Import/export relationships, supply chains

## API Overview

### Main Functions

```typst
sankey-diagram(data, aliases, categories, layout, tinter, ribbon-stylizer, draw-label)
chord-diagram(data, aliases, categories, layout, tinter, ribbon-stylizer, draw-label)
```

### Layout Functions

```typst
layout.auto-linear(layer-gap, node-gap, vertical, layers, ...)
layout.circular(radius, directed, node-gap, ...)
```

### Color Functions

```typst
tinter.layer-tinter(palette)
tinter.node-tinter(palette)
tinter.categorical-tinter(palette)
tinter.dict-tinter(color-map, override)
```

### Style Functions

```typst
ribbon-stylizer.match-from(transparency, stroke-width, stroke-color)
ribbon-stylizer.match-to(transparency, stroke-width, stroke-color)
ribbon-stylizer.gradient-from-to(transparency, stroke-width, stroke-color)
ribbon-stylizer.solid-color(color, transparency, stroke-width, stroke-color)
```

### Palettes

- `palette.color-brewer-palette` - ColorBrewer Set2 (8 colors)
- `palette.tableau` - Tableau 10 (10 colors)
- `palette.catppuccin` - Catppuccin Frappé (13 colors)

## Roadmap

- [x] Core Sankey diagram functionality
- [x] Chord diagram support
- [x] Customizable colors and styling
- [x] Label positioning and customization
- [x] Multiple data format support
- [x] Comprehensive documentation
- [ ] Alluvial diagrams
- [ ] Animation support
- [ ] Interactive features
- [ ] Performance optimizations for large datasets
- [ ] Package publication to Typst registry

## Contributing

Contributions are welcome! This project is in early development. Feel free to:

- Report bugs or issues
- Suggest new features
- Submit pull requests
- Improve documentation

## Credits

- Built with [cetz](https://github.com/cetz-package/cetz) by Johannes Wolf
- Inspired by [SankeyMatic](https://sankeymatic.com) and [D3.js](https://d3js.org)
- Color palettes from ColorBrewer, Tableau, and Catppuccin
- Demo data adapted from various public datasets

## License

To be determined (likely MIT or Apache 2.0)

## Links

- Documentation: See `docs/api-reference.typ`
- Examples: See `docs/examples.typ`
- Demo: See `demo.typ`

---

Made with ❤️ for the Typst community
