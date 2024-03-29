//
//  Settings.swift
//  Lineosaur
//
//  Created by Dylan Conklin on 9/30/23.
//

import SwiftUI

enum Compiler: String {
    case dot
    case fdp
    case neato
    case circo
    case twopi
    case osage
    case patchwork
}

struct Settings: View {
    @AppStorage("displayEdgeWeights") var displayEdgeWeights: Bool = false
    @AppStorage("deleteDetachedVertices") var deleteDetachedVertices: Bool = false
    @AppStorage("compiler") var compiler: Compiler = .dot

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show Edge Weights", isOn: $displayEdgeWeights)

                #warning("Unimplemented: Delete Detatched Vertices")
                Toggle("Delete Detached Vertices", isOn: $deleteDetachedVertices)

                Picker("Compiler", selection: $compiler) {
                    Text("Dot").tag(Compiler.dot)
                    Text("FDP").tag(Compiler.fdp)
                    Text("Neato").tag(Compiler.neato)
                    Text("Circo").tag(Compiler.circo)
                    Text("TwoPi").tag(Compiler.twopi)
                    Text("Osage").tag(Compiler.osage)
                    Text("Patchwork").tag(Compiler.patchwork)
                }

                NavigationLink {
                    GraphSelector()
                } label: {
                    Label("Open Graph", systemImage: "folder")
                }

                NavigationLink {
                    VStack {
                        Text("Developed by Dylan Conklin")
                            .padding()
                        Text("Made with ❤️ in Portland, OR")
                            .padding()
                        Text("MIT License")
                            .padding()
                    }
                } label: {
                    Label("About GraphApp", systemImage: "info")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    Settings()
}
