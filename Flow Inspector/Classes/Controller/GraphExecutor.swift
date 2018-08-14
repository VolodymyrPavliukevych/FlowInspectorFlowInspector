//
//  GraphExecutor.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/8/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import TensorFlowKit
import Proto

enum GraphExecutorError: Error {
    case notFound
}

protocol GraphExecutorInput {
    func launchTimeProfiler(for scope: Scope, entryFunctionBaseName: String, tensorArgument: [Tensorflow_TensorProto], callback: @escaping ResultCompletion<Tensorflow_RunMetadata>) -> GraphExecutorTask.TaskIdentifier
}

protocol GraphExecutorOutput {
    
}

class GraphExecutorTask {
    typealias TaskIdentifier = String
    let identifier: TaskIdentifier
    let scope: Scope
    let inputs: [Tensorflow_TensorProto]
    let entryFunctionBaseName: String
    
    init(scope: Scope, inputs: [Tensorflow_TensorProto], entryFunctionBaseName: String) {
        self.identifier = UUID().uuidString
        self.scope = scope
        self.inputs = inputs
        self.entryFunctionBaseName = entryFunctionBaseName
    }
}

class GraphExecutor {
    
    var output: GraphExecutorOutput!
    var tasks = [GraphExecutorTask]()
    let queue = DispatchQueue.global(qos: .default)
    init(output: GraphExecutorOutput) {
        self.output = output
        
    }
    
    func launchTimeProfiler(for task: GraphExecutorTask, callback: @escaping ResultCompletion<Tensorflow_RunMetadata>) {
        var options = Tensorflow_RunOptions()
        options.traceLevel = .hardwareTrace
        do {
            let session = try buildSession(for: task.scope.graph)
            var options = Tensorflow_RunOptions()
            options.traceLevel = .fullTrace
            
            let inputNames = task.inputs.enumerated().map { MetaGraph.inputKey.replacingOccurrences(of: MetaGraph.numberKey, with: "\($0.offset)")}
            let inputs = try task.inputs.map  { try Tensor(proto: $0) }
            
            
            let result: (outputs: [Tensor], runMetadata: Tensorflow_RunMetadata?) = try session.run(runOptions: options,
                                                                                                inputNames: inputNames,
                                                                                                inputs: inputs,
                                                                                                outputNames: ["tfc_output_0_main.tf"],
                                                                                                targetOperationsNames: [])
            print(result.runMetadata!)
        } catch {
            print(error)
        }
    }
    
    func buildSession(for graph: Graph) throws -> Session {
        let options = try SessionOptions()
        let session = try Session(graph: graph, sessionOptions: options)
        return session
    }
}

extension GraphExecutor: GraphExecutorInput {
    func launchTimeProfiler(for scope: Scope, entryFunctionBaseName: String, tensorArgument: [Tensorflow_TensorProto], callback: @escaping ResultCompletion<Tensorflow_RunMetadata>) -> GraphExecutorTask.TaskIdentifier {
        
        let task = GraphExecutorTask(scope: scope, inputs: tensorArgument, entryFunctionBaseName: entryFunctionBaseName)
        tasks.append(task)
        queue.async {
            self.launchTimeProfiler(for: task, callback: callback)
        }
        return task.identifier
    }
}
