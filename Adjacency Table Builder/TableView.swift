//
//  TableView.swift
//  Adjacency Table
//
//  Created by Dylan Conklin on 8/9/23.
//

import SwiftUI

/// Displays graph data as an adjacency table, using cells to display each data point
struct TableView: View {
    var G: Graph
    @State var showDetails: Bool = false
    
    var body: some View {
        if G.isEmpty{
            VStack {
                Text("No table to view")
                Text("Go to the table builder to create a table")
            }
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                ScrollView(.horizontal, showsIndicators: true) {
                    Grid {
                        GridRow {
                            Cell {
                                Button {
                                    showDetails = true
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .padding()
                                        .padding()
                                }
                                .alert("Graph Details", isPresented: $showDetails){
                                    Button ("Okay") {
                                        showDetails = false
                                    }
                                } message: {
                                    VStack {
                                        Text("Cost is \(String(G.cost))\n\(G.vertices.count) vertices\n\(G.edges.count) edges")
                                    }
                                }
                            }
                            ForEach(G.vertices.sorted(), id: \.self) { x in
                                Cell {
                                    Text(String(x))
                                        .fontWeight(Font.Weight.bold)
                                }
                            }
                        }
                        ForEach(G.vertices.sorted(), id: \.self) { y in
                            GridRow {
                                Cell {
                                    Text(String(y))
                                        .fontWeight(Font.Weight.bold)
                                }
                                ForEach(G.vertices.sorted(), id: \.self) { x in
                                    var distance: String {
                                        var distance: String = ""
                                        distance = String(G[Set(arrayLiteral: y, x)] ?? 0.0)
                                        distance = y != x && distance == "0.0" ? "-" : distance
                                        return distance
                                    }
                                    Cell {
                                        Text(String(distance))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TableView_Previews: PreviewProvider {
    static let mst: Graph = [Set(["Baltimore", "Barre"]): 496,
                             Set(["Baltimore", "Richmond"]): 149,
                             Set(["Barre", "Richmond"]): 646,
    ]
    static var previews: some View {
        TableView(G: mst)
    }
}
