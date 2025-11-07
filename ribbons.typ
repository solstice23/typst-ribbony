#import "@preview/cetz:0.4.2"
#import "./utils.typ": *

#import "./ribbon-stylizer.typ"

#let assign-layers = (
	nodes,
	layer-override: (:)
) => {
	let layer-dict = (:)

	let queue = ()
	let visited = (:)
	let max-layer = 0
	for (node-id, properties) in nodes {
		// BFS to assign layers for each component
		if (visited.at(node-id, default: false) == false) {
			queue.push((node-id: node-id, layer: 0))
		}
		let tmp-layer = (:)
		let min-layer = 0
		while (queue.len() > 0) {
			let (node-id, layer) = queue.remove(0)
			if (visited.at(node-id, default: false) == true) {
				continue
			}
			tmp-layer.insert(node-id, layer)
			min-layer = calc.min(min-layer, layer)
			visited.insert(node-id, true)
			for (to, ..) in nodes.at(node-id).edges {
				if (visited.at(to, default: false) == false) {
					queue.push((node-id: to, layer: layer + 1))
				}
			}
			for (from, size) in nodes.at(node-id).from-edges {
				if (visited.at(from, default: false) == false) {
					queue.push((node-id: from, layer: layer - 1))
				}
			}
		}
		// Normalize layers to start from 0
		for (node-id, layer) in tmp-layer {
			let normalized-layer = layer - min-layer
			max-layer = calc.max(max-layer, normalized-layer)
			layer-dict.insert(node-id, normalized-layer)
		}
	}
	// Apply layer override
	for (node-id, layer) in layer-override {
		layer-dict.insert(node-id, layer)
	}

	// Collect nodes in layers	
	let layers = ()
	for i in range(0, max-layer + 1) {
		layers.push(())
	}
	for node-id in nodes.keys() { // keep original order
		let layer = layer-dict.at(node-id)
		layers.at(layer).push(node-id)		
	}
	layers = layers.map(layer => layer.sorted(key: (it) => nodes.at(it).number-id))

	return layers
}

/* Input Data Processing Functions */
/*
 * There are 3 supported input data formats:
 * 1. Adjacency list: array of (from, to, size, ?([style]: , ..edge-attributes))
 * 2. Adjacency matrix: (matrix: n*n array, ids: array of n node-ids)
 * 3. Adjacency dictionary: ("node-id": outgoingEdges)
 * 
 * outgoingEdges = DetailedEdges | SimpleEdges
 * DetailedEdges = array of (to: node-id, size: number, ([style]: , ..edge-attributes))
 * SimpleEdges = a dict: ([to: node-id]: size)
 * 
 * The output of all preprocess-data functions is a dictionary:
 * ([node-id]: DetailedEdges)
 * Meanwhile, add nodes that defined implicitly by being a target of an edge
 */

#let is-adjacency-list = (data) => {
	if (type(data) != array) {
		return false
	}
	// adjacency list is the only array input type, so we don't check further, and can provide more detailed error messages later
	return true
}
#let process-adjancy-list = (data) => {
	let nodes = (:)
	for edge in data {
		assert(type(edge) == array, message: "Expected each edge to be a array")
		assert(edge.len() >= 3, message: "Expected each edge to have at least 3 elements: (from, to, size, ?attrs)")
		let (from, to, size) = (edge.at(0), edge.at(1), edge.at(2))
		let attrs = edge.at(3, default: (:))
		if (nodes.at(from, default: none) == none) {
			nodes.insert(from, ())
		}
		if (nodes.at(to, default: none) == none) {
			nodes.insert(to, ())
		}
		nodes.at(from).push((
			to: to,
			size: size,
			..attrs
		))
	}
	return nodes
}
#let is-adjacency-matrix = (data) => {
	if (type(data) != dictionary) {
		return false
	}
	if (data.at("matrix", default: none) == none or data.at("ids", default: none) == none) {
		return false
	}
	if (type(data.at("matrix")) != array or type(data.at("ids")) != array) {
		return false
	}
	return true
}
#let process-adjacency-matrix = (data) => {
	let (matrix, ids) = data
	let n = matrix.len()
	assert(matrix.len() == n, message: "Expected square adjacency matrix")
	for row in matrix {
		assert(type(row) == array, message: "Expected each row of adjacency matrix to be an array")
		assert(row.len() == n, message: "Expected square adjacency matrix")
	}
	assert(ids.len() == n, message: "Expected ids array length to match adjacency matrix size")
	let nodes = (:)
	for i in range(0, n) {
		let from = ids.at(i)
		nodes.insert(from, ())
		for j in range(0, n) {
			let to = ids.at(j)
			let size = matrix.at(i).at(j)
			if (size > 0) {
				nodes.at(from).push((
					to: to,
					size: size
				))
			}
		}
	}
	return nodes
}
#let process-adjacency-dictionary = (data) => {
	let nodes = (:)
	for (from, edges) in data {
		nodes.insert(from, ())
		assert(type(edges) == dictionary or type(edges) == array, message: "Expected edges to be a dictionary or an array")
		if (type(edges) == dictionary) {
			// SimpleEdges
			for (to, size) in edges {
				if (nodes.at(to, default: none) == none) {
					nodes.insert(to, ())
				}
				nodes.at(from).push((
					to: to,
					size: size
				))
			}
		} else {
			// DetailedEdges
			for edge in edges {
				assert(type(edge) == dictionary, message: "Expected each edge to be a dictionary")
				let (to, size, ..attrs) = edge
				if (nodes.at(to, default: none) == none) {
					nodes.insert(to, ())
				}
				nodes.at(from).push((
					to: to,
					size: size,
					..attrs
				))
			}
		}
	}
	return nodes
}

