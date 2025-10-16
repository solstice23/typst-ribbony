#import "@preview/cetz:0.4.2"
#import "./utils.typ": *

#let topo-sort = (
	nodes,
	layer-override: (:)
) => {
	// TODO: CHANGE TO DEPTH ON TREE
	let current-layer = 0
	let layer-dict = (:)

	let queue = ()
	let next = ()

	let in-degree = (:)
	for (node-id, (edges, )) in nodes {
		for to in edges.keys() {
			in-degree.insert(to, in-degree.at(to, default: 0) + 1)
		}
	}
	for (node-id, (edges, )) in nodes {
		if (in-degree.at(node-id, default: 0) == 0) {
			queue.push(node-id)
		}
	}

	while (queue.len() > 0) {
		// layers.push(queue)
		for node in queue {
			layer-dict.insert(node, current-layer)
		}
		current-layer += 1
		while (queue.len() > 0) {
			let node-id = queue.remove(0)
			for (to, _) in nodes.at(node-id).edges {
				in-degree.insert(to, in-degree.at(to) - 1)
				if (in-degree.at(to) == 0) {
					next.push(to)
				}
			}
		}
		queue = next
		next = ()
	}

	// Check for remaining nodes (cycles)
	for (node-id, _) in nodes {
		if (in-degree.at(node-id, default: 0) > 0) {
			queue.push(node-id)
		}
	}
	if (queue.len() > 0) {
		// panic("Graph has cycles: " + queue.join(", "))
		// layers.push(queue)
		for node in queue {
			layer-dict.insert(node, current-layer)
		}
	}
	// Apply layer override
	for (node-id, layer) in layer-override {
		layer-dict.insert(node-id, layer)
	}

	// Collect nodes in layers	
	let layers = ()
	for i in range(0, current-layer + 1) {
		layers.push(())
	}
	for node-id in nodes.keys() { // keep original order
		let layer = layer-dict.at(node-id)
		layers.at(layer).push(node-id)		
	}

	return layers
}


#let preprocess-data = (
	data
) => {
	// Add nodes that defined implicitly by being a target of an edge
	assert(type(data) == dictionary, message: "Expected a dictionary")

	for (node-id, edges) in data {
		assert(type(edges) == dictionary, message: "Expected a dictionary of dictionaries")
		for target in edges.keys() {
			if (data.at(target, default: none) == none) {
				data.insert(target, (:))
			}
		}
	}

	// Make edges dictionaries in another dictionary for other attributes
	for (node-id, edges) in data {
		data.insert(node-id, (
			edges: edges,
			from-edges: (:)
		))
	}
	// Add from-edges
	for (node-id, properties) in data {
		for (to, size) in properties.edges {
			data.at(to).from-edges.insert(node-id, size)
		}
	}


	// Add other necessary attributes to nodes
	// size: size (max(sum of incoming sizes, sum of outgoing sizes)) of a node
	let in-size = (:)
	for (node-id, properties) in data {
		for (to, size) in properties.edges {
			in-size.insert(to, in-size.at(to, default: 0) + size)
		}
	}
	for (node-id, properties) in data {
		let out-size = properties.edges.values().sum(default: 0)
		let node-size = calc.max(in-size.at(node-id, default: 0), out-size)
		data.at(node-id).insert("size", node-size)
	}


	// TODO: Add more attributes
	data
}


/*
A Palette is an array of colours
A Tinter returns a function, Nodes -> Palette -> Nodes
*/
#let tint-override = (overrides) => {

}
#let default-palette = (red, green, blue, orange, purple, gray, yellow)

