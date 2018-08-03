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
                /*let offsetAddress = symbol.startAddress.offset*/
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
    
    func extractTensors(tensorArgumentAddress: UInt64, tensorArgumentCount: UInt64, at process: LLDBProcess) {
        guard tensorArgumentCount > 0 else { return }
        guard let thread = process.threads.first else  { return }
        guard let frame = thread.frames.first else  { return }

        guard let status = frame.evaluateExpression("(id)TF_NewStatus()", on: .objC) else { fatalError() }
        guard status.error.code == 0 else { return }
        print(status.description())
        
        guard let pointers = frame.evaluateExpression("(const void *)\(tensorArgumentAddress)]", on: .objC) else { fatalError() }
        guard pointers.error.code == 0 else { return }
        print(pointers.description())
        
        
        guard let tensorPointer = frame.evaluateExpression("((long *) \(pointers.name!))[0]", on: .objC) else { fatalError() }
        print(tensorPointer.error)
        print(tensorPointer.description())
        let pointerAddress = try! readPointerValue(in: tensorPointer)
        print("address: \(pointerAddress)")
        
        //TF_Dim
        //TF_NumDims
        /*
         guard let dataType = frame.evaluateObjCExpression("(int)TF_NumDims((id)\(pointerAddress))") else { fatalError() }
         print(dataType.error)
         print(dataType.description())
         */
        guard let resolve = frame.evaluateExpression("(id)TFE_TensorHandleResolve((id)\(pointerAddress),\(status.name!))",
            on: .objC) else { fatalError() }
        print(resolve.error)
        print(resolve.description())
        
        guard let tensorByteSize = frame.evaluateExpression("(int)TF_TensorByteSize((id)\(resolve.name!), \(status.name!))",
            on: .objC) else { fatalError() }
        print(tensorByteSize.error)
        print(tensorByteSize.description())
        //Reading data
        let byteSize = try! readPointerValue(in: tensorByteSize)
        
        guard let tensorData = frame.evaluateExpression("(id)TF_TensorData((id)\(resolve.name!))",
            on: .objC) else { fatalError() }
        print(tensorData.error)
        print(tensorData.description())
        
        let dataAddress = try! readPointerValue(in: tensorData)
        
        let data = process.readMemory(dataAddress..<dataAddress+byteSize)
        if let error = data.error, error.code != 0 {
            print(error)
            return
        }
        
        let collection = data.data.withUnsafeBytes { (pointer: UnsafePointer<Float>) -> [Float] in
            return Array(UnsafeBufferPointer<Float>(start: pointer, count: data.data.count / MemoryLayout<Float>.size))
        }
        
        self.output.outputStreamReceived("Input tensor[0] value: \(collection)\n\n")
        
//        var tensor = Tensorflow_TensorProto()
//        var tensorShape = Tensorflow_TensorShapeProto()
//        var dim = Tensorflow_TensorShapeProto.Dim()
//        dim.size = 0
//        tensorShape.dim = [dim]
//
//        tensor.dtype = Tensorflow_DataType.dtFloat
        
    }
    
    func readArguments(_ registers: [LLDBValue], process: LLDBProcess) throws -> MetaGraph {
        
        let rdiPointerValue = try lookingForFirstPointerValue("rdi", at: registers)
        let rsiPointerValue = try lookingForFirstPointerValue("rsi", at: registers)
        let rdxPointerValue = try lookingForFirstPointerValue("rdx", at: registers)
        let rcxPointerValue = try lookingForFirstPointerValue("rcx", at: registers) //tensorArgumentAddress
        let r8PointerValue = try lookingForFirstPointerValue("r8", at: registers) //tensorArgumentCount

        extractTensors(tensorArgumentAddress: rcxPointerValue,
                       tensorArgumentCount: r8PointerValue,
                       at: process)

        let graphData: Data = try readValue(by: rdiPointerValue, size: Int(rsiPointerValue), in: process)
        // Read first 128 byte, C string has terminator \0 so it will find finish.
        let entryFunctionBaseName: String = try readValue(by: rdxPointerValue, size: 128, in: process)

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
                    let result = process.readMemory(startAddress..<endAddress)
                    if let error = result.error, error.code != 0 {
                        callback(.negative(error: error))
                    }
                    callback(.positive(value: result.data))
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
    func readValue<T: Any>(by address: UInt64, size: Int, in process: LLDBProcess) throws -> T {
        let result = process.readMemory(address..<address + UInt64(size))
        if let error = result.error, error.code != 0 {
            throw error
        }
        
        switch T.self {
        case is String.Type:
            
            let string = result.data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> String in
                return String(cString: pointer)
            }
            if let string = string as? T {
                return string
            }
            break
            
        case is Data.Type:
            if let data = result.data as? T {
                return data
            }
            break
        default:
            break
        }
        throw ProcessorError.canNotReadArgument
    }
    
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
