//
//  Graph.swift
//  Adjacency Table
//
//  Created by Dylan Conklin on 7/21/23.
//

import Foundation

typealias Vertex = String

enum GraphType {
    case mst
    case given
}

struct Graph: Equatable {
    private var graphEdges: Set<Edge> = []
    private var graphVertices: Set<Vertex> = []

    mutating func insert(_ vertex: Vertex) {
        graphVertices.insert(vertex)
    }

    mutating func insert(_ edge: Edge) {
        graphEdges.insert(edge)
        insert(edge.from)
        insert(edge.to)
    }

    var isEmpty: Bool {
        graphEdges.isEmpty && graphVertices.isEmpty
    }

    mutating func remove(_ vertex: Vertex) {
        graphEdges.filter({ $0.vertices.contains(vertex) }).forEach { edge in
            remove(edge)
        }
        graphVertices.remove(vertex)
    }

    mutating func remove(_ vertices: any Collection<Vertex>) {
        vertices.forEach { vertex in
            remove(vertex)
        }
    }

    mutating func remove(_ edge: Edge) {
        graphEdges.remove(edge)
    }

    mutating func remove(_ edges: any Collection<Edge>) {
        edges.forEach { edge in
            remove(edge)
        }
    }

    /// Returns the vertices of the graph
    var vertices: [Vertex] {
        get {
            graphVertices.sorted()
        }
        set {
            let newVertices = Set<Vertex>(newValue)
            let difference = Set<Vertex>(vertices).symmetricDifference(newVertices)

            if vertices.count < newVertices.count {
                graphVertices.formUnion(difference)
            } else {
                difference.forEach { remove($0) }
            }
        }
    }

    /// Calculates the total cost of the graph
    /// The cost is the sum of the weight (length) of all the edges in the graph
    var cost: Double {
        edges.reduce(0.0, { $0 + $1.weight })
    }

    /// Generate the Minimum Spanning Tree (MST)
    /// - Returns: The MST Graph generated by the edges in the graph
    var mst: Graph {
        var G: Graph = self
        var vertices_left: Set<Vertex> = Set<Vertex>(G.vertices) // vertices that don't have an edge
        var MST: Graph = Graph()

        while let edge = G.edges.sorted(by: { $0.weight < $1.weight }).first(where: {
            let a = Set<Vertex>($0.vertices).intersection(vertices_left)
            let b = Set<Vertex>($0.vertices).intersection(MST.vertices)
            return !a.isEmpty && !b.isEmpty
        }) ?? (MST.isEmpty ? G.edges.sorted(by: { $0.weight < $1.weight }).first : nil) {
            MST.insert(edge)
            G.remove(edge)
            vertices_left.subtract(edge.vertices)
        }

        return MST
    }

    /// Returns edges of the graph, in the form of Edge objects in an array
    var edges: [Edge] {
        get {
            graphEdges.sorted(by: {
                if $0.from != $1.from {
                    return $0.from < $1.from
                } else if $0.to != $1.to {
                    return $0.to < $1.to
                } else {
                    return $0.weight < $1.weight
                }
            })
        }
        set {
            let difference = Set(newValue).symmetricDifference(Set(edges))
            let addOrRemove = edges.count < newValue.count ? { (edge: Edge) in
                insert(edge)
            } : { (edge: Edge) in
                remove(edge)
            }
            difference.forEach(addOrRemove)
        }
    }

    func edges(from: Vertex, to: Vertex, directional: Bool = true) -> Set<Edge> {
        var result: Set<Edge> = Set<Edge>()
        let f = directional ? { (from: Vertex, to: Vertex, edge: Edge) -> Bool in
            edge.to == to && edge.from == from
        } : { (from: Vertex, to: Vertex, edge: Edge) -> Bool in
            Set<Vertex>(edge.vertices) == Set<Vertex>(arrayLiteral: from, to)
        }

        edges.forEach { edge in
            if f(from, to, edge) {
                result.insert(edge)
            }
        }

        return result
    }

