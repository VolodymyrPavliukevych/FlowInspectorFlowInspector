//
//  GraphMarker.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation

struct GraphMarker: Codable {
    let filePath: String
    let lineNumber: Int
    var enabled: Bool
    let functionName: String
    let uuid: String = UUID().uuidString
}
