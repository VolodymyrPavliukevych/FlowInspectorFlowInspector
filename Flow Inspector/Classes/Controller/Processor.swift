//
//  Processor.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 7/2/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation
import LLDBKit
import Proto
import TensorFlowKit

typealias DiscoverCallback = (_ lldb: LLDBDebugger, _ process: LLDBProcess, _ target: LLDBTarget) -> Bool
typealias CreateBreakpointCallback = (_ target: LLDBTarget) -> [LLDBBreakpoint]

enum ProcessorError: Error {
    case canNotLoadDebugger
    case canNotCreateTarget
    case canNotLaunchProcess
    case canNotCreateListener
    case canNotCreateBreakpoint
    case graphDataNotFound
    case waitingBreakpointTimeout
    case canNotComputeProgramName
    case canNotReadArgument
    case argumentNotFound
    case canNotComputRegisterValue
    case isInProgress
    case canNotReadInputTensor
    
}
protocol ProcessorInput {
    func extractGraph(at functionName: String, preferences: Preferences, callback: @escaping ResultCompletion<Data>)
    func extractMainGraph(preferences: Preferences, callback: @escaping ResultCompletion<MetaGraph>)
}

protocol ProcessorOutput {
    func binFileURL() throws -> URL
    func dsymFileURL() throws -> URL
    func sourceFileURL() throws -> URL
    func outputStreamReceived(_ string: String)
    func errorStreamReceived(_ string: String)
}

struct MetaGraph {
    let program: Data
    let entryFunctionBaseName: String
    let tensorArgument: [Tensorflow_TensorProto]
}

enum Argument {
    case intValue(value: Int)
    case uint64Value(value: UInt64)
    case dataValue(value: Data)
    case stringValue(value: String)
}

class Processor {
    enum State: Equatable {
        enum State {
            case looking
            case found
            case finished
        }
        
        case idle
        case lookingForFunctionGraph(state: Processor.State.State)
        case lookingForMainGraph(state: Processor.State.State)
    }
    
    static let triggerFunctionName = "_swift_tfc_StartTensorComputation"
    static let mainFunctionName = "main"
    
    var output: ProcessorOutput
    var graphProcessingCallback: ResultCompletion<Data>?
    var state = State.idle
    
    init(output: ProcessorOutput) {
        self.output = output
        LLDBGlobals.initialize()
    }
    
    deinit {
        LLDBGlobals.terminate()
    }
}

/*
 public func _TFCStartTensorComputation(
 %rdi _ programByteAddress: UnsafeRawPointer,
 %rsi _ programByteCount: Int,
 %rdx _ entryFunctionBaseNameAddress: UnsafePointer<Int8>,
 %rcx _ tensorArgumentAddress: UnsafePointer<CTensorHandle>,
 %r8 _ tensorArgumentCount: Int,
 %r9 _ helperFunctionCount: Int,
 ?? 16(%rbp) _ resultCount: Int
 ) -> _TensorComputation { */

extension Processor: ProcessorInput {
    //MARK: Helpers
    func lookingForStartAddress(at target: LLDBTarget, program name: String) -> UInt64 {
        let filteredModules = target.modules.filter { $0.fileSpec()?.filename == name }
        for module in filteredModules {
            var callAddress: UInt64 = 0
            var symbols = module.symbols.filter { $0.name == Processor.triggerFunctionName }
            for symbol in symbols {
                callAddress = symbol.startAddress.fileAddress
                break
            }

            guard callAddress != 0 else { continue }
            symbols = module.symbols.filter { $0.name == Processor.mainFunctionName }
            for symbol in symbols {
                let fileAddress = symbol.startAddress.fileAddress
                guard let instructions = symbol.instructions(for: target) else { continue }
                
                for instruction in instructions.allInstructions {
                    guard let operands = instruction.operands(for: target) else { continue }
                    guard let address = instruction.getAddress() else { continue }
                    let offset = address.offset
                    let shouldBeAddress = operands.replacingOccurrences(of: "0x", with: "")
                    guard let funcAddress = Int(shouldBeAddress, radix:16) else { continue }
                    if funcAddress == callAddress {
                        let breakpointAddress = fileAddress + offset
                        return breakpointAddress
                    }
                }
            }
        }
        return 0
    }
    
    func evaluateObjCExpression(_ expression: String, at frame: LLDBFrame) throws -> LLDBValue {
        guard let resolve = frame.evaluateExpression(expression, on: .objC) else { throw ProcessorError.canNotReadInputTensor }
        guard resolve.error.code == 0 else { throw ProcessorError.canNotReadInputTensor }
        return resolve
    }
    
