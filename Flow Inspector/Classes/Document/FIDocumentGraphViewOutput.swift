//
//  FIDocumentGraphViewOutput.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import Proto
import SwiftProtobuf

extension Tensorflow_GraphDef {
    func save(at file: URL, asText: Bool = false) throws {
        if asText {
            let txtGraphDef = self.textFormatString()
            if let data = txtGraphDef.data(using: .ascii) {
                try data.write(to: file)
            }
        } else {
            try self.serializedData().write(to: file)
        }
    }
}
extension FIDocument: GraphViewOutput {
    func launchGraphExecution(kind: GraphModel.Kind) { }
    
    func saveGraph(kind: GraphModel.Kind) {
        var graphMode: GraphModel? = nil
        
        switch kind {
        case .function:
            graphMode = self.model.functionGraph
        case .main:
            graphMode = self.model.mainGraph
        }
        guard let graph = graphMode?.graphDef else {
            return
        }
        
        let message = "Please, select folder and name to save graph in 'pb' or 'pbtxt' format."
        self.projectWindowControllerInput?.save("Graph", allowedFileTypes: ["pb", "pbtxt"], message: message, callback: { (url) in
            let isTextFormat = url.pathExtension == "pbtxt"
            try? graph.save(at: url, asText: isTextFormat)
        })
    }
    
    func exportGraphAsEvent(kind: GraphModel.Kind) {
        var graphMode: GraphModel? = nil
        
        switch kind {
        case .function:
            graphMode = self.model.functionGraph
        case .main:
            graphMode = self.model.mainGraph
        }
        
        guard let graph = graphMode?.graphDef else {
            Swift.print("Graph not found in model.")
            return
        }
        
        let message = "Please, select folder and identifier to save graph in TensorBoard format."

        self.projectWindowControllerInput?.save("graph", allowedFileTypes: ["event"], message: message, callback: { (url) in
            let folderURL = URL(string: url.deletingLastPathComponent().path + "/")!
            do {
                let _ = try FileWriter(folder: folderURL, identifier: url.lastPathComponent, graph: graph)
            } catch {
                Swift.print(error.localizedDescription)
            }
        })
    }
}