// Merge duplicated edges and return two adjacency dictionarys in which edges are SimpleEdges
// return (merged-out-edges, merged-in-edges)
// Useful for some types of layouts (e.g. undirected circular layout)
#let merge-duplicated-edges = (nodes) => {
	let merged-out-edges = (:)
	let merged-in-edges = (:)
	for (node-id, properties) in nodes {
		merged-out-edges.insert(node-id, (:))
		merged-in-edges.insert(node-id, (:))
		for (to, size, ..) in properties.edges {
			merged-out-edges.at(node-id).insert(to, merged-out-edges.at(node-id).at(to, default: 0) + size)
		}
		for (from, size, ..) in properties.from-edges {
			merged-in-edges.at(node-id).insert(from, merged-in-edges.at(node-id).at(from, default: 0) + size)
		}
	}
	return (merged-out-edges, merged-in-edges)
}


#let preprocess-data = (
	data,
	aliases,
	categories
) => {
	// Preprocess edges, standarize to DetailedEdges
	if (is-adjacency-list(data)) {
		data = process-adjancy-list(data)
	} else if (is-adjacency-matrix(data)) {
		data = process-adjacency-matrix(data)
	} else {
		data = process-adjacency-dictionary(data)
	}

	// Make edges dictionaries one of the attributes
	for (node-id, edges) in data {
		data.insert(node-id, (
			edges: edges,
			from-edges: ()
		))
	}

	// Add from-edges
	for (node-id, properties) in data {
		for (to, ..attrs) in properties.edges {
			data.at(to).from-edges.push(("from": node-id, ..attrs))
		}
	}

	// Add id (same as key) and name (alias | id)
	for (node-id, properties) in data {
		data.at(node-id).insert("id", node-id)
		if (aliases.at(node-id, default: none) != none) {
			data.at(node-id).insert("name", aliases.at(node-id))
		} else {
			data.at(node-id).insert("name", node-id)
		}
	}
	// Add category
	for (category-name, node-ids) in categories {
		for node-id in node-ids {
			if (data.at(node-id, default: none) != none) {
				data.at(node-id).insert("category", category-name)
			}
		}
	}
	// Add #id
	let counter = 0
	for (node-id, properties) in data {
		data.at(node-id).insert("number-id", counter)
		counter += 1
	}

	// Add other necessary attributes to nodes
	// in-size and out-size: sum of incoming and outgoing edge sizes
	for (node-id, properties) in data {
		data.at(node-id).insert("in-size", properties.from-edges.map(edge => edge.size).sum(default: 0))
		data.at(node-id).insert("out-size", properties.edges.map(edge => edge.size).sum(default: 0))
	}

	data
}


/*
A Palette is an array of colours
A Tinter returns a function, Nodes -> Palette -> Nodes
*/
#let color-brewer-palette = (rgb("#66C2A5"), rgb("#FC8D62"), rgb("#8DA0CB"), rgb("#E78AC3"), rgb("#A6D854"), rgb("#FFD92F"), rgb("#E5C494"), rgb("#B3B3B3"))
#let tableau = (rgb("#1F77B4"), rgb("#FF7F0E"), rgb("#2CA02C"), rgb("#D62728"), rgb("#9467BD"), rgb("#8C564B"), rgb("#E377C2"), rgb("#7F7F7F"), rgb("#BCBD22"), rgb("#17BECF"))
#let catppuccin = (rgb("#e78284"), rgb("#a6d189"), rgb("#e5c890"), rgb("#8caaee"), rgb("#f4b8e4"), rgb("#81c8be"), rgb("#ca9ee6"), rgb("#ea999c"), rgb("#85c1dc"), rgb("#ef9f76"), rgb("#99d1db"), rgb("#eebebe"), rgb("#f2d5cf"))
#let default-palette = color-brewer-palette

