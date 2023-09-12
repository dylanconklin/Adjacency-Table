//
//  Graph.swift
//  Adjacency Table
//
//  Created by Dylan Conklin on 7/21/23.
//

import Foundation

typealias Vertex = String
typealias Graph = Set<Edge>

struct Edge: Hashable, Comparable {
    var from: Vertex
    var to: Vertex
    var weight: Double

    static func < (lhs: Edge, rhs: Edge) -> Bool {
        lhs.weight < rhs.weight
    }

    /// Returns vertices of the edge
    var vertices: [Vertex] {
        get {
            [from, to]
        }
        set {
            guard newValue.count == 2 else {
                return
            }
            from = newValue[0]
            to = newValue[1]
        }
    }

    var isVertex: Bool {
        to == from && weight == 0
    }
}

let acyclic_graph: Graph = [
    Edge(from: "1", to: "2", weight: 1),
    Edge(from: "2", to: "3", weight: 1),
    Edge(from: "2", to: "4", weight: 1),
    Edge(from: "4", to: "5", weight: 1),
    Edge(from: "4", to: "6", weight: 1),
    Edge(from: "5", to: "6", weight: 1),
    Edge(from: "6", to: "3", weight: 1),
]

let cyclic_graph: Graph = [
    Edge(from: "1", to: "2", weight: 1),
    Edge(from: "2", to: "3", weight: 1),
    Edge(from: "2", to: "4", weight: 1),
    Edge(from: "4", to: "5", weight: 1),
    Edge(from: "5", to: "6", weight: 1),
    Edge(from: "6", to: "3", weight: 1),
    Edge(from: "6", to: "4", weight: 1),
]

var cities: Graph = [
    Edge(from: "Baltimore", to: "Barre", weight: 496),
    Edge(from: "Baltimore", to: "Portland", weight: 2810),
    Edge(from: "Baltimore", to: "Richmond", weight: 149),
    Edge(from: "Baltimore", to: "SLC", weight: 2082),
    Edge(from: "Barre", to: "Portland", weight: 3052),
    Edge(from: "Barre", to: "Richmond", weight: 646),
    Edge(from: "Barre", to: "SLC", weight: 2328),
    Edge(from: "Portland", to: "Richmond", weight: 2867),
    Edge(from: "Portland", to: "SLC", weight: 768),
    Edge(from: "Richmond", to: "SLC", weight: 2141),
]

/// Observable object containing a graph
///
/// NOTE: Bindings to a graph is a better way to do this
/// But I have to demonstrate that I can use Observable Objects to potential employers
public class GraphData: ObservableObject {
    @Published var G: Graph = acyclic_graph
}

extension Graph {
    mutating func insert(_ vertex: Vertex) {
        insert(Edge(from: vertex, to: vertex, weight: 0))
    }

    mutating func remove(_ vertex: Vertex) {
        filter({ $0.vertices.contains(vertex) }).forEach { edge in
            self.remove(edge)
        }
    }

    /// Returns the vertices of the graph
    var vertices: [Vertex] {
        get {
            var vertices: Set<Vertex> = Set<Vertex>()
            forEach { edge in
                vertices.formUnion(edge.vertices)
            }
            return Array<Vertex>(vertices).sorted()
        }
        set {
            Set<Vertex>(vertices).symmetricDifference(Set<Vertex>(newValue)).forEach { vertex in
                if self.vertices.count < newValue.count {
                    insert(Edge(from: vertex, to: vertex, weight: 0))
                } else {
                    remove(vertex)
                }
            }
        }
    }

    /// Calculates the total cost of the graph
    /// The cost is the sum of the weight (length) of all the edges in the graph
    var cost: Double {
        var result: Double = 0
        forEach({ edge in
            result += edge.weight
        })
        return result
    }

    /// Generate the Minimum Spanning Tree (MST)
    /// - Returns: The MST Graph generated by the edges in the graph
    var mst: Graph {
        var G: Graph = self
        var vertices_left: Set<Vertex> = Set<Vertex>(G.vertices) // vertices that don't have an edge
        var MST: Graph = []

        while let edge = G.filter({ !Set<Vertex>($0.vertices).intersection(vertices_left).isEmpty && !Set<Vertex>($0.vertices).intersection(MST.vertices).isEmpty }).sorted(by: { $0.weight < $1.weight }).first ?? (MST.isEmpty ? G.sorted(by: { $0.weight < $1.weight }).first : nil) {
            MST.insert(edge)
            for vertex in edge.vertices {
                vertices_left.remove(vertex)
            }
            G.remove(edge)
        }

        return MST
    }

    /// Returns edges of the graph, in the form of Edge objects in an array
    var edges: [Edge] {
        get {
            Array(self).sorted(by: {
                let index: Int = $0.from != $1.from ? 0 : 1
                return $0.vertices[index] < $1.vertices[index]
            })
        }
        set {
            removeAll()
            newValue.forEach { edge in
                insert(edge)
            }
        }
    }

    func edges(from: String, to: String, directional: Bool = true) -> Set<Edge> {
        var result: Set<Edge> = Set<Edge>()
        let f = directional ? { (from: String, to: String, edge: Edge) -> Bool in
            edge.to == to && edge.from == from
        } : { (from: String, to: String, edge: Edge) -> Bool in
            Set<Vertex>(edge.vertices) == Set<Vertex>(arrayLiteral: from, to)
        }

        for edge in edges {
            if f(from, to, edge) && !edge.isVertex {
                result.insert(edge)
            }
        }

        return result
    }

    var leaves: Set<Vertex> {
        var result: Set<Vertex> = Set<Vertex>()

        for vertex in vertices {
            if self.filter({ $0.from == vertex }).isEmpty {
                result.insert(vertex)
            }
        }

        return result
    }

    var isCyclic: Bool {
        var result: Bool = false
        var graph: Graph = self

        while !graph.leaves.isEmpty {
            graph.leaves.forEach({ graph.remove($0) })
        }
        
        result = !graph.isEmpty

        return result
    }
}
