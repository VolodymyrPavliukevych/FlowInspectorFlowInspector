//
//  Document.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/19/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa
import TensorFlowKit
import Proto

public enum FIDocumentError: Error {
    case canNotLoadSourceFileContent(url: String)
    case canNotComputeBinFileURL
    case canNotComputeDSYMFileURL
    case canNotComputeSourceFileURL
}


protocol FIDocumentInteraction: SourceTreeViewOutput, CodeViewOutput, GraphViewOutput {
    func injectCodeViewInput(_ input: CodeViewInput)
    func injectDebugViewInput(_ input: DebugViewInput)
    func injectGraphViewInput(_ input: GraphViewInput)
}

extension FIDocument: FIDocumentInteraction {
    func selectSourceFile(callback: @escaping (_ fileName: String) -> Void) {
        self.projectWindowControllerInput?.openFile(format: [FIDocument.sourceFileFormat], callback: { (url) in
            self.model.sourceFilePath = url.absoluteString
            self.analizeEnvironment()
            self.loadSourceFile(url: url)
            callback(url.lastPathComponent)
        })
    }
    
    func selectProgramFile(callback: @escaping (_ fileName: String) -> Void) {
        self.projectWindowControllerInput?.openFile(format: [FIDocument.binFileFormat], callback: { (url) in
            self.model.binFilePath = url.absoluteString
            self.analizeEnvironment()
            callback(url.lastPathComponent)
        })
    }
    
    func selectDSYMFile(callback: @escaping (_ fileName: String) -> Void) {
        self.projectWindowControllerInput?.openFolder(format: [FIDocument.dSYMFileFormat], callback: { (url) in
            self.model.dSYMFilePath = url.absoluteString
            callback(url.lastPathComponent)
        })
    }
    
    func injectCodeViewInput(_ input: CodeViewInput) {
        self.codeViewInput = input
    }
    
    func injectDebugViewInput(_ input: DebugViewInput) {
        self.debugViewInput = input
    }
    
    func injectGraphViewInput(_ input: GraphViewInput) {
        self.graphViewInput = input
    }
}


struct GraphMarker: Codable {
    let filePath: String
    let lineNumber: Int
    var enabled: Bool
    let functionName: String
    let uuid: String = UUID().uuidString
}


struct GraphModel {
    enum Kind {
        case function
        case main
    }
    var graphData: Data
    var scope: Scope
    var graph: Graph
    var graphDef: Tensorflow_GraphDef
    var kind: Kind
    var viewModel: GraphViewModel
}

struct FIDocumentModel { /*SWIFT_TENSORFLOW_ENABLE_DEBUG_LOGGING=true,*/
    var preferences: Preferences = Preferences(argument: "4.54,0.001", environment: "PATH=/Library/Developer/Toolchains/swift-latest/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin")
    var sourceFilePath: String?
    var binFilePath: String?
    var dSYMFilePath: String?
    var marker: GraphMarker?

    var mainGraph: GraphModel?
    var functionGraph: GraphModel?
}


class FIDocument: NSDocument {

    var model: FIDocumentModel = FIDocumentModel()
    static let sourceFileFormat = "swift"
    static let binFileFormat = ""
    static let dSYMFileFormat = "DSYM"
    
    lazy var processorInput: ProcessorInput = {
        return Processor(output: self)
    }()
    
    var projectWindowControllerInput: ProjectWindowControllerInput? {
        get {
            let inputs = self.windowControllers.filter { $0 is ProjectWindowControllerInput }
            return inputs.first as? ProjectWindowControllerInput
        }
    }
    
