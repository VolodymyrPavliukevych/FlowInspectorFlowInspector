//
//  Document.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/19/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa
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


struct FIDocumentModel { /*SWIFT_TENSORFLOW_ENABLE_DEBUG_LOGGING=true,*/
    var preferences: Preferences = Preferences(argument: "4.54,0.001",
                                               environment: "SWIFT_TENSORFLOW_ENABLE_DEBUG_LOGGING=true,PATH=/Library/Developer/Toolchains/swift-latest/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin")
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
    
    lazy var graphExecutorInput: GraphExecutorInput = {
        return GraphExecutor(output: self)
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
    
    func graphDidFound(_ data: Data, kind: GraphModel.Kind, entryFunctionBaseName: String? = nil, tensorArgument: [Tensorflow_TensorProto]? = nil) {
        
        do {
            let graphDef = try Tensorflow_GraphDef(serializedData: data)
            let graphModel = GraphModel(graphDef: graphDef,
                                        kind: kind,
                                        entryFunctionBaseName: entryFunctionBaseName,
                                        tensorArgument: tensorArgument)
            
            switch kind {
            case .function:
                self.model.functionGraph = graphModel
            case .main:
                self.model.mainGraph = graphModel
            }
            
            self.graphViewInput?.shouwGraph(graph: try graphModel.viewModel.serialize(), for: kind)
            
        } catch {
            self.heppend(error)
        }
    }
    
    func heppend(_ error: Error) {
        Swift.print(error.localizedDescription)
    }
}