#let layer-tinter = (
	palette: default-palette
) => {
	(nodes) => {
		for (node-id, properties) in nodes {
			assert(properties.at("layer", default: none) != none, message: "Node " + node-id + " has no layer attribute. Are you using a layered layout?")
			let layer = properties.layer
			let color = palette.at(calc.rem(layer, palette.len()))
			nodes.at(node-id).insert("color", color)
		}
		nodes
	}
}

#let categorical-tinter = (
	palette: default-palette
) => {
	(nodes) => {
		let categories = ()
		// collect categories
		for (node-id, properties) in nodes {
			categories.push(properties.at("category", default: "default"))
		}
		categories = categories.dedup()
		let category-index = (:)
		for (index, category) in categories.enumerate() {
			category-index.insert(category, index)
		}
		// assign colors
		for (node-id, properties) in nodes {
			let index = category-index.at(properties.at("category", default: "default"))
			let color = palette.at(calc.rem(index, palette.len()))
			nodes.at(node-id).insert("color", color)
		}
		return nodes
	}
}

#let node-tinter = (
	palette: default-palette
) => {
	(nodes) => {
		for (node-id, properties) in nodes {
			let number-id = properties.number-id
			let color = palette.at(calc.rem(number-id, palette.len()))
			nodes.at(node-id).insert("color", color)
		}
		return nodes
	}
}
#let dict-tinter = (
	color-map,
	override: none
) => {
	assert(type(color-map) == dictionary, message: "Expected a dictionary for color-map")
	(nodes) => {
		if (override != none) {
			nodes = override(nodes)
		}
		for (node-id, properties) in nodes {
			let color = color-map.at(node-id, default: if (override == none) { default-palette.at(0) } else { nodes.at(node-id).color })
			nodes.at(node-id).insert("color", color)
		}
		return nodes
	}
}



#let default-tinter = (
	palette: default-palette
) => {
	// choose layer tinter if layers exist, otherwise node tinter
	(nodes) => {
		if nodes.keys().len() == 0 {
			return layer-tinter(palette: palette)(nodes)
		}
		if (nodes.at(nodes.keys().first()).at("layer", default: none) != none) {
			return layer-tinter(palette: palette)(nodes)
		} else {
			return node-tinter(palette: palette)(nodes)
		}
	}
}



