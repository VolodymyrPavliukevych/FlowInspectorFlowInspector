//
//  GraphViewModel.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 7/8/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import TensorFlowKit
import CTensorFlow
import Proto

struct EdgeValueViewModel: Encodable {
    let label: String
    let viewModelType: EdgeTypeViewModel
}

enum EdgeTypeViewModel: String, Encodable {
    case input
    case controlDependencies
}

struct EdgeViewModel: Encodable {
    let v: String
    let w: String
    let value: EdgeValueViewModel
}


enum NodeTypeViewModel: String, Encodable {
    case operation
    case libraryFunction
    case arg
}

struct NodeValueViewModel: Encodable {
    let label: String
    let width: Int
    let height: Int
    let viewModelType: NodeTypeViewModel
    init(label: String, type: NodeTypeViewModel) {
        self.label = label
        height = 30
        width = ((label.count * 15) > 120) ? 120 : label.count * 15
        self.viewModelType = type
    }
}

struct NodeViewModel: Encodable {
    let v: String
    let value: NodeValueViewModel
}

protocol NodeRepresentatible {
    var name: String { get }
    var input: [String] { get }
}

extension Tensorflow_NodeDef: NodeRepresentatible {}
extension Tensorflow_OpDef.ArgDef: NodeRepresentatible {
    var input: [String] {
        return [String]()
    }
}


struct GraphViewModel: Encodable {
    
    var nodes = [NodeViewModel]()
    var edges = [EdgeViewModel]()
    var options = [String : Bool]()
    init(from graphDef: Tensorflow_GraphDef) {
        options = ["directed" : true,
                   "multigraph": false,
                   "compound": false]


        func enumirate(_ nodeList: [NodeRepresentatible], type: NodeTypeViewModel) {
            for graphNode in nodeList {
                let node = NodeViewModel(v: graphNode.name, value: NodeValueViewModel(label: graphNode.name, type: type))
                nodes.append(node)
                
                for input in graphNode.input {
                    let input = process(input, suffixes: [":handle:0", ":output:0", ":components:0", ":y:0", ":x:0", ":product:0", ":z:0"])
                    
                    var type = EdgeTypeViewModel.input
                    
                    if input.hasPrefix("^") {
                        type = .controlDependencies
                    }
                    
                    let edge = EdgeViewModel(v: graphNode.name,
                                             w: input.replacingOccurrences(of: "^", with: ""),
                                             value: EdgeValueViewModel(label: "\(graphNode.name) <- \(input)", viewModelType: type))
                    edges.append(edge)
                }
            }
        }
        
        enumirate(graphDef.node, type: .operation)
        for libraryFunction in graphDef.library.function {
            enumirate(libraryFunction.nodeDef, type: .libraryFunction)
            enumirate(libraryFunction.signature.inputArg, type: .arg)
        }
    }
    
    func process(_ input: String, suffixes: [String]) -> String {
        var output = input
        for suffix in suffixes {
            if output.hasSuffix(suffix) {
                output = output.replacingOccurrences(of: suffix, with: "")
            }
        }
        return output
    }
    
    func serialize() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