    func extractTensors(tensorArgumentAddress: UInt64, tensorArgumentCount: UInt64, at process: LLDBProcess) throws {
        guard tensorArgumentCount > 0 else { return }
        guard let thread = process.threads.first else  { return }
        guard let frame = thread.frames.first else  { return }

        let status = try evaluateObjCExpression("(id)TF_NewStatus()", at: frame)
        
        let pointers = try evaluateObjCExpression("(const void *)\(tensorArgumentAddress)]", at: frame)
        let tensorPointer = try evaluateObjCExpression("((long *) \(pointers.name!))[0]", at: frame)
        let pointerAddress = try readPointerValue(in: tensorPointer)
        
        let tensorAddressValue = try evaluateObjCExpression("(id)TFE_TensorHandleResolve((id)\(pointerAddress),\(status.name!))", at: frame)
        let tensorByteSize = try evaluateObjCExpression("(int)TF_TensorByteSize((id)\(tensorAddressValue.name!), \(status.name!))", at: frame)
        
        let typeValue = try evaluateObjCExpression("(id)TF_TensorType((id)\(tensorAddressValue.name!))", at: frame)
        let rawType: Int = try typeValue.data.readRawData().unsafeCast()
        guard let type = Tensorflow_DataType(rawValue: rawType) else { throw ProcessorError.canNotReadArgument }
        
        //Reading data
        let byteSize = try readPointerValue(in: tensorByteSize)
        let tensorData = try evaluateObjCExpression("(id)TF_TensorData((id)\(tensorAddressValue.name!))", at: frame)
        
        var shape = [Int64]()
        let numDims = try evaluateObjCExpression("(int)TF_NumDims((id)\(tensorAddressValue.name!))", at: frame)
        let dimCount: Int32 = try numDims.data.readRawData().unsafeCast()
        for dimIndex in 0..<dimCount {
            let dim = try evaluateObjCExpression("(int)TF_Dim((id)\(tensorAddressValue.name!), \(dimIndex))", at: frame)
            let dimention: Int32 = try dim.data.readRawData().unsafeCast()
            shape.append(Int64(dimention))
        }

        let dataAddress = try readPointerValue(in: tensorData)
        
        let data = try process.readMemory(dataAddress..<dataAddress+byteSize)
        
        var tensor = Tensorflow_TensorProto()
        tensor.dtype = type
        tensor.tensorContent = data
        var tensorShape = Tensorflow_TensorShapeProto()
        tensorShape.dim = shape.map({ (value) -> Tensorflow_TensorShapeProto.Dim in
            var dim = Tensorflow_TensorShapeProto.Dim()
            dim.size = value
            return dim
        })
        tensor.tensorShape = tensorShape
    }
    
    func readArguments(_ registers: [LLDBValue], process: LLDBProcess) throws -> MetaGraph {
        
        let rdiPointerValue = try lookingForFirstPointerValue("rdi", at: registers)
        let rsiPointerValue = try lookingForFirstPointerValue("rsi", at: registers)
        let rdxPointerValue = try lookingForFirstPointerValue("rdx", at: registers)
        let rcxPointerValue = try lookingForFirstPointerValue("rcx", at: registers) //tensorArgumentAddress
        let r8PointerValue = try lookingForFirstPointerValue("r8", at: registers) //tensorArgumentCount

        try extractTensors(tensorArgumentAddress: rcxPointerValue,
                           tensorArgumentCount: r8PointerValue,
                           at: process)

        let graphData = try process.readMemory(rdiPointerValue..<rdiPointerValue + rsiPointerValue)
        
        let entryFunctionBaseName: String = try process.readString(rdxPointerValue)

        return MetaGraph(program: graphData, entryFunctionBaseName: entryFunctionBaseName, tensorArgument: [])
    }
    