#let auto-linear-layout = (
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
) => {
	let layer-override = layers
	( layouter: (nodes) => {
		// Calculate layers for each node
		let layers = assign-layers(nodes, layer-override: layer-override)

		for (layer-index, layer) in layers.enumerate() {
			for node-id in layer {
				nodes.at(node-id).insert("layer", layer-index)
			}
		}
		// node size=max(in-size, out-size)
		for (node-id, properties) in nodes {
			let node-size = calc.max(properties.in-size, properties.out-size)
			nodes.at(node-id).insert("size", node-size)
		}
		// Give widths
		for (node-id, properties) in nodes {
			nodes.at(node-id).insert("width", node-width)
		}
		// Give heights
		let max-node-size = 0
		for (node-id, properties) in nodes {
			max-node-size = calc.max(max-node-size, properties.size)
		}
		for (node-id, properties) in nodes {
			let node-size = properties.size
			let node-height = calc.max(node-size / max-node-size * base-node-height, min-node-height)
			nodes.at(node-id).insert("height", node-height)
		}

		// Give initial x positions
		for (node-id, properties) in nodes {
			let layer = properties.layer
			let x = layer * (node-width + layer-gap) + node-width / 2
			nodes.at(node-id).insert("x", x)
		}
		// Assign initial y positions based on node-gap
		let layer-assign-y-positions = (nodes, layer) => {
			let offset = 0.0
			for node-id in layer {
				let height = nodes.at(node-id).height
				nodes.at(node-id).insert("y", offset - height / 2)
				offset -= height + node-gap
			}
			nodes
		}
		for layer in layers {
			nodes = layer-assign-y-positions(nodes, layer)
		}

		/*
			A node receives forces from:
				- attraction to every connected nodes
			Nodes have rigid constraints:
				- nodes in the same layer must have at least node-gap distance
		*/
		let calculate-attraction-forces = (nodes) => {
			let forces = (:)
			for (node-id, properties) in nodes {
				forces.insert(node-id, 0.0)
			}

			for (node-id, properties) in nodes {
				let y1 = properties.y
				
				for to in properties.edges.map(edge => edge.to).dedup() {
					let y2 = nodes.at(to).y
					let dy = y2 - y1
					let dx = layer-gap
					let dist = calc.sqrt(dx * dx + dy * dy)
					let theta = calc.atan2(dy, dx)
					let force = dist * calc.cos(theta) * 0.5
					forces.insert(node-id, forces.at(node-id) + force)
					forces.insert(to, forces.at(to) - force)
				}
			}
			
			return forces
		}
		
		let enforce-rigid-min-gap = (nodes, layers) => {
			let max-iterations = 15
			let nodes-new = nodes
			
			for iter in range(0, max-iterations) {
				let violations = false
				
				for layer in layers {
					for i in range(0, layer.len() - 1) {
						let node-id1 = layer.at(i)
						let node-id2 = layer.at(i + 1)
						let y1 = nodes-new.at(node-id1).y
						let h1 = nodes-new.at(node-id1).height
						let y2 = nodes-new.at(node-id2).y
						let h2 = nodes-new.at(node-id2).height
						
						let bottom1 = y1 - h1 / 2
						let top2 = y2 + h2 / 2
						let current-gap = bottom1 - top2
						
						if current-gap < node-gap {
							violations = true
							let violation = node-gap - current-gap
							// Push them apart equally
							nodes-new.at(node-id1).insert("y", nodes-new.at(node-id1).y + violation / 2)
							nodes-new.at(node-id2).insert("y", nodes-new.at(node-id2).y - violation / 2)
						}
					}
				}
				
				if not violations { break }
			}
			
			return nodes-new
		}

		// Resolve physical system
		let iterations = 30
		let alpha = 0.1
		
		for i in range(1, iterations) {
			let nodes-new = nodes
			
			let forces = calculate-attraction-forces(nodes)
			
			// Apply forces
			for (node-id, properties) in nodes {
				let y = properties.y
				let force = forces.at(node-id)
				y += force * alpha
				nodes-new.at(node-id).insert("y", y)
				nodes-new.at(node-id).insert("force", force)
			}
			
			nodes = enforce-rigid-min-gap(nodes-new, layers)
		}

		// Center each layer to y=0
		if (centerize-layer) {
			for layer in layers {
				let min-y = 0.0
				let max-y = 0.0
				for node-id in layer {
					let y = nodes.at(node-id).y
					let height = nodes.at(node-id).height
					min-y = calc.min(min-y, y - height / 2)
					max-y = calc.max(max-y, y + height / 2)
				}
				let layer-height = max-y - min-y
				let offset = layer-height / 2 + min-y

				for node-id in layer {
					let y = nodes.at(node-id).y
					nodes.at(node-id).insert("y", y - offset)
				}
			}
		}

		// Normalize y positions
		let min-y = 99999999
		for (node-id, properties) in nodes {
			let y = properties.y
			let height = properties.height
			min-y = calc.min(min-y, y - height / 2)
		}
		for (node-id, properties) in nodes {
			let y = properties.y
			nodes.at(node-id).insert("y", y - min-y)
		}

		return nodes
	}, drawer: (nodes, ribbon-stylizer, label-drawer) => {
		cetz.canvas({
			import cetz.draw: *

			if (vertical) {
				set-transform(cetz.matrix.mul-mat(
					cetz.matrix.transform-rotate-z(90deg),
					cetz.matrix.transform-scale((1, -1))
				))
			}
			
			let acc-out-size = (:)
			let acc-in-size = (:)
			for (node-id, properties) in nodes {
				let (x, y, width, height) = properties
				let node-name = node-id + "_node";

				rect(name: node-name,
					(rel: (0, -radius / 2), to: (x - width / 2, y - height / 2)), 
					(rel: (0, radius / 2), to: (x + width / 2, y + height / 2)), 
					fill: properties.color,
					stroke: none,
					radius: radius
				)

				// label
				on-layer(
					1,
					{
						label-drawer(
							node-name,
							properties,
							layer-gap: layer-gap,
							node-gap: node-gap,
							node-width: node-width,
							base-node-height: base-node-height,
							vertical-layout: vertical
						)
					}
				)

				// sort ribbons first by slope to prevent crossing
				let slopes = (:)
				for to in properties.edges.map(edge => edge.to).dedup() {
					slopes.insert(
						to,
						calc.atan2((nodes.at(to).y - y), (nodes.at(to).x - x))
					)
				}
				let edges = properties.edges.sorted(key: it => slopes.at(it.to))

				// ribbons
				for (to, size, ..attrs) in edges {
					let to-properties = nodes.at(to)
					let top-left = (x + width / 2, y + height / 2 - acc-out-size.at(node-id, default: 0) / properties.size * height)
					let bottom-left = (top-left.at(0), top-left.at(1) - size / properties.size * height)
					let top-right = (to-properties.x - to-properties.width / 2, to-properties.y + to-properties.height / 2 - acc-in-size.at(to, default: 0) / to-properties.size * to-properties.height)
					let bottom-right = (top-right.at(0), top-right.at(1) - size / to-properties.size * to-properties.height)
					acc-out-size.insert(node-id, acc-out-size.at(node-id, default: 0) + size)
					acc-in-size.insert(to, acc-in-size.at(to, default: 0) + size)

					let ribbon-width = calc.min(top-left.at(1) - bottom-left.at(1), top-right.at(1) - bottom-right.at(1))

					let bezier-top-control-1 = point-translate(top-left, (curve-factor * (top-right.at(0) - top-left.at(0)), 0))
					let bezier-top-control-2 = point-translate(top-right, (-curve-factor * (top-right.at(0) - top-left.at(0)), 0))
					let bezier-bottom-control-1 = point-translate(bottom-left, (curve-factor * (bottom-right.at(0) - bottom-left.at(0)), 0))
					let bezier-bottom-control-2 = point-translate(bottom-right, (-curve-factor * (bottom-right.at(0) - bottom-left.at(0)), 0))
					merge-path(
						..ribbon-stylizer(properties.color, to-properties.color, node-id, to),
						{
							bezier(top-left, top-right, bezier-top-control-1, bezier-top-control-2)
							line(top-right, bottom-right)
							bezier(bottom-right, bottom-left, bezier-bottom-control-2, bezier-bottom-control-1)
							line(bottom-left, top-left)
						}
					)
				}

				// forces
				let force = properties.at("force", default: 0)
				if (force != 0) {
					let sign = if (force > 0) { 1 } else { -1 }
					let len = calc.min(calc.abs(force), 1)
					// line((x, y), (x, y + len * sign), stroke: red, stroke-width: 0.05, mark: (end: ">"))
				}
			}
		})

	})
}