#let layer-tinter = (
	palette: default-palette
) => {
	(nodes) => {
		for (node-id, properties) in nodes {
			assert(properties.layer != none, message: "Node " + node-id + " has no layer attribute. Are you using a layered layout?")
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
	
}



#let auto-linear-layout = (
	layer-gap: 1.5,
	node-gap: 0.75,
	node-width: 0.5,
	basenode-height: 3,
	layers: (:)
) => {
	let layer-override = layers
	( layouter: (nodes) => {
		// Calculate layers for each node
		let layers = topo-sort(nodes, layer-override: layer-override)

		for (layer-index, layer) in layers.enumerate() {
			for node-id in layer {
				nodes.at(node-id).insert("layer", layer-index)
			}
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
			let node-height = node-size / max-node-size * basenode-height
			nodes.at(node-id).insert("height", node-height)
		}

		// Give initial x positions
		for (node-id, properties) in nodes {
			let layer = properties.layer
			let x = layer * (node-width + layer-gap) + node-width / 2
			nodes.at(node-id).insert("x", x)
			
		}
		// Give initial y positions
		for layer in layers {
			let offset = 0.0
			for node-id in layer {
				let height = nodes.at(node-id).height
				nodes.at(node-id).insert("y", offset - height / 2)
				offset -= height + node-gap
			}
		}
		// Resolve physical system:
		/*
			A node receives forces from:
				- repulsion from other nodes in the same layer, to keep minimum distance
				- attraction to the mass center of connected nodes (only counting x direction force)
		*/
		// TODO: Use gradient descent instead of simple iteration

		let iterations = 60
		let alpha = 0.1
		let forces = (:) // all forces are in x axis only
		for i in range(1, iterations) {
			let nodes-new = nodes
			for (node-id, properties) in nodes {
				forces.insert(node-id, 0.0)
			}

			// Repulsion forces
			for layer in layers {
				for (i, node-id1) in layer.enumerate() {
					if (i + 1 == layer.len()) { break }
					let y1 = nodes.at(node-id1).y
					let h1 = nodes.at(node-id1).height
					let y2 = nodes.at(layer.at(i + 1)).y
					let h2 = nodes.at(layer.at(i + 1)).height
					let gap = (y1 - h1 / 2) - (y2 + h2 / 2)
					if (gap < node-gap) {
						let force = calc.pow(node-gap - gap, 2) * 5
						forces.insert(node-id1, forces.at(node-id1) + force)
						forces.insert(layer.at(i + 1), forces.at(layer.at(i + 1)) - force)
					}
				}
			}
			// Attraction forces
			for (node-id, properties) in nodes {
				let y1 = properties.y
				
				for to in properties.edges.keys() {
					let y = nodes.at(to).y
					let dy = y - y1
					let dx = layer-gap
					let dist = calc.sqrt(dx * dx + dy * dy)
					let theta = calc.atan2(dy, dx)
					let force = dist  * calc.cos(theta) * 0.5
					forces.insert(node-id, forces.at(node-id) + force)
					forces.insert(to, forces.at(to) - force)
				}

			}
			// Apply forces
			for (node-id, properties) in nodes {
				let y = properties.y
				let force = forces.at(node-id)
				y += force * alpha
				nodes-new.at(node-id).insert("y", y)
				// nodes-new.at(node-id).insert("force", force)
			}
			nodes = nodes-new
		}

		return nodes
	}, drawer: (nodes, ribbon-colorizer) => {
		cetz.canvas({
			import cetz.draw: *
			
			
			let acc-out-size = (:)
			let acc-in-size = (:)
			for (node-id, properties) in nodes {
				let (x, y, width, height) = properties
				rect((x - width/2, y - height/2), (x + width/2, y + height/2), fill: properties.color, stroke: none)
				// forces
				// let force = properties.at("force", default: 0)
				// if (force != 0) {
				// 	let sign = if (force > 0) { 1 } else { -1 }
				// 	let len = calc.min(calc.abs(force), 1)
				// 	line((x, y), (x, y + len * sign), stroke: red, stroke-width: 0.05, end-arrow: (size: 0.1, angle: 20))
				// }
				content((x, y), text(node-id, size: 8pt))

				// ribbons
				for (to-node-id, edge-size) in properties.edges {
					let to-properties = nodes.at(to-node-id)
					let top-left = (x + width / 2, y + height / 2 - acc-out-size.at(node-id, default: 0) / properties.size * height)
					let bottom-left = (top-left.at(0), top-left.at(1) - edge-size / properties.size * height)
					let top-right = (to-properties.x - to-properties.width / 2, to-properties.y + to-properties.height / 2 - acc-in-size.at(to-node-id, default: 0) / to-properties.size * to-properties.height)
					let bottom-right = (top-right.at(0), top-right.at(1) - edge-size / to-properties.size * to-properties.height)
					acc-out-size.insert(node-id, acc-out-size.at(node-id, default: 0) + edge-size)
					acc-in-size.insert(to-node-id, acc-in-size.at(to-node-id, default: 0) + edge-size)

					let ribbon-width = calc.min(top-left.at(1) - bottom-left.at(1), top-right.at(1) - bottom-right.at(1))

					// TODO: Fine tune bezier control points
					let bezier-top-control-1 = point-translate(point-mix(top-left, top-right, 0.5), (0, ribbon-width * 0.1))
					let bezier-top-control-2 = point-translate(point-mix(top-left, top-right, 0.5), (0, -ribbon-width * 0.1))
					let bezier-bottom-control-1 = point-translate(point-mix(bottom-left, bottom-right, 0.5), (0, ribbon-width * 0.1))
					let bezier-bottom-control-2 = point-translate(point-mix(bottom-left, bottom-right, 0.5), (0, -ribbon-width * 0.1))
					merge-path(
						fill: ribbon-colorizer(properties.color, to-properties.color, node-id, to-node-id),
						stroke: none,
						{
							bezier(top-left, top-right, bezier-top-control-1, bezier-top-control-2)
							line(top-right, bottom-right)
							bezier(bottom-right, bottom-left, bezier-bottom-control-1, bezier-bottom-control-2)
							line(bottom-left, top-left)
						}
					)
				}
			}
		})

	})
}


/*
Ribbon colorizers
*/

#let ribbon-from-color = (
	transparency: 75%,
) => {
	(from-color, to-color, from-node, to-node) => from-color.transparentize(transparency)
}
#let ribbon-to-color = (
	transparency: 75%,
) => {
	(from-color, to-color, from-node, to-node) => to-color.transparentize(transparency)
}
#let ribbon-gradient-from-to = (
	transparency: 75%,
) => {
	(from-color, to-color, from-node, to-node) => {
		gradient.linear(from-color.transparentize(transparency), to-color.transparentize(transparency))
	}
}
#let ribbon-color = (
	color: black,
	transparency: 90%,
) => {
	(from-color, to-color, from-node, to-node) => color.transparentize(transparency)
}