    func extractMainGraph(preferences: Preferences, callback: @escaping ResultCompletion<MetaGraph>) {
        guard state == .idle else {
            callback(.negative(error: ProcessorError.isInProgress))
            return
        }
        state = .lookingForMainGraph(state: .looking)

        guard let program = try? self.output.binFileURL().lastPathComponent else {
            callback(.negative(error: ProcessorError.canNotComputeProgramName))
            return
        }

        // Create Breakpoint
        let createBreakpoint: CreateBreakpointCallback = { (target: LLDBTarget) in
            
            let modules = target.modules.filter { $0.fileSpec()?.filename == program }
            let startAddress = self.lookingForStartAddress(at: target, program: program)
            
            guard let module = modules.first else {
                callback(.negative(error: ProcessorError.canNotCreateBreakpoint))
                return []
            }
            
            guard let sbAddress = module.resolve(forAddress: startAddress) else {
                callback(.negative(error: ProcessorError.canNotCreateBreakpoint))
                return []
            }
            
            guard let mainAddressBreakpoint = target.createBreakpoint(by: sbAddress) else {
                callback(.negative(error: ProcessorError.canNotCreateBreakpoint))
                return []
            }
            
            mainAddressBreakpoint.isEnabled = true

            return [mainAddressBreakpoint]
        }
        
        // Discover process
        let discoverCallback: DiscoverCallback = { (lldb: LLDBDebugger, process: LLDBProcess, target: LLDBTarget) in
            
            guard let thread = process.threads.first else { callback(.negative(error: ProcessorError.graphDataNotFound)); return false }
            guard let frame = thread.frames.first else { callback(.negative(error: ProcessorError.graphDataNotFound)); return false }
            
            let registersValues = frame.registers.availableValues.flatMap { $0.allAvailableChildren }

            do {
                let metaGraph = try self.readArguments(registersValues, process: process)
                self.state = .lookingForMainGraph(state: .found)
                callback(.positive(value: metaGraph))
            } catch {
                callback(error.toResult())
            }
            
            return true
        }
        
        // Finish
        let finishCallback = { (error: Error?) in
            defer {
                self.state = .idle
            }
            if let error = error {
                callback(.negative(error: error))
            } else {
                guard self.state == .lookingForMainGraph(state: .found) else {
                    callback(.negative(error: ProcessorError.graphDataNotFound))
                    return
                }
            }
        }
        
        launchDebug(preferences: preferences, createBreakpoint: createBreakpoint, discoverCallback: discoverCallback, finish: finishCallback)
    }
    
    func extractGraph(at functionName: String, preferences: Preferences, callback: @escaping ResultCompletion<Data>) {
        guard state == .idle else {
            callback(.negative(error: ProcessorError.isInProgress))
            return
        }
        state = .lookingForFunctionGraph(state: .looking)
        graphProcessingCallback = callback
        guard let program = try? self.output.binFileURL().lastPathComponent else {
            callback(.negative(error: ProcessorError.canNotComputeProgramName))
            return
        }
        
        // Create Breakpoint
        let createBreakpoint: CreateBreakpointCallback = { (target: LLDBTarget) in
            guard let functionBreakpoint = target.createBreakpoint(byName: functionName) else { fatalError("Can't add breakpoint.") }
            functionBreakpoint.isEnabled = true
            
            let hotFixBreakpoint = target.createBreakpointByLocationWithFilePath("main.swift", lineNumber: 4)
            return [functionBreakpoint, hotFixBreakpoint]
        }
        
        // Discover process
        let discoverCallback: DiscoverCallback = { (lldb: LLDBDebugger, process: LLDBProcess, target: LLDBTarget) in
            guard let thread = process.threads.first else  { return false }
            guard let frame = thread.frames.first else  { return false }
            
            let localCallback = { (result: Result<Data>) in
                result.onPositive {
                    self.state = .lookingForFunctionGraph(state: .found)
                    callback(.positive(value: $0))
                }
                result.onNegative {
                    callback(.negative(error: $0))
                }
            }
            self.lookingForFunctionGraph(at: lldb,
                                         process: process,
                                         target: target,
                                         program: program,
                                         functionName: functionName,
                                         callback: localCallback)
            return true
        }
        
        // Finish
        let finishCallback = { (error: Error?) in
            defer {
                self.state = .idle
            }
            if let error = error {
                callback(.negative(error: error))
            } else {
                guard self.state == .lookingForFunctionGraph(state: .found) else {
                    callback(.negative(error: ProcessorError.graphDataNotFound))
                    return
                }
            }
        }
        
        launchDebug(preferences: preferences, createBreakpoint: createBreakpoint, discoverCallback: discoverCallback, finish: finishCallback)
    }
    
