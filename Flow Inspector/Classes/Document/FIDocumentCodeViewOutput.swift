//
//  FIDocumentCodeViewOutput.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation

extension FIDocument: CodeViewOutput {
    func addGraphMarker(at filePath: String, lineNumber: Int, functionName: String) {
        model.marker = GraphMarker(filePath: filePath, lineNumber: lineNumber, enabled: true, functionName: functionName)
        self.codeViewInput?.addGraphMarker(at: filePath, lineNumber: lineNumber)
        self.projectWindowControllerInput?.extractFunctionGraphAction(available: true)
        analizeEnvironment()
    }
    
    func markerTurnOn(value :Bool, at filePath: String, lineNumber: Int) {}
    
    func removeMarker(at filePath: String, lineNumber: Int) {
        model.marker = nil
    }
}
