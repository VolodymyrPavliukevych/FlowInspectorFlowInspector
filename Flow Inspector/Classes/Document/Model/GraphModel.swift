//
//  GraphModel.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import Proto

struct GraphModel {
    enum Kind {
        case function
        case main
    }
    var graphDef: Tensorflow_GraphDef
    var kind: Kind
    var viewModel: GraphViewModel
    var entryFunctionBaseName: String? = nil
    var tensorArgument: [Tensorflow_TensorProto]? = nil
    var runMetadata: Tensorflow_RunMetadata? = nil
    
    init(graphDef: Tensorflow_GraphDef, kind: Kind, entryFunctionBaseName: String? = nil, tensorArgument: [Tensorflow_TensorProto]? = nil, runMetadata: Tensorflow_RunMetadata? = nil) {
        self.graphDef = graphDef
        self.kind = kind
        self.entryFunctionBaseName = entryFunctionBaseName
        self.tensorArgument = tensorArgument
        self.viewModel = GraphViewModel(from: graphDef)
        self.runMetadata = runMetadata
    }
}
