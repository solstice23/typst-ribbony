# typst-ribbons Documentation

Comprehensive documentation for the typst-ribbons library.

## Documentation Files

### 📘 [Quick Start Guide](quick-start.typ)
**For beginners** - Get up and running in 5 minutes
- Basic Sankey and Chord diagrams
- Common customizations
- Real-world example
- Tips and patterns

**Start here if you're new to typst-ribbons!**

### 📖 [API Reference](api-reference.typ)
**Complete reference** - All functions, parameters, and types
- Every function signature with types
- Detailed parameter descriptions
- Return values
- Multiple examples per function
- Troubleshooting guide

**Use this when you need detailed information about specific functions.**

### 🎨 [Examples Gallery](examples.typ)
**Practical examples** - See it in action
- Basic examples
- Layout variations
- Color and styling demos
- Real-world use cases (budgets, energy, trade, etc.)
- Advanced techniques

**Browse this for inspiration and copy-paste code.**

## Quick Reference

### Main Functions

```typst
#sankey-diagram(data, ...)  // Linear flow diagram
#chord-diagram(data, ...)   // Circular relationship diagram
```

### Data Format

```typst
// Adjacency dictionary (recommended)
(
  "Source": ("Target": size, ...),
  ...
)

// Or adjacency list
(
  ("from", "to", size),
  ...
)

// Or adjacency matrix
(
  matrix: ((values...), ...),
  ids: ("id1", "id2", ...)
)
```

### Key Customization Options

```typst
// Layout
layout: layout.auto-linear(vertical: true, layer-gap: 3)
layout: layout.circular(radius: 5, directed: true)

// Colors
tinter: tinter.layer-tinter(palette: palette.tableau)
tinter: tinter.dict-tinter(("A": red, "B": blue))

// Ribbon styles
ribbon-stylizer: ribbon-stylizer.gradient-from-to(transparency: 60%)

// Labels
draw-label: label.default-linear-label-drawer(snap: right)
```

## Document Structure

Each documentation file is a Typst document (.typ) that you can:
1. **Read** - View in a text editor
2. **Compile** - Generate PDF with `typst compile`
3. **Render** - See live results in Typst's preview

## Compiling Documentation

To generate PDF versions:

```bash
# Quick start guide
typst compile docs/quick-start.typ

# API reference
typst compile docs/api-reference.typ

# Examples gallery
typst compile docs/examples.typ
```

## Using the Documentation

### If you want to...

**Learn the basics fast**
→ Start with `quick-start.typ`

**Understand a specific function**
→ Search in `api-reference.typ`

**See real examples**
→ Browse `examples.typ`

**Copy-paste code**
→ Use `examples.typ` or `quick-start.typ`

**Understand all options**
→ Read `api-reference.typ`

## Documentation Organization

### quick-start.typ
- **Audience**: Beginners
- **Length**: ~10 pages
- **Focus**: Getting started quickly
- **Format**: Tutorial style with progressive examples

### api-reference.typ
- **Audience**: All users (reference)
- **Length**: ~60 pages
- **Focus**: Complete API documentation
- **Format**: Systematic function-by-function reference

### examples.typ
- **Audience**: Visual learners, practitioners
- **Length**: ~30 pages
- **Focus**: Practical, copy-paste ready code
- **Format**: Gallery of rendered examples with code

## Topics Covered

### Covered in All Documents
- Creating basic diagrams
- Data formats
- Customization options

### Only in API Reference
- Complete type signatures
- All parameter options
- Return values
- Edge cases and advanced usage
- Troubleshooting
- API quick reference tables

### Only in Examples
- Multiple variations of same concept
- Real-world scenarios
- Color palette comparisons
- Styled vs. unstyled comparisons

### Only in Quick Start
- Recommended learning path
- Common patterns for specific use cases
- Tips for beginners
- "Next steps" guidance

## Contributing to Documentation

When adding new features, please update:
1. **API Reference** - Add complete function documentation
2. **Examples** - Add at least one practical example
3. **Quick Start** (optional) - If it's a common use case

## Building Complete Documentation Set

Generate all documentation PDFs:

```bash
# Create output directory
mkdir -p docs-pdf

# Build all documents
typst compile docs/quick-start.typ docs-pdf/quick-start.pdf
typst compile docs/api-reference.typ docs-pdf/api-reference.pdf
typst compile docs/examples.typ docs-pdf/examples.pdf
```

## Index of Functions

### Main Diagrams
- `ribbon-diagram()` - api-reference.typ p.8, examples.typ p.N/A
- `sankey-diagram()` - api-reference.typ p.9-10, quick-start.typ p.2, examples.typ p.3+
- `chord-diagram()` - api-reference.typ p.10-11, quick-start.typ p.3, examples.typ p.4+

### Layouts
- `layout.auto-linear()` - api-reference.typ p.15-17, examples.typ p.5-7
- `layout.circular()` - api-reference.typ p.18-19, examples.typ p.6

### Tinters
- `tinter.default-tinter()` - api-reference.typ p.22
- `tinter.layer-tinter()` - api-reference.typ p.23, quick-start.typ p.6, examples.typ p.8
- `tinter.node-tinter()` - api-reference.typ p.23, examples.typ p.21
- `tinter.categorical-tinter()` - api-reference.typ p.24, examples.typ p.10
- `tinter.dict-tinter()` - api-reference.typ p.24-25, quick-start.typ p.4, examples.typ p.9

### Stylizers
- `ribbon-stylizer.match-from()` - api-reference.typ p.27-28
- `ribbon-stylizer.match-to()` - api-reference.typ p.28
- `ribbon-stylizer.gradient-from-to()` - api-reference.typ p.28-29, quick-start.typ p.5, examples.typ p.10
- `ribbon-stylizer.solid-color()` - api-reference.typ p.29

### Labels
- `label.default-linear-label-drawer()` - api-reference.typ p.30-31, examples.typ p.17
- `label.default-circular-label-drawer()` - api-reference.typ p.31

### Palettes
- `palette.color-brewer-palette` - api-reference.typ p.26, examples.typ p.19
- `palette.tableau` - api-reference.typ p.26, examples.typ p.20
- `palette.catppuccin` - api-reference.typ p.26, examples.typ p.21

## Feedback

Documentation feedback is welcome! Please note:
- Missing examples
- Unclear explanations
- Errors or typos
- Suggested improvements

---

Happy diagramming! 🎨