#let circular-layout = (
	radius: 4,
	node-width: 0.5,
	node-gap: 1deg,
	angle-offset: 0deg,
	directed: false,
) => {
	(layouter: (nodes) => {
		// node size=in-size+out-size by default
		for (node-id, properties) in nodes {
			let node-size = if (directed) { properties.in-size + properties.out-size } else { properties.out-size }
			nodes.at(node-id).insert("size", node-size)
		}
		// Place all node on a ring (only 1 layer)
		let sum = 0
		for (node-id, properties) in nodes {
			sum += properties.size
		}
		sum /= 1 - (node-gap * nodes.keys().len() / 360deg)

		let angle = angle-offset + 90deg
		for (node-id, properties) in nodes {
			let node-size = properties.size
			let node-arc = (node-size / sum) * 360deg
			nodes.at(node-id).insert("angle", angle + node-arc / 2)
			nodes.at(node-id).insert("arc", node-arc)
			angle += node-arc + node-gap
		}
		
		return nodes
	}, drawer: (nodes, ribbon-stylizer, label-drawer) => {
		cetz.canvas({
			import cetz.draw: *
			
			// out size acculates from 0, in size acculates from total size
			let in-acc-size = (:)
			let out-acc-size = (:) // if undirected, only use out-acc-size
			let drawn = (:) // drawn[from][to] = bool, for drawing undirected edges only once

			// if undirected, we combine all out and in edges and use this instead
			let (merged-out-edges, merged-in-edges) = merge-duplicated-edges(nodes)

			for (node-id, properties) in nodes {
				let angle = properties.angle
				let node-arc = properties.arc
				let width = node-width

				let inner-left = (radius * calc.cos(angle - node-arc / 2), radius * calc.sin(angle - node-arc / 2))
				let inner-center = (radius * calc.cos(angle), radius * calc.sin(angle))
				let inner-right = (radius * calc.cos(angle + node-arc / 2), radius * calc.sin(angle + node-arc / 2))
				let outer-left = ((radius + width) * calc.cos(angle - node-arc / 2), (radius + width) * calc.sin(angle - node-arc / 2))
				let outer-center = ((radius + width) * calc.cos(angle), (radius + width) * calc.sin(angle))
				let outer-right = ((radius + width) * calc.cos(angle + node-arc / 2), (radius + width) * calc.sin(angle + node-arc / 2))

				merge-path(
					fill: properties.color,
					stroke: none,
					{
						arc-through(inner-left, inner-center, inner-right)
						line(inner-right, outer-right)
						arc-through(outer-right, outer-center, outer-left)
						line(outer-left, inner-left)
					}
				)

				// content((x, y), text(properties.name, size: 8pt))

				// ribbons
				for (to, out-edge-size) in merged-out-edges.at(node-id) {
					if (not directed and (
						drawn.at(node-id, default: (:)).at(to, default: false) or
						drawn.at(to, default: (:)).at(node-id, default: false)
					)) {
						continue
					}


					let to-properties = nodes.at(to)
					
					let in-edge-size = if (directed) { out-edge-size } else {
						merged-in-edges.at(node-id).at(to, default: 0)
					}

					let from-acc-size = out-acc-size.at(node-id, default: 0)
					let to-acc-size = if (directed) {in-acc-size.at(to, default: to-properties.size) }
										else { out-acc-size.at(to, default: 0) }
					let from-start-angle = angle - node-arc / 2 + (from-acc-size / properties.size * node-arc)
					let from-end-angle = angle - node-arc / 2 + ((from-acc-size + out-edge-size) / properties.size * node-arc)
					let to-start-angle = to-properties.angle - to-properties.arc / 2 + ((to-acc-size - in-edge-size) / to-properties.size * to-properties.arc)
					let to-end-angle = to-properties.angle - to-properties.arc / 2 + (to-acc-size / to-properties.size * to-properties.arc)
					if (not directed) {
						to-start-angle = to-properties.angle - to-properties.arc / 2 + (to-acc-size / to-properties.size * to-properties.arc)
						to-end-angle = to-properties.angle - to-properties.arc / 2 + ((to-acc-size + in-edge-size) / to-properties.size * to-properties.arc)
						if (drawn.at(node-id, default: none) == none) { drawn.insert(node-id, (:)) }
						drawn.at(node-id).insert(to, true)
						if (drawn.at(to, default: none) == none) { drawn.insert(to, (:)) }
						drawn.at(to).insert(node-id, true)
					}

					let from-left = (radius * calc.cos(from-start-angle), radius * calc.sin(from-start-angle))
					let from-center = (radius * calc.cos((from-start-angle + from-end-angle) / 2), radius * calc.sin((from-start-angle + from-end-angle) / 2))
					let from-right = (radius * calc.cos(from-end-angle), radius * calc.sin(from-end-angle))
					let to-left = (radius * calc.cos(to-start-angle), radius * calc.sin(to-start-angle))
					let to-center = (radius * calc.cos((to-start-angle + to-end-angle) / 2), radius * calc.sin((to-start-angle + to-end-angle) / 2))
					let to-right = (radius * calc.cos(to-end-angle), radius * calc.sin(to-end-angle))

					out-acc-size.insert(node-id, from-acc-size + out-edge-size)
					if (directed) {
						in-acc-size.insert(to, to-acc-size - in-edge-size)
					} else if (node-id != to) {
						out-acc-size.insert(to, to-acc-size + in-edge-size)
					}

					
					merge-path(
						..ribbon-stylizer(
							properties.color, to-properties.color, node-id, to,
							angle: -calc.atan2(to-center.at(0) - from-center.at(0), to-center.at(1) - from-center.at(1))
						),
						{
							arc-through(from-left, from-center, from-right)
							bezier(from-right, to-left, (0, 0))
							arc-through(to-left, to-center, to-right)
							bezier(to-right, from-left, (0, 0))
						}
					)
					
				}

			}
		})
	})
}


