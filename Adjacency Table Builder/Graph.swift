//
//  Graph.swift
//  Adjacency Table
//
//  Created by Dylan Conklin on 7/21/23.
//

import Foundation

typealias Vertex = String
typealias Graph = [Set<Vertex>: Double]

struct Edge: Hashable {
    var vertices: Set<Vertex>
    var weight: Double
    
    /// Returns vertices of the edge, as an array
    var verticesArray: [Vertex] {
        get {
            Array(vertices).sorted()
        }
        set {
            vertices = Set<Vertex>(newValue)
        }
    }
}

/// Observable object containing a graph
///
/// NOTE: Bindings to a graph is a better way to do this
/// But I have to demonstrate that I can use Observable Objects to potential employers
public class GraphData: ObservableObject {
    @Published var G: Graph = [Set(["Baltimore", "Barre"]): 496,
                               Set(["Baltimore", "Portland"]): 2810,
                               Set(["Baltimore", "Richmond"]): 149,
                               Set(["Baltimore", "SLC"]): 2082,
                               Set(["Barre", "Portland"]): 3052,
                               Set(["Barre", "Richmond"]): 646,
                               Set(["Barre", "SLC"]): 2328,
                               Set(["Portland", "Richmond"]): 2867,
                               Set(["Portland", "SLC"]): 768,
                               Set(["Richmond", "SLC"]): 2141,
    ]
    
    /// Generate the Minimum Spanning Tree (MST)
    var MST: Graph {
        G.mst()
    }
}

extension Graph {
    /// Insert edge into graph
    /// - Parameter edge: Edge object containing two vertices and the weight between them
    mutating func insert(edge: Edge) {
        self[edge.vertices] = edge.weight
    }
    
    /// Returns the vertices of the graph
    var vertices: Set<Vertex> {
        var vertices: Set<Vertex> = []
        forEach { edge in
            vertices.formUnion(edge.key)
        }
        return vertices
    }

    /// Returns the vertices of the graph, as an array
    var verticesArray: [Vertex] {
        Array(vertices).sorted()
    }
    
    /// Returns edges of the graph, in the form of Edge objects
    var edges: Set<Edge> {
        var edges: Set<Edge> = []
        vertices.forEach { v1 in
            self.vertices.forEach { v2 in
                if self[Set([v1, v2])] != nil {
                    edges.insert(Edge(vertices: Set([v1, v2]), weight: self[Set([v1, v2])] ?? 0.0))
                }
            }
        }
        return edges
    }

    /// Returns edges of the graph, in the form of Edge objects in an array
    var edgesArray: [Edge] {
        get {
            Array(edges).sorted(by: {
                let index: Int = $0.verticesArray[0] != $1.verticesArray[0] ? 0 : 1
                return $0.verticesArray[index] < $1.verticesArray[index]
            })
        }
        set {
            removeAll()
            for edge in newValue {
                insert(edge: Edge(vertices: edge.vertices, weight: edge.weight))
            }
        }
    }
    
    /// Calculates the total cost of the graph
    /// The cost is the sum of the weight (length) of all the edges in the graph
    var cost: Double {
        self.values.reduce(0, +)
    }
    
    /// Calculates the minimum spanning tree (MST) of a graph
    /// - Returns: The MST Graph generated by the edges in the graph
    func mst() -> Graph {
        var G: Graph = self
        var vertices_left: Set<Vertex> = G.vertices // vertices that don't have an edge
        var MST: Graph = [:]

        while let edge = G.filter({ $0.key.containsAny(in: vertices_left) && $0.key.containsAny(in: MST.vertices) }).sorted(by: { $0.value < $1.value }).first ?? (MST.isEmpty ? G.sorted(by: { $0.value < $1.value }).first : nil) {
            MST.insert(edge: Edge(vertices: edge.key, weight: edge.value))
            for vertex in edge.key {
                vertices_left.remove(vertex)
            }
            G.removeValue(forKey: edge.key)
        }

        return MST
    }
}

extension Set {
    /// Check if there are any shared elements between the sets
    /// - Parameter set: Any set containing any type of element
    /// - Returns: Returns true if there are any shared elements between the sets, otherwise false
    func containsAny(in set: Set) -> Bool {
        var result: Bool = false
        for element in set {
            if contains(element) {
                result = true
            }
        }
        return result
    }
}