#let sankey = (
	data,
	layout: auto-linear-layout(),
	tinter: layer-tinter(),
	ribbon-color: ribbon-from-color()
) => {
	let nodes = preprocess-data(data)
	let (layouter, drawer) = layout
	nodes = layouter(nodes)
	nodes = tinter(nodes)
	drawer(nodes, ribbon-color)
	repr(nodes)
	repr(topo-sort(nodes))
}


#sankey(
	(
		"A": ("B": 5, "C": 3),
		"B": ("D": 2, "E": 4),
		"C": ("D": 3, "E": 4),
		"E": ("F": 2),
	)
)
#sankey(
	// (
	// 	"iPhone": (
	// 		"Products": 44582
	// 	),
	// 	"Wearables, Home, Accessories": (
	// 		"Products": 7404
	// 	),
	// 	"Mac": (
	// 		"Products": 8046
	// 	),
	// 	"iPad": (
	// 		"Products": 6581
	// 	),
	// 	"Products": (
	// 		"Apple Net Sales Quarter": 66613
	// 	),
	// 	"Services": (
	// 		"Apple Net Sales Quarter": 27423
	// 	),
	// 	"Apple Net Sales Quarter": (
	// 		"Cost of Sales": 50318,
	// 		"Gross Margin": 43718
	// 	),
	// 	"Gross Margin": (
	// 		"Research & Development": 8866,
	// 		"Selling, General, Administrative": 6650,
	// 		"Operating Income": 28202
	// 	),
	// 	"Operating Income": (
	// 		"Other Expense": 171,
	// 		"Income before Taxes": 28031
	// 	),
	// 	"Income before Taxes": (
	// 		"Taxes": 4597,
	// 		"Net Income": 23434
	// 	)
	// ),
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
		layers: (
			"Services": 1,
		)
	)
)


#sankey(
	(
		"A": ("B": 4, "C": 9, "D": 4),
		"B": ("E": 2, "F": 2),
		"E": ("G": 1, "H": 1)
	)
)