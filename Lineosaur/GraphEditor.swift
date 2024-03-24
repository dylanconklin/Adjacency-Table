//
//  GraphEditor.swift
//  Lineosaur
//
//  Created by Dylan Conklin on 8/27/23.
//

import SwiftData
import SwiftUI
import TipKit

struct GraphEditor: View {
    @Bindable var graph: Graph
    @State private var showVertexBuilder: Bool = false
    @State private var showEdgeCreator: Bool = false
    @State private var vertexName: String = ""
    @State private var showTutorial = false
    @State private var showVertexSection = true

    var body: some View {
        NavigationStack {
            VStack {
                TipView(TutorialTip()) { _ in
                    showTutorial = true
                }
                .padding(.horizontal)
                
                if graph.isEmpty {
                    ContentUnavailableView("No edges or vertices to display", systemImage: "hammer", description: Text("Tap on + to add data"))
                } else {
                    List {
                        if !graph.edges.isEmpty {
                            EdgeList(graph: graph)
                        }
                        if !graph.vertices.isEmpty {
                            Section("Vertices", isExpanded: $showVertexSection) {
                                ForEach($graph.vertices, id: \.self, editActions: .delete) { vertex in
                                    Text("\(vertex.wrappedValue)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                                .onDelete { offsets in
                                    withAnimation {
                                        for offset in offsets {
                                            graph.remove(graph.vertices[offset])
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Edge.self) { _ in Spacer() }
                    .listStyle(.sidebar)
                }
                
                Spacer()
                    .sheet(isPresented: $showTutorial) {
                        Tutorial()
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            if !graph.isEmpty {
                                EditButton()
                            } else {
                                Button("Help", systemImage: "questionmark.circle") { showTutorial = true }
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                if !graph.isEmpty {
                                    menu
                                }
                                addButton
                            }
                        }
                    }
            }
            .navigationTitle("Graph Editor")
        }
    }

    var addButton: some View {
        Menu("Add", systemImage: "plus") {
            Button("Add Edge", systemImage: "app.connected.to.app.below.fill") { showEdgeCreator = true }
            Button("Add Vertex", systemImage: "smallcircle.filled.circle") { showVertexBuilder = true }
        }
        .sheet(isPresented: $showEdgeCreator) {
            EdgeCreator(graph: graph)
        }
        .alert("Add Vertex", isPresented: $showVertexBuilder) {
            TextField("Add Vertex", text: $vertexName, prompt: Text("Vertex Name"))
            Button("Cancel", role: .cancel) {
                showVertexBuilder = false
                vertexName = ""
            }
            Button("Add") {
                graph.insert(vertexName)
                vertexName = ""
            }
        }
    }

    var menu: some View {
        Menu("Menu", systemImage: "ellipsis.circle") {
            Button("Help", systemImage: "questionmark.circle") { showTutorial = true }
            Menu("Delete Edges", systemImage: "app.connected.to.app.below.fill") {
                Button("Smallest Edges", systemImage: "trash", role: .destructive) {
                    graph.remove(graph.edges.sorted(by: <).first!)
                }
                Button("Largest Edges", systemImage: "trash", role: .destructive) {
                    graph.remove(graph.edges.sorted(by: >).first!)
                }
                Button("All Edges", systemImage: "trash", role: .destructive) { graph.deleteEdges() }
            }
            Menu("Delete Vertices", systemImage: "smallcircle.filled.circle") {
                Button("Detached Vertices", systemImage: "trash", role: .destructive) {
                    graph.deleteDetachedVertices()
                }
                Button("Leaves", systemImage: "trash", role: .destructive) { graph.deleteLeaves() }
            }
            Button("Delete Graph", systemImage: "trash", role: .destructive) {
                graph.deleteEdgesAndVertices()
            }
        }
        .onAppear {
            assert(!graph.isEmpty)
        }
    }
}

#Preview("Non-Empty Graph") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: connected_graph)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}

#Preview("Empty Graph") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Graph.self, configurations: config)
        return GraphEditor(graph: Graph())
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