    var codeViewInput: CodeViewInput?
    var debugViewInput: DebugViewInput?
    var graphViewInput: GraphViewInput?
    
    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let projectSceneIdentifier = NSStoryboard.SceneIdentifier("ProjectWindowController")
        guard let windowController =  storyboard.instantiateController(withIdentifier: projectSceneIdentifier) as? ProjectWindowController else { return }
        windowController.inject(document: self)
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    func loadSourceFile(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.codeViewInput?.load(content: data, filePath: url.absoluteString)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func analizeEnvironment() {
        self.projectWindowControllerInput?.extractMainGraphAction(available: self.model.binFilePath != nil)

        guard self.model.sourceFilePath != nil else {
            projectWindowControllerInput?.progressText("Please, select source file.")
            return
        }

        guard self.model.binFilePath != nil else {
            projectWindowControllerInput?.progressText("Please, select program file.")
            return
        }
        
        guard self.model.marker != nil else {
            projectWindowControllerInput?.progressText("Please, select function in your code.")
            return
        }
        projectWindowControllerInput?.progressText("Ready, now you can read graph.")
    }
    
    func graphDidFound(_ data: Data, kind: GraphModel.Kind) {
        let scope = Scope()

        do {
            try scope.graph.import(data: data, prefix: "")
            let graphDef = try Tensorflow_GraphDef(serializedData: data)
            
            let graphViewModel = GraphViewModel(from: graphDef)
            self.graphViewInput?.shouwGraph(graph: try graphViewModel.serialize(), for: kind)
            let graphModel = GraphModel(graphData: data,
                                        scope: scope,
                                        graph: scope.graph,
                                        graphDef: graphDef,
                                        kind: kind,
                                        viewModel: graphViewModel)
            switch kind {
            case .function:
                self.model.functionGraph = graphModel
            case .main:
                self.model.mainGraph = graphModel
            }


        } catch {
            Swift.print(error.localizedDescription)
            return
        }
    }
}

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
        /*
        let available = self.model.markers.enumerated().filter { $0.element.filePath == filePath && $0.element.lineNumber == lineNumber }
        for (index, marker) in available.reversed() {
            Swift.print("Remove marker at: \(marker.lineNumber)")
            model.markers.remove(at: index)
        }
         */
    }
}

extension FIDocument: ProcessorOutput {

    func binFileURL() throws -> URL {
        guard let binFilePth = self.model.binFilePath else { throw FIDocumentError.canNotComputeBinFileURL }
        guard let url = URL(string: binFilePth) else { throw FIDocumentError.canNotComputeBinFileURL }
        return url
    }
    
    func dsymFileURL() throws -> URL {
        guard let dSYMFilePath = self.model.dSYMFilePath else { throw FIDocumentError.canNotComputeDSYMFileURL }
        guard let url = URL(string: dSYMFilePath) else { throw FIDocumentError.canNotComputeDSYMFileURL }
        return url
    }
    
    func sourceFileURL() throws -> URL {
        guard let sourceFilePath = self.model.sourceFilePath else { throw FIDocumentError.canNotComputeBinFileURL }
        guard let url = URL(string: sourceFilePath) else { throw FIDocumentError.canNotComputeSourceFileURL }
        return url
    }
    
    func outputStreamReceived(_ string: String) {
        self.debugViewInput?.insertOutput(string)
    }
    
    func errorStreamReceived(_ string: String) {
        self.debugViewInput?.insertError(string)
    }

}

extension FIDocument: ProjectWindowControllerOutput {
    func extractMainGraph() {
        projectWindowControllerInput?.progressIndicator(startAnimation: true)
        projectWindowControllerInput?.progressText("Looking for graph in program...")
        
        let finishCallback = {
            DispatchQueue.main.async {
                self.projectWindowControllerInput?.progressIndicator(startAnimation: false)
                if let data = self.model.mainGraph?.graphData {
                    self.projectWindowControllerInput?.progressText("Finished. Graph \(data.count) bytes.")
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
                    self.graphDidFound($0.program, kind: .main)
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
                if let data = self.model.functionGraph?.graphData {
                    self.projectWindowControllerInput?.progressText("Finished. Graph \(data.count) bytes.")
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
                    self.graphDidFound($0, kind: .function)
                    finishCallback()
                }
            })
        }
    }
    
    func shouldOpenPreferences() {
        projectWindowControllerInput?.showPreferences(self.model.preferences, output: self)
    }
    
}

extension FIDocument: GraphViewOutput {
    func launch(kind: GraphModel.Kind) {
        if kind == .main {
            guard let mainGraph = self.model.mainGraph else {
                return
            }
            Swift.print(mainGraph)
            /*processorInput.launchMainGraphExecution()*/
        }
    }
    
    func saveGraph(kind: GraphModel.Kind) {
        var graphMode: GraphModel? = nil
        
        switch kind {
        case .function:
            graphMode = self.model.functionGraph
        case .main:
            graphMode = self.model.mainGraph
        }
        guard let graph = graphMode?.graph else {
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
        
        guard let graph = graphMode?.graph else {
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

extension FIDocument: PreferencesOutput {
    func update(_ preferences: Preferences) {
        self.model.preferences = preferences
    }
}