    func edges(connectedTo vertex: Vertex) -> Set<Edge> {
        return Set(edges.filter { $0.vertices.contains(vertex) })
    }

    func edges(connectedTo vertices: any Collection<Vertex>) -> Set<Edge> {
        return vertices.reduce(into: Set<Edge>()) { result, vertex in
            result.formUnion(self.edges(connectedTo: vertex))
        }
    }

    var leaves: Set<Vertex> {
        Set<Vertex>(vertices.filter { vertex in
            graphEdges.filter { $0.from == vertex }.isEmpty
        })
    }

    var loops: Set<Edge> {
        Set(edges.filter { $0.from == $0.to })
    }

    var isCyclic: Bool {
        var graph: Graph = self
        while !graph.leaves.isEmpty {
            graph.leaves.forEach {
                graph.remove($0)
            }
        }
        return !graph.isEmpty
    }

    var isConnected: Bool {
        var connectedVertices: Set<Vertex> = vertices.isEmpty ? [] : [vertices.randomElement()!]
        var connectedEdges: Set<Edge> = Set<Edge>()
        while !edges(connectedTo: connectedVertices).subtracting(connectedEdges).isEmpty {
            let newEdges = edges(connectedTo: connectedVertices)
            connectedEdges.formUnion(newEdges)
            connectedVertices.formUnion(newEdges.flatMap { $0.vertices })
        }
        return Set(edges).subtracting(connectedEdges).isEmpty
    }

    func isBipartite(selectedVertex: Vertex, _ groupA: inout Set<Vertex>, _ groupB: inout Set<Vertex>, _ group: Bool = true, visitedEdges: Set<Edge> = Set<Edge>()) {
        if group {
            groupA.insert(selectedVertex)
        } else {
            groupB.insert(selectedVertex)
        }
        let connectedEdges: Set<Edge> = edges(connectedTo: selectedVertex).filter({ $0.from != $0.to }).subtracting(visitedEdges)
        let visitedEdges: Set<Edge> = visitedEdges.union(connectedEdges)
        var connectedVertices: Set<Vertex> = connectedEdges.reduce(into: Set<Vertex>(), { $0.formUnion($1.vertices) })
        connectedVertices.remove(selectedVertex)
        connectedVertices.forEach { vertex in
            isBipartite(selectedVertex: vertex, &groupA, &groupB, !group, visitedEdges: visitedEdges)
        }

        let leftoverVertices: Set<Vertex> = Set(vertices).subtracting(groupA).subtracting(groupB)
        if !leftoverVertices.isEmpty {
            isBipartite(selectedVertex: leftoverVertices.randomElement()!, &groupA, &groupB, !group, visitedEdges: visitedEdges)
        }
    }

    var isBipartite: Bool {
        var groupA: Set<Vertex> = Set<Vertex>()
        var groupB: Set<Vertex> = Set<Vertex>()

        if !vertices.isEmpty {
            isBipartite(selectedVertex: vertices.randomElement()!, &groupA, &groupB)
        }

        return groupA.intersection(groupB).isEmpty
    }

    var isTree: Bool {
        isConnected && !isCyclic
    }

    var isTrivial: Bool {
        edges.count == 0 && vertices.count == 1
    }

    var isComplete: Bool {
        for vertex in vertices {
            let connectedVertices: [Vertex] = edges(connectedTo: vertex).flatMap { $0.vertices }
            if Set(connectedVertices).count != vertices.count {
                return false
            }
        }
        return true
    }

    var isSimple: Bool {
        for v1 in vertices {
            for v2 in vertices {
                if edges(from: v1, to: v2, directional: false).count > 1 {
                    return false
                }
            }
        }
        return true
    }

    var isMulti: Bool {
        if loops.isEmpty {
            for v1 in vertices {
                for v2 in vertices {
                    if edges(from: v1, to: v2, directional: false).count > 1 {
                        return true
                    }
                }
            }
        }
        return false
    }
}
