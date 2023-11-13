//
//  GraphVizViewer.swift
//  Adjacency Table Builder
//
//  Created by Dylan Conklin on 9/29/23.
//

import SwiftUI

struct GraphVizViewer: View {
    var graph: Graph

    @State private var graphType: GraphType = .given

    private var directional: Bool {
        if graphType == .given { return true }
        else if graphType == .mst { return false }
        else { return false }
    }

    var body: some View {
        VStack {
            Picker("Type of graph to display", selection: $graphType) {
                Text("Given").tag(GraphType.given)
                Text("MST").tag(GraphType.mst)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
            
            GraphViz(url: graph.generateGraphVizURL(of: graphType))
        }
    }
}

#Preview {
    GraphVizViewer(graph: Graph())
}
