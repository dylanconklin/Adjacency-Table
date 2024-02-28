//
//  GraphEditor.swift
//  Lineosaur
//
//  Created by Dylan Conklin on 8/27/23.
//

import SwiftData
import SwiftUI
import TipKit

enum GraphElement {
    case edges
    case vertices
}

struct GraphEditor: View {
    @Bindable var graph: Graph
    @State var graphElement: GraphElement = .edges
    @State private var showVertexBuilder: Bool = false
    @State private var showEdgeCreator: Bool = false
    @State private var vertexName: String = ""
    @State private var showTutorial = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type of graph to display", selection: $graphElement) {
                    Text("Edges").tag(GraphElement.edges)
                    Text("Vertices").tag(GraphElement.vertices)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                TipView(TutorialTip()) { _ in
                    showTutorial = true
                }
                .sheet(isPresented: $showTutorial) {
                    Tutorial()
                }

                switch graphElement {
                    case .edges:
                        EdgeList(graph: graph)
                    case .vertices:
                        VertexList(graph: graph)
                }
                
                Spacer()
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            Button("Help", systemImage: "questionmark.circle") {
                                showTutorial = true
                            }
                        }

                        ToolbarItemGroup(placement: .topBarTrailing) {
                            EditButton()

                            Button("Add", systemImage: "plus") {
                                if graphElement == .vertices {
                                    showVertexBuilder = true
                                } else if graphElement == .edges {
                                    showEdgeCreator = true
                                }
                            }
                            .sheet(isPresented: $showEdgeCreator) {
                                EdgeCreator(graph: graph)
                            }
                            .alert("Add Vertex", isPresented: $showVertexBuilder) {
                                TextField("Add Vertex", text: $vertexName, prompt: Text("Vertex Name"))
                                Button ("Cancel", role: .cancel) {
                                    showVertexBuilder = false
                                    vertexName = ""
                                }
                                Button ("Add") {
                                    graph.insert(vertexName)
                                    vertexName = ""
                                }
                            }
                        }
                    }
            }
            .navigationTitle("Graph Editor")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Edge List") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: connected_graph, graphElement: .edges)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}

#Preview("Vertex List") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: connected_graph, graphElement: .vertices)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}

#Preview("Empty Graph (Edge)") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: Graph(), graphElement: .edges)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}

#Preview("Empty Graph (Vertices)") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: Graph(), graphElement: .vertices)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