/*
Label drawer
*/
#let default-linear-label-drawer = (
	snap: auto,
	offset: auto,
	width-limit: auto, // auto | false | value,
	styles: (
		inset: 0.2em,
		fill: white.transparentize(50%),
		radius: 2pt
	),
	draw-content: (properties) => {[
		#set par(leading: 0.5em)
		#text(properties.name, size: 0.8em) \
		#text(str(properties.size), size: 1em)
	]}
) => {
	(
		node-name,
		properties,
		layer-gap: none,
		vertical-layout: false,
		..args
	) => {
		import cetz.draw: *

		let _snap = snap

		let snap = if (_snap == auto) {
			if (vertical-layout) { bottom } else { right }
		} else {
			_snap
		}

		assert(snap in (left, right, top, bottom, center), message: "Invalid snap value: " + repr(snap))
		assert((snap in (left, right) and not vertical-layout) or
			   (snap in (top, bottom) and vertical-layout) or
			   (snap == center),
			   message: "Snap value " + repr(snap) + " is incompatible with layout direction")

		let rel = if (offset != auto) { offset } else {
			if (snap in (right, bottom)) {
				(0.05, 0)
			} else if (snap in (left, top)) {
				(-0.05, 0)
			} else {
				(0, 0)
			}
		}

		let (content-anchor, rel-to-anchor) = if (snap == left) { ("east", "west") }
			else if (snap == right) { ("west", "east") }
			else if (snap == top) { ("south", "west") }
			else if (snap == bottom) { ("north", "east") }
			else { ("center", "center") }

		let outer-box-width = if (width-limit == auto) {
			if (layer-gap != none) {
				layer-gap * 0.95cm
			} else { auto }
		} else if (width-limit == false) {
			auto
		} else {
			width-limit
		}
		let outer-box-constraints = if (vertical-layout) {
			(width: auto, height: outer-box-width)
		} else {
			(width: outer-box-width, height: auto)
		}

		content(
			anchor: content-anchor, (rel: rel, to: node-name + "." + rel-to-anchor), 
			box(..outer-box-constraints)[
				#set align(
					if (snap == right) { left }
					else if (snap == left) { right }
					else { center } +
					if (snap == top) { bottom }
					else if (snap == bottom) { top }
					else { horizon }
				)
				#box(..styles)[
					#draw-content(properties)
				]
			]
		)
	}
}


