//
//  GraphFacts.swift
//  Lineosaur
//
//  Created by Dylan Conklin on 9/11/23.
//

import SwiftData
import SwiftUI

struct GraphFact: View {
    var fact: String
    var symbol: String
    var value: Bool?

    var body: some View {
        Grid {
            GridRow {
                ZStack {
                    Image(systemName: symbol)
                        .font(.system(size: 32))
                    if value == true {
                        Image(systemName: "xmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.red)
                    }
                }
                .frame(minHeight: 48)
                .padding(.horizontal)
                Text(fact)
                    .padding(.horizontal)
            }
        }
    }
}

struct GraphFacts: View {
    @Bindable var graph: Graph
    
    var body: some View {
        CloseButtonView(title: "Graph Facts", titleStyle: .inline) {
            List {
                GraphFact(fact: "The graph has \(graph.edges.count) edge\(graph.edges.count == 1 ? "" : "s") and \(graph.vertices.count) \(graph.vertices.count == 1 ? "vertex" : "vertices")",
                          symbol: "point.topleft.down.curvedto.point.bottomright.up")
                GraphFact(fact: "The cost is \(graph.cost)",
                          symbol: "clock")
                GraphFact(fact: "The graph is \(graph.isCyclic ? "" : "a")cyclic",
                          symbol: "arrow.triangle.2.circlepath",
                          value: !graph.isCyclic)
                GraphFact(fact: "The graph is \(graph.isConnected ? "" : "not ")connected",
                          symbol: "point.3.connected.trianglepath.dotted",
                          value: !graph.isConnected)
                GraphFact(fact: "The graph is \(graph.isTree ? "" : "not ")a tree",
                          symbol: "tree",
                          value: !graph.isTree)
                GraphFact(fact: "The graph is \(graph.isBipartite ? "" : "not ")bipartite",
                          symbol: "rectangle.split.2x1",
                          value: !graph.isBipartite)
            }
        }
    }
}

#Preview("Empty Graph") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphFacts(graph: Graph())
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}

#Preview("Non-Empty Graph") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphFacts(graph: connected_graph)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
