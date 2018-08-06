//
//  Extension.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/6/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import Proto

enum MemoryLayoutError: Error {
    case valueSizeIsNotEqualToAvailableByteCount
    case canNotFitCollection
}

extension Data {
    public func unsafeCast<T>() throws -> T {
        let size = MemoryLayout<T>.size
        guard self.count == size else {
            throw MemoryLayoutError.valueSizeIsNotEqualToAvailableByteCount
        }
        return self.withUnsafeBytes { (pointer: UnsafePointer<T>) -> T in
            return pointer.pointee
        }
    }
    
    public func unsafeCollectionCast<U>() throws -> [U] {
        let elementCount = Float(self.count) / Float(MemoryLayout<U>.size)
        let fraction = modf(elementCount)
        
        guard fraction.1 == 0 else {
            throw MemoryLayoutError.canNotFitCollection
        }
        
        return self.withUnsafeBytes { (pointer: UnsafePointer<U>) -> [U] in
            return Array(UnsafeBufferPointer<U>(start: pointer, count: Int(fraction.0)))
        }
    }    
    
}

extension Tensorflow_DataType {
    var native: Any.Type {
        
        switch self {
        case .dtFloat:
            return Float.self
            
        case .dtInt8:
            return Int8.self
            
        case .dtInt16:
            return Int16.self
            
        case .dtInt32:
            return Int32.self
        
        case .dtInt64:
            return Int64.self
        
        case .dtUint8:
            return UInt8.self
            
        case .dtUint16:
            return UInt16.self
            
        case .dtUint32:
            return UInt32.self
            
        case .dtUint64:
            return UInt64.self
            
        case .dtString:
            return String.self
        
        default:
            return Data.self
        }
    }
}
