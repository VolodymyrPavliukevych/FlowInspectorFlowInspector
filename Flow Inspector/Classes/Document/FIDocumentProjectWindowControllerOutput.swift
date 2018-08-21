//
//  FIDocumentProjectWindowControllerOutput.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation

extension FIDocument: ProjectWindowControllerOutput {
    func launchProfiller() {
        
    }
    
    func extractMainGraph() {
        projectWindowControllerInput?.progressIndicator(startAnimation: true)
        projectWindowControllerInput?.progressText("Looking for graph in program...")
        
        let finishCallback = {
            DispatchQueue.main.async {
                self.projectWindowControllerInput?.progressIndicator(startAnimation: false)
                if let graphDef = self.model.mainGraph?.graphDef {
                    self.projectWindowControllerInput?.progressText("Finished. Graph with \(graphDef.node.count) nodes found.")
                } else {
                    self.projectWindowControllerInput?.progressText("Finished. Graph not found.")
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            self.processorInput.extractMainGraph(preferences: self.model.preferences, callback: { (result) in
                result.onNegative {
                    self.model.mainGraph = nil
                    Swift.print($0.localizedDescription)
                    finishCallback()
                }
                
                result.onPositive {
                    self.graphDidFound(as: $0, for: .main)
                    finishCallback()
                }
            })
        }
    }
    
    func extractFunctionGraph() {
        projectWindowControllerInput?.progressIndicator(startAnimation: true)
        projectWindowControllerInput?.progressText("Looking for graph in program...")
        
        guard let marker = self.model.marker else {
            self.projectWindowControllerInput?.extractFunctionGraphAction(available: false)
            return
        }
        
        let finishCallback = {
            DispatchQueue.main.async {
                self.projectWindowControllerInput?.progressIndicator(startAnimation: false)
                if let graphDef = self.model.functionGraph?.graphDef {
                    self.projectWindowControllerInput?.progressText("Finished. Graph with \(graphDef.node.count) nodes found.")
                } else {
                    self.projectWindowControllerInput?.progressText("Finished. Graph not found.")
                }
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            self.processorInput.extractGraph(at: marker.functionName, preferences: self.model.preferences, callback: { (result) in
                result.onNegative {
                    self.model.functionGraph = nil
                    Swift.print($0.localizedDescription)
                    finishCallback()
                }
                
                result.onPositive {
                    self.graphDidFound(as: $0, for: .function)
                    finishCallback()
                }
            })
        }
    }
    
    func shouldOpenPreferences() {
        projectWindowControllerInput?.showPreferences(self.model.preferences, output: self)
    }
}