    func lookingForFunctionGraph(at lldb: LLDBDebugger, process: LLDBProcess, target: LLDBTarget, program: String, functionName: String, callback: @escaping ResultCompletion<Data>) {
        let modules = target.modules.filter { $0.fileSpec().filename == program}
        for module in modules {
            let codeSymbols = module.symbols.filter { $0.type == .code && $0.name.contains(program + "." + functionName) }
            for symbol in codeSymbols {
                guard let instructions = symbol.instructions(for: target) else { continue }
                let allInstructions = instructions.allInstructions
                var stepAddress: LLDBAddressType = 0
                var targetFunctionFound: Bool = false
                var rdiValue: Int = 0
                var rsiValue: Int = 0
                
                for instruction in allInstructions.reversed() {
                    
                    guard targetFunctionFound else {
                        if let comment = instruction.comment(for: target), comment.contains(Processor.triggerFunctionName) {
                            targetFunctionFound = true
                        }
                        continue
                    }
                    
                    guard let mnemonic = instruction.mnemonic(for: target) else { continue }
                    guard let operands = instruction.operands(for: target) else { continue }
                    guard let address = instruction.getAddress() else { continue }
                    
                    let loadedAdress = address.load(with: target)
                    
                    if operands.contains("%rdi") && mnemonic == "leaq" {
                        if let pointer = operands.split(separator: ",").first {
                            let hex = pointer.replacingOccurrences(of: "(%rip)", with: "").replacingOccurrences(of: "0x", with: "")
                            rdiValue = Int(hex, radix: 16) ?? 0
                        }
                    }
                    
                    if operands.contains("%esi") && mnemonic == "movl" {
                        if let pointer = operands.split(separator: ",").first {
                            let hex = pointer.replacingOccurrences(of: "$0x", with: "")
                            rsiValue = Int(hex, radix: 16) ?? 0
                        }
                    }
                    
                    if rdiValue == 0 {
                        stepAddress = loadedAdress
                    }
                    
                    guard rdiValue != 0, rsiValue != 0 else { continue }
                    
                    let startAddress = UInt64(stepAddress) + UInt64(rdiValue)
                    let endAddress = startAddress + UInt64(rsiValue)
                    do {
                        let result = try process.readMemory(startAddress..<endAddress)
                        callback(.positive(value: result))
                    } catch {
                        callback(.negative(error: error))
                    }
                    
                    return
                }
            }
        }
        callback(.negative(error: ProcessorError.graphDataNotFound))
    }
    
    
    func launchDebug(preferences: Preferences, createBreakpoint: CreateBreakpointCallback, discoverCallback: @escaping DiscoverCallback, finish: (_ error: Error?) -> Void)  {
        do {
            let binURL = try output.binFileURL()
            
            guard let lldb = LLDBDebugger() else {
                finish(ProcessorError.canNotLoadDebugger)
                return
            }
            
            let target = try lldb.createTarget(at: binURL.path)
            
            let _ = createBreakpoint(target)
            
            let dirPath = binURL.deletingLastPathComponent()
            guard let process = try target.launchProcess(workingDirectory: dirPath.path,
                                                         arguments: preferences.argument,
                                                         environment: preferences.environment) else {
                                                            finish(ProcessorError.canNotLaunchProcess)
                                                            return
            }
            guard let listener = lldb.listener else {
                finish(ProcessorError.canNotCreateListener)
                return
            }
            
            var isWorking = true
            while isWorking {
                guard let event = listener.waitForEvent(Int(UInt32.max)) else {
                    finish(ProcessorError.waitingBreakpointTimeout)
                    return
                }
                
                if event.type == .stateChanged {
                    if process.state == .exited {
                        isWorking = false
                        continue
                    }
                    
                    if process.state == .running {
                        continue
                    }
                    
                    if process.state == .stopped {
                        if discoverCallback(lldb, process, target) {
                            if let error = process.continue(), error.code != 0 {
                                finish(error)
                                return
                            }
                        }
                        continue
                    }
                    print("Not used event: ", event.description(), event.type, " Process state: ", process.state)
                }
                
                if event.type == .stdOutputAvailable {
                    guard let output = process.readOutput() else { continue }
                    self.output.outputStreamReceived(output)
                    continue
                }
                
                if event.type == .stdErrorAvailable {
                    guard let output = process.readError() else { continue }
                    self.output.errorStreamReceived(output)
                    continue
                }
                print("Unknown event: ", event.description(), event.type)
            }
            finish(nil)
        } catch {
            finish(error)
        }
    }
}


//MARK: - Helper
extension Processor {
    func readPointerValue(in value: LLDBValue) throws -> UInt64 {
        let data = try value.data.readRawData()
        let argValue = data.withUnsafeBytes { (pointer: UnsafePointer<UInt64>) -> UInt64 in
            return UInt64(littleEndian: pointer.pointee)
        }
        return argValue
    }
    
    func lookingForFirstPointerValue(_ name: String, at registers: [LLDBValue]) throws -> UInt64 {
        let filtered = registers.filter { (value) -> Bool in
            return value.name == name
        }
        guard let value = filtered.first else { throw ProcessorError.argumentNotFound }
        return try readPointerValue(in: value)
    }
}