#let sankey = (
	data,
	aliases: (:),
	categories: (:),
	layout: auto-linear-layout(),
	tinter: default-tinter(),
	ribbon-stylizer: ribbon-stylizer.default(),
	draw-label: default-linear-label-drawer(),
) => {
	let nodes = preprocess-data(data, aliases, categories)
	// repr(nodes)
	//repr(assign-layers(nodes))
	let (layouter, drawer) = layout
	nodes = layouter(nodes)
	nodes = tinter(nodes)
	// repr(nodes)
	drawer(nodes, ribbon-stylizer, draw-label)
}

#sankey(
	(
		("A", "B", 2),
		("A", "B", 3),
		("A", "C", 3),
		("B", "D", 2),
		("B", "E", 4),
		("C", "D", 3),
		("C", "E", 4),
		("E", "F", 2),
	),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to(
		stroke-width: 0.2pt,
	)
)


#sankey(
	(
		"A": ("B": 5, "C": 3),
		"B": ("D": 2, "E": 4),
		"C": ("D": 3, "E": 4),
		"D": (:),
		"E": ("F": 2),
	)
)
#sankey(
	(
		"iPhone": (
			"Products": 44582
		),
		"Wearables, Home, Accessories": (
			"Products": 7404
		),
		"Mac": (
			"Products": 8046
		),
		"iPad": (
			"Products": 6581
		),
		"Products": (
			"Apple Net Sales Quarter": 66613
		),
		"Services": (
			"Apple Net Sales Quarter": 27423
		),
		"Apple Net Sales Quarter": (
			"Gross Margin": 43718,
			"Cost of Sales": 50318,
		),
		"Gross Margin": (
			"Operating Income": 28202,
			"Research & Development": 8866,
			"Selling, General, Administrative": 6650,
		),
		"Operating Income": (
			"Income before Taxes": 28031,
			"Other Expense": 171,
		),
		"Income before Taxes": (
			"Taxes": 4597,
			"Net Income": 23434
		)
	),
)
#sankey(
	(
		"iPhone": (
			"Products": 44582
		),
		"Wearables, Home, Accessories": (
			"Products": 7404
		),
		"Mac": (
			"Products": 8046
		),
		"iPad": (
			"Products": 6581
		),
		"Products": (
			"Apple Net Sales Quarter": 66613
		),
		"Services": (
			"Apple Net Sales Quarter": 27423
		),
		"Apple Net Sales Quarter": (
			"Gross Margin": 43718,
			"Cost of Sales": 50318,
		),
		"Gross Margin": (
			"Operating Income": 28202,
			"Research & Development": 8866,
			"Selling, General, Administrative": 6650,
		),
		"Operating Income": (
			"Income before Taxes": 28031,
			"Other Expense": 171,
		),
		"Income before Taxes": (
			"Taxes": 4597,
			"Net Income": 23434
		)
	),
	layout: auto-linear-layout(
		radius: 0,
		vertical: true
	)
)


#sankey(
	(
		"A": ("B": 4, "C": 9, "D": 4),
		"B": ("E": 2, "F": 2),
		"E": ("G": 1, "H": 1)
	),
	aliases: (
		"A": "meow"
	)
)
#sankey(
	(
		"Nuclear": (
			"Thermal generation": 839
		),
		"Agricultural 'waste'": (
			"Bio-conversion": 124
		),
		"UK land based bioenergy": (
			"Bio-conversion": 182
		),
		"Marine algae": (
			"Bio-conversion": 4
		),
		"Other waste": (
			"Bio-conversion": 77,
			"Solid": 56
		),
		"Tidal": (
			"Electricity grid": 9
		),
		"Wave": (
			"Electricity grid": 19
		),
		"Solar": (
			"Solar PV": 59,
			"Solar Thermal": 19
		),
		"Solar PV": (
			"Electricity grid": 59
		),
		"Geothermal": (
			"Electricity grid": 7
		),
		"Hydro": (
			"Electricity grid": 6
		),
		"Wind": (
			"Electricity grid": 289
		),
		"District heating": (
			"Industry": 10,
			"Heating and cooling - commercial": 22,
			"Heating and cooling - homes": 46
		),
		"Solar Thermal": (
			"Heating and cooling - homes": 19
		),
		"Pumped heat": (
			"Heating and cooling - homes": 193,
			"Heating and cooling - commercial": 70
		),
		"Bio-conversion": (
			"Losses": 26,
			"Solid": 280,
			"Gas": 81,
			"Liquid": 0
		),
		"Biomass imports": (
			"Solid": 35
		),
		"Coal imports": (
			"Coal": 11
		),
		"Coal reserves": (
			"Coal": 63
		),
		"Coal": (
			"Solid": 75
		),
		"Gas": (
			"Losses": 1,
			"Thermal generation": 151,
			"Heating and cooling - commercial": 0,
			"Industry": 48,
			"Agriculture": 2
		),
		"Gas imports": (
			"Ngas": 40
		),
		"Gas reserves": (
			"Ngas": 82
		),
		"Ngas": (
			"Gas": 122
		),
		"H2 conversion": (
			"H2": 20,
			"Losses": 6
		),
		"Solid": (
			"Agriculture": 0,
			"Thermal generation": 400,
			"Industry": 46
		),
		"Electricity grid": (
			"Losses": 56,
			"Industry": 342,
			"Over generation / exports": 104,
			"Lighting & appliances - commercial": 90,
			"Lighting & appliances - homes": 93,
			"Heating and cooling - homes": 113,
			"H2 conversion": 27,
			"Rail transport": 7,
			"Road transport": 37,
			"Agriculture": 4,
			"Heating and cooling - commercial": 40
		),
		"H2": (
			"Road transport": 20
		),
		"Liquid": (
			"Industry": 121,
			"Road transport": 135,
			"International aviation": 206,
			"International shipping": 128,
			"Agriculture": 3,
			"National navigation": 33,
			"Rail transport": 4,
			"Domestic aviation": 14
		),
		"Oil imports": (
			"Oil": 504
		),
		"Oil reserves": (
			"Oil": 107
		),
		"Oil": (
			"Liquid": 611
		),
		"Biofuel imports": (
			"Liquid": 35
		),
		"Thermal generation": (
			"Electricity grid": 525,
			"Losses": 787,
			"District heating": 79
		)
	),
	ribbon-stylizer: ribbon-stylizer.gradient-from-to()
)

#sankey(
	(
		"a": ("a": 1000, "b": 1000), 
		"b": ("a": 1000, "b": 1000), 
	),
	layout: circular-layout(),
	// tinter: node-tinter()
)

#sankey(
	(
		"a": ("a": 1000, "b": 1000), 
		"b": ("a": 500, "b": 1000), 
	),
	layout: circular-layout(directed: true),
	// tinter: node-tinter()
	ribbon-stylizer: ribbon-stylizer.gradient-from-to()
)


#sankey(
	(
		"black": ("black": 11975, "blond": 5871, "brown": 8916, "red": 2868), 
		"blond": ("black": 1951, "blond": 10048, "brown": 2060, "red": 6171), 
		"brown": ("black": 8010, "blond": 16145, "brown": 8090, "red": 8045), 
		"red": ("black": 1013, "blond": 990, "brown": 940, "red": 6907)  
	),
	layout: circular-layout(),
	tinter: dict-tinter((
		"black": rgb("#000000"),
		"blond": rgb("#ffdd89"),
		"brown": rgb("#957244"),
		"red": rgb("#f26223"),
	))
)
#sankey(
	(
		matrix: (
			(11975, 5871, 8916, 2868), 
			(1951, 10048, 2060, 6171), 
			(8010, 16145, 8090, 8045), 
			(1013, 990, 940, 6907)
		),
		ids: ("black", "blond", "brown", "red")
	),
	layout: circular-layout(),
	tinter: dict-tinter((
		"black": rgb("#000000"),
		"blond": rgb("#ffdd89"),
		"brown": rgb("#957244"),
		"red": rgb("#f26223"),
	))
)

#sankey(
	(
		"A": ("B": 10),
		"B": ("C": 10),
		"C": ("D": 10, "Y": 10),
		"D": ("E": 10),
		"X": ("C": 10),
	)
)
