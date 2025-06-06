/*
 Copyright 2018 The Octadero Authors. All Rights Reserved.
 Created by Volodymyr Pavliukevych on 2017.
 Licensed under the GPL License, Version 3.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.gnu.org/licenses/gpl-3.0.txt
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#pragma once
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LLDBStateType) {
    LLDBStateTypeInvalid = 0,
    /*!
    Process is object is valid, but not currently loaded
    */
    LLDBStateTypeUnloaded = 1,
    /*!
    Process is connected to remote debug services, but not launched or attached to anything yet
    */
    LLDBStateTypeConnected = 2,
    /*!
    Process is currently trying to attach
    */
    LLDBStateTypeAttaching = 3,
    /*!
    Process is in the process of launching
    */
    LLDBStateTypeLaunching = 4,
    /*!
    Process or thread is stopped and can be examined.
    */
    LLDBStateTypeStopped = 5,
    /*!
    Process or thread is running and can't be examined.
    */
    LLDBStateTypeRunning = 6,
    /*!
    Process or thread is in the process of stepping and can not be examined.
    */
    LLDBStateTypeStepping = 7,
    /*!
    Process or thread has crashed and can be examined.
    */
    LLDBStateTypeCrashed = 8,
    /*!
    Process has been detached and can't be examined.
    */
    LLDBStateTypeDetached = 9,
    /*!
    Process has exited and can't be examined.
    */
    LLDBStateTypeExited = 10,
    /*!
    Process or thread is in a suspended state as far as the debugger is concerned while other processes or threads get the chance to run.
    */
    LLDBStateTypeSuspended = 11,
};

typedef NS_OPTIONS(NSUInteger,LLDBLaunchFlags) {
    LLDBLaunchFlagsLaunchFlagNone = 0,
    /*!
    Exec when launching and turn the calling process into a new process
    */
    LLDBLaunchFlagsLaunchFlagExec = 1,
    /*!
    Stop as soon as the process launches to allow the process to be debugged
    */
    LLDBLaunchFlagsLaunchFlagDebug = 2,
    /*!
    Stop at the program entry point instead of auto-continuing when launching or attaching at entry point
    */
    LLDBLaunchFlagsLaunchFlagStopAtEntry = 4,
    /*!
    Disable Address Space Layout Randomization
    */
    LLDBLaunchFlagsLaunchFlagDisableASLR = 8,
    /*!
    Disable stdio for inferior process (e.g. for a GUI app)
    */
    LLDBLaunchFlagsLaunchFlagDisableSTDIO = 16,
    /*!
    Launch the process in a new TTY if supported by the host
    */
    LLDBLaunchFlagsLaunchFlagLaunchInTTY = 32,
    /*!
    Launch the process inside a shell to get shell expansion
    */
    LLDBLaunchFlagsLaunchFlagLaunchInShell = 64,
    /*!
    Launch the process in a separate process group
    */
    LLDBLaunchFlagsLaunchFlagLaunchInSeparateProcessGroup = 128,
    /*!
    If you are going to hand the process off (e.g. to debugserver) set this flag so lldb & the handee don't race to set its exit status.
    */
    LLDBLaunchFlagsLaunchFlagDontSetExitStatus = 256,
    /*!
    If set, then the client stub should detach rather than killing the debugee if it loses connection with lldb.
    */
    LLDBLaunchFlagsLaunchFlagDetachOnError = 512,
};

typedef NS_ENUM(NSUInteger,LLDBRunMode) {
    LLDBRunModeOnlyThisThread = 0,
    LLDBRunModeAllThreads = 1,
    LLDBRunModeOnlyDuringStepping = 2,
};

typedef NS_ENUM(NSUInteger,LLDBByteOrder) {
    LLDBByteOrderInvalid = 0,
    LLDBByteOrderBig = 1,
    LLDBByteOrderPDP = 2,
    LLDBByteOrderLittle = 4,
};

typedef NS_ENUM(NSUInteger,LLDBEncoding) {
    LLDBEncodingInvalid = 0,
    LLDBEncodingUint = 1,
    LLDBEncodingSint = 2,
    LLDBEncodingIEEE754 = 3,
    LLDBEncodingVector = 4,
};

typedef NS_ENUM(NSUInteger,LLDBFormat) {
    LLDBFormatDefault = 0,
    LLDBFormatInvalid = 0,
    LLDBFormatBoolean = 1,
    LLDBFormatBinary = 2,
    LLDBFormatBytes = 3,
    LLDBFormatBytesWithASCII = 4,
    LLDBFormatChar = 5,
    LLDBFormatCharPrintable = 6,
    LLDBFormatComplex = 7,
    LLDBFormatComplexFloat = 7,
    LLDBFormatCString = 8,
    LLDBFormatDecimal = 9,
    LLDBFormatEnum = 10,
    LLDBFormatHex = 11,
    LLDBFormatHexUppercase = 12,
    LLDBFormatFloat = 13,
    LLDBFormatOctal = 14,
    LLDBFormatOSType = 15,
    LLDBFormatUnicode16 = 16,
    LLDBFormatUnicode32 = 17,
    LLDBFormatUnsigned = 18,
    LLDBFormatPointer = 19,
    LLDBFormatVectorOfChar = 20,
    LLDBFormatVectorOfSInt8 = 21,
    LLDBFormatVectorOfUInt8 = 22,
    LLDBFormatVectorOfSInt16 = 23,
    LLDBFormatVectorOfUInt16 = 24,
    LLDBFormatVectorOfSInt32 = 25,
    LLDBFormatVectorOfUInt32 = 26,
    LLDBFormatVectorOfSInt64 = 27,
    LLDBFormatVectorOfUInt64 = 28,
    LLDBFormatVectorOfFloat32 = 29,
    LLDBFormatVectorOfFloat64 = 30,
    LLDBFormatVectorOfUInt128 = 31,
    LLDBFormatComplexInteger = 32,
    LLDBFormatCharArray = 33,
    LLDBFormatAddressInfo = 34,
    LLDBFormatHexFloat = 35,
    LLDBFormatInstruction = 36,
    LLDBFormatVoid = 37,
    LLDBFormatkNumFormats = 38,
};

typedef NS_ENUM(NSUInteger, LLDBDescriptionLevel) {
    LLDBDescriptionLevelBrief = 0,
    LLDBDescriptionLevelFull = 1,
    LLDBDescriptionLevelVerbose = 2,
    LLDBDescriptionLevelInitial = 3,
    LLDBDescriptionLevelkNumDescriptionLevels = 4,
};

typedef NS_ENUM(NSUInteger, LLDBScriptLanguage) {
    LLDBScriptLanguageNone = 0,
    LLDBScriptLanguagePython = 1,
    LLDBScriptLanguageDefault = 1,
};

typedef NS_ENUM(NSUInteger, LLDBRegisterKind) {
    LLDBRegisterKindGCC = 0,
    LLDBRegisterKindDWARF = 1,
    LLDBRegisterKindGeneric = 2,
    LLDBRegisterKindGDB = 3,
    LLDBRegisterKindLLDB = 4,
    LLDBRegisterKindkNumRegisterKinds = 5,
};

typedef NS_ENUM(NSUInteger, LLDBStopReason) {
    LLDBStopReasonInvalid = 0,
    LLDBStopReasonNone = 1,
    LLDBStopReasonTrace = 2,
    LLDBStopReasonBreakpoint = 3,
    LLDBStopReasonWatchpoint = 4,
    LLDBStopReasonSignal = 5,
    LLDBStopReasonException = 6,
    LLDBStopReasonExec = 7,
    LLDBStopReasonPlanComplete = 8,
    LLDBStopReasonThreadExiting = 9,
    LLDBStopReasonInstrumentation = 10,
};

typedef NS_ENUM(NSUInteger,LLDBReturnStatus) {
    LLDBReturnStatusInvalid = 0,
    LLDBReturnStatusSuccessFinishNoResult = 1,
    LLDBReturnStatusSuccessFinishResult = 2,
    LLDBReturnStatusSuccessContinuingNoResult = 3,
    LLDBReturnStatusSuccessContinuingResult = 4,
    LLDBReturnStatusStarted = 5,
    LLDBReturnStatusFailed = 6,
    LLDBReturnStatusQuit = 7,
};

typedef NS_ENUM(NSUInteger,LLDBExpressionResults) {
    LLDBExpressionResultsExpressionCompleted = 0,
    LLDBExpressionResultsExpressionSetupError = 1,
    LLDBExpressionResultsExpressionParseError = 2,
    LLDBExpressionResultsExpressionDiscarded = 3,
    LLDBExpressionResultsExpressionInterrupted = 4,
    LLDBExpressionResultsExpressionHitBreakpoint = 5,
    LLDBExpressionResultsExpressionTimedOut = 6,
    LLDBExpressionResultsExpressionResultUnavailable = 7,
    LLDBExpressionResultsExpressionStoppedForDebug = 8,
};

typedef NS_ENUM(NSUInteger,LLDBConnectionStatus) {
    LLDBConnectionStatusSuccess = 0,
    LLDBConnectionStatusEndOfFile = 1,
    LLDBConnectionStatusError = 2,
    LLDBConnectionStatusTimedOut = 3,
    LLDBConnectionStatusNoConnection = 4,
    LLDBConnectionStatusLostConnection = 5,
    LLDBConnectionStatusInterrupted = 6,
};

typedef NS_ENUM(NSUInteger,LLDBErrorType) {
    LLDBErrorTypeInvalid = 0,
    /*!
    Generic errors that can be any value.
    */
    LLDBErrorTypeGeneric = 1,
    /*!
    Mach kernel error codes.
    */
    LLDBErrorTypeMachKernel = 2,
    /*!
    POSIX error codes.
    */
    LLDBErrorTypePOSIX = 3,
    /*!
    These are from the ExpressionResults enum.
    */
    LLDBErrorTypeExpression = 4,
    /*!
    Standard Win32 error codes.
    */
    LLDBErrorTypeWin32 = 5,
};

typedef NS_ENUM(NSUInteger,LLDBValueType) {
    LLDBValueTypeInvalid = 0,
    LLDBValueTypeVariableGlobal = 1,
    LLDBValueTypeVariableStatic = 2,
    LLDBValueTypeVariableArgument = 3,
    LLDBValueTypeVariableLocal = 4,
    LLDBValueTypeRegister = 5,
    LLDBValueTypeRegisterSet = 6,
    LLDBValueTypeConstResult = 7,
};

typedef NS_ENUM(NSUInteger,LLDBInputReaderGranularity) {
    LLDBInputReaderGranularityInvalid = 0,
    LLDBInputReaderGranularityByte = 1,
    LLDBInputReaderGranularityWord = 2,
    LLDBInputReaderGranularityLine = 3,
    LLDBInputReaderGranularityAll = 4,
};

/*!
These mask bits allow a common interface for queries that can limit the amount of information that gets parsed to only the information that is requested. These bits also can indicate what actually did get resolved during query function calls.
*/
typedef NS_OPTIONS(NSUInteger,LLDBSymbolContextItem) {
    /*!
    Set when target is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextTarget = 1,
    /*!
    Set when module is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextModule = 2,
    /*!
    Set when comp_unit is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextCompUnit = 4,
    /*!
    Set when function is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextFunction = 8,
    /*!
    Set when the deepest block is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextBlock = 16,
    /*!
    Set when line_entry is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextLineEntry = 32,
    /*!
    Set when symbol is requested from a query, or was located in query results
    */
    LLDBSymbolContextItemSymbolContextSymbol = 64,
    /*!
    Indicates to try and lookup everything up during a routine symbol context query.
    */
    LLDBSymbolContextItemSymbolContextEverything = 127,
    /*!
    Set when global or static variable is requested from a query, or was located in query results. eSymbolContextVariable is potentially expensive to lookup so it isn't included in eSymbolContextEverything which stops it from being used during frame PC lookups and many other potential address to symbol context lookups.
    */
    LLDBSymbolContextItemSymbolContextVariable = 128,
};

typedef NS_OPTIONS(NSUInteger,LLDBPermissions) {
    LLDBPermissionsWritable = 1,
    LLDBPermissionsReadable = 2,
    LLDBPermissionsExecutable = 4,
};

typedef NS_ENUM(NSUInteger,LLDBInputReaderAction) {
    LLDBInputReaderActionInputReaderActivate = 0,
    LLDBInputReaderActionInputReaderAsynchronousOutputWritten = 1,
    LLDBInputReaderActionInputReaderReactivate = 2,
    LLDBInputReaderActionInputReaderDeactivate = 3,
    LLDBInputReaderActionInputReaderGotToken = 4,
    LLDBInputReaderActionInputReaderInterrupt = 5,
    LLDBInputReaderActionInputReaderEndOfFile = 6,
    LLDBInputReaderActionInputReaderDone = 7,
};

typedef NS_OPTIONS(NSUInteger,LLDBBreakpointEventType) {
    LLDBBreakpointEventTypeInvalidType = 1,
    LLDBBreakpointEventTypeAdded = 2,
    LLDBBreakpointEventTypeRemoved = 4,
    LLDBBreakpointEventTypeLocationsAdded = 8,
    LLDBBreakpointEventTypeLocationsRemoved = 16,
    LLDBBreakpointEventTypeLocationsResolved = 32,
    LLDBBreakpointEventTypeEnabled = 64,
    LLDBBreakpointEventTypeDisabled = 128,
    LLDBBreakpointEventTypeCommandChanged = 256,
    LLDBBreakpointEventTypeConditionChanged = 512,
    LLDBBreakpointEventTypeIgnoreChanged = 1024,
    LLDBBreakpointEventTypeThreadChanged = 2048,
};

typedef NS_OPTIONS(NSUInteger,LLDBWatchpointEventType) {
    LLDBWatchpointEventTypeInvalidType = 1,
    LLDBWatchpointEventTypeAdded = 2,
    LLDBWatchpointEventTypeRemoved = 4,
    LLDBWatchpointEventTypeEnabled = 64,
    LLDBWatchpointEventTypeDisabled = 128,
    LLDBWatchpointEventTypeCommandChanged = 256,
    LLDBWatchpointEventTypeConditionChanged = 512,
    LLDBWatchpointEventTypeIgnoreChanged = 1024,
    LLDBWatchpointEventTypeThreadChanged = 2048,
    LLDBWatchpointEventTypeTypeChanged = 4096,
};

/*!
Programming language type.
*/
typedef NS_ENUM(NSUInteger,LLDBLanguageType) {
    /*!
    Unknown or invalid language value.
    */
    LLDBLanguageTypeUnknown = 0,
    /*!
    ISO C:1989.
    */
    LLDBLanguageTypeC89 = 1,
    /*!
    Non-standardized C, such as K&R.
    */
    LLDBLanguageTypeC = 2,
    /*!
    ISO Ada:1983.
    */
    LLDBLanguageTypeAda83 = 3,
    /*!
    ISO C++:1998.
    */
    LLDBLanguageTypeC_plus_plus = 4,
    /*!
    ISO Cobol:1974.
    */
    LLDBLanguageTypeCobol74 = 5,
    /*!
    ISO Cobol:1985.
    */
    LLDBLanguageTypeCobol85 = 6,
    /*!
    ISO Fortran 77.
    */
    LLDBLanguageTypeFortran77 = 7,
    /*!
    ISO Fortran 90.
    */
    LLDBLanguageTypeFortran90 = 8,
    /*!
    ISO Pascal:1983.
    */
    LLDBLanguageTypePascal83 = 9,
    /*!
    ISO Modula-2:1996.
    */
    LLDBLanguageTypeModula2 = 10,
    /*!
    Java.
    */
    LLDBLanguageTypeJava = 11,
    /*!
    ISO C:1999.
    */
    LLDBLanguageTypeC99 = 12,
    /*!
    ISO Ada:1995.
    */
    LLDBLanguageTypeAda95 = 13,
    /*!
    ISO Fortran 95.
    */
    LLDBLanguageTypeFortran95 = 14,
    /*!
    ANSI PL/I:1976.
    */
    LLDBLanguageTypePLI = 15,
    /*!
    Objective-C.
    */
    LLDBLanguageTypeObjC = 16,
    /*!
    Objective-C++.
    */
    LLDBLanguageTypeObjC_plus_plus = 17,
    /*!
    Unified Parallel C.
    */
    LLDBLanguageTypeUPC = 18,
    /*!
    D.
    */
    LLDBLanguageTypeD = 19,
    /*!
    Python.
    */
    LLDBLanguageTypePython = 20,
    /*!
    OpenCL.
    */
    LLDBLanguageTypeOpenCL = 21,
    /*!
    Go.
    */
    LLDBLanguageTypeGo = 22,
    /*!
    Modula 3.
    */
    LLDBLanguageTypeModula3 = 23,
    /*!
    Haskell.
    */
    LLDBLanguageTypeHaskell = 24,
    /*!
    ISO C++:2003.
    */
    LLDBLanguageTypeC_plus_plus_03 = 25,
    /*!
    ISO C++:2011.
    */
    LLDBLanguageTypeC_plus_plus_11 = 26,
    /*!
    OCaml.
    */
    LLDBLanguageTypeOCaml = 27,
    /*!
    Rust.
    */
    LLDBLanguageTypeRust = 28,
    /*!
    ISO C:2011.
    */
    LLDBLanguageTypeC11 = 29,
    /*!
    Swift.
    */
    LLDBLanguageTypeSwift = 30,
    /*!
    Julia.
    */
    LLDBLanguageTypeJulia = 31,
    /*!
    Dylan.
    */
    LLDBLanguageTypeDylan = 32,
    LLDBLanguageTypeNumLanguageTypes = 33,
};

typedef NS_ENUM(NSUInteger,LLDBInstrumentationRuntimeType) {
    LLDBInstrumentationRuntimeTypeAddressSanitizer = 0,
    LLDBInstrumentationRuntimeTypeNumInstrumentationRuntimeTypes = 1,
};

typedef NS_ENUM(NSUInteger,LLDBDynamicValueType) {
    LLDBDynamicValueTypeNoDynamicValues = 0,
    LLDBDynamicValueTypeDynamicCanRunTarget = 1,
    LLDBDynamicValueTypeDynamicDontRunTarget = 2,
};

typedef NS_ENUM(NSUInteger,LLDBAccessType) {
    LLDBAccessTypeAccessNone = 0,
    LLDBAccessTypeAccessPublic = 1,
    LLDBAccessTypeAccessPrivate = 2,
    LLDBAccessTypeAccessProtected = 3,
    LLDBAccessTypeAccessPackage = 4,
};

typedef NS_ENUM(NSUInteger,LLDBCommandArgumentType) {
    LLDBCommandArgumentTypeArgTypeAddress = 0,
    LLDBCommandArgumentTypeArgTypeAddressOrExpression = 1,
    LLDBCommandArgumentTypeArgTypeAliasName = 2,
    LLDBCommandArgumentTypeArgTypeAliasOptions = 3,
    LLDBCommandArgumentTypeArgTypeArchitecture = 4,
    LLDBCommandArgumentTypeArgTypeBoolean = 5,
    LLDBCommandArgumentTypeArgTypeBreakpointID = 6,
    LLDBCommandArgumentTypeArgTypeBreakpointIDRange = 7,
    LLDBCommandArgumentTypeArgTypeBreakpointName = 8,
    LLDBCommandArgumentTypeArgTypeByteSize = 9,
    LLDBCommandArgumentTypeArgTypeClassName = 10,
    LLDBCommandArgumentTypeArgTypeCommandName = 11,
    LLDBCommandArgumentTypeArgTypeCount = 12,
    LLDBCommandArgumentTypeArgTypeDescriptionVerbosity = 13,
    LLDBCommandArgumentTypeArgTypeDirectoryName = 14,
    LLDBCommandArgumentTypeArgTypeDisassemblyFlavor = 15,
    LLDBCommandArgumentTypeArgTypeEndAddress = 16,
    LLDBCommandArgumentTypeArgTypeExpression = 17,
    LLDBCommandArgumentTypeArgTypeExpressionPath = 18,
    LLDBCommandArgumentTypeArgTypeExprFormat = 19,
    LLDBCommandArgumentTypeArgTypeFilename = 20,
    LLDBCommandArgumentTypeArgTypeFormat = 21,
    LLDBCommandArgumentTypeArgTypeFrameIndex = 22,
    LLDBCommandArgumentTypeArgTypeFullName = 23,
    LLDBCommandArgumentTypeArgTypeFunctionName = 24,
    LLDBCommandArgumentTypeArgTypeFunctionOrSymbol = 25,
    LLDBCommandArgumentTypeArgTypeGDBFormat = 26,
    LLDBCommandArgumentTypeArgTypeHelpText = 27,
    LLDBCommandArgumentTypeArgTypeIndex = 28,
    LLDBCommandArgumentTypeArgTypeLanguage = 29,
    LLDBCommandArgumentTypeArgTypeLineNum = 30,
    LLDBCommandArgumentTypeArgTypeLogCategory = 31,
    LLDBCommandArgumentTypeArgTypeLogChannel = 32,
    LLDBCommandArgumentTypeArgTypeMethod = 33,
    LLDBCommandArgumentTypeArgTypeName = 34,
    LLDBCommandArgumentTypeArgTypeNewPathPrefix = 35,
    LLDBCommandArgumentTypeArgTypeNumLines = 36,
    LLDBCommandArgumentTypeArgTypeNumberPerLine = 37,
    LLDBCommandArgumentTypeArgTypeOffset = 38,
    LLDBCommandArgumentTypeArgTypeOldPathPrefix = 39,
    LLDBCommandArgumentTypeArgTypeOneLiner = 40,
    LLDBCommandArgumentTypeArgTypePath = 41,
    LLDBCommandArgumentTypeArgTypePermissionsNumber = 42,
    LLDBCommandArgumentTypeArgTypePermissionsString = 43,
    LLDBCommandArgumentTypeArgTypePid = 44,
    LLDBCommandArgumentTypeArgTypePlugin = 45,
    LLDBCommandArgumentTypeArgTypeProcessName = 46,
    LLDBCommandArgumentTypeArgTypePythonClass = 47,
    LLDBCommandArgumentTypeArgTypePythonFunction = 48,
    LLDBCommandArgumentTypeArgTypePythonScript = 49,
    LLDBCommandArgumentTypeArgTypeQueueName = 50,
    LLDBCommandArgumentTypeArgTypeRegisterName = 51,
    LLDBCommandArgumentTypeArgTypeRegularExpression = 52,
    LLDBCommandArgumentTypeArgTypeRunArgs = 53,
    LLDBCommandArgumentTypeArgTypeRunMode = 54,
    LLDBCommandArgumentTypeArgTypeScriptedCommandSynchronicity = 55,
    LLDBCommandArgumentTypeArgTypeScriptLang = 56,
    LLDBCommandArgumentTypeArgTypeSearchWord = 57,
    LLDBCommandArgumentTypeArgTypeSelector = 58,
    LLDBCommandArgumentTypeArgTypeSettingIndex = 59,
    LLDBCommandArgumentTypeArgTypeSettingKey = 60,
    LLDBCommandArgumentTypeArgTypeSettingPrefix = 61,
    LLDBCommandArgumentTypeArgTypeSettingVariableName = 62,
    LLDBCommandArgumentTypeArgTypeShlibName = 63,
    LLDBCommandArgumentTypeArgTypeSourceFile = 64,
    LLDBCommandArgumentTypeArgTypeSortOrder = 65,
    LLDBCommandArgumentTypeArgTypeStartAddress = 66,
    LLDBCommandArgumentTypeArgTypeSummaryString = 67,
    LLDBCommandArgumentTypeArgTypeSymbol = 68,
    LLDBCommandArgumentTypeArgTypeThreadID = 69,
    LLDBCommandArgumentTypeArgTypeThreadIndex = 70,
    LLDBCommandArgumentTypeArgTypeThreadName = 71,
    LLDBCommandArgumentTypeArgTypeUnsignedInteger = 72,
    LLDBCommandArgumentTypeArgTypeUnixSignal = 73,
    LLDBCommandArgumentTypeArgTypeVarName = 74,
    LLDBCommandArgumentTypeArgTypeValue = 75,
    LLDBCommandArgumentTypeArgTypeWidth = 76,
    LLDBCommandArgumentTypeArgTypeNone = 77,
    LLDBCommandArgumentTypeArgTypePlatform = 78,
    LLDBCommandArgumentTypeArgTypeWatchpointID = 79,
    LLDBCommandArgumentTypeArgTypeWatchpointIDRange = 80,
    LLDBCommandArgumentTypeArgTypeWatchType = 81,
    LLDBCommandArgumentTypeArgTypeLastArg = 82,
};

typedef NS_ENUM(NSUInteger,LLDBSectionType) {
    LLDBSectionTypeInvalid = 0,
    LLDBSectionTypeCode = 1,
    LLDBSectionTypeContainer = 2,
    LLDBSectionTypeData = 3,
    LLDBSectionTypeDataCString = 4,
    LLDBSectionTypeDataCStringPointers = 5,
    LLDBSectionTypeDataSymbolAddress = 6,
    LLDBSectionTypeData4 = 7,
    LLDBSectionTypeData8 = 8,
    LLDBSectionTypeData16 = 9,
    LLDBSectionTypeDataPointers = 10,
    LLDBSectionTypeDebug = 11,
    LLDBSectionTypeZeroFill = 12,
    LLDBSectionTypeDataObjCMessageRefs = 13,
    LLDBSectionTypeDataObjCCFStrings = 14,
    LLDBSectionTypeDWARFDebugAbbrev = 15,
    LLDBSectionTypeDWARFDebugAranges = 16,
    LLDBSectionTypeDWARFDebugFrame = 17,
    LLDBSectionTypeDWARFDebugInfo = 18,
    LLDBSectionTypeDWARFDebugLine = 19,
    LLDBSectionTypeDWARFDebugLoc = 20,
    LLDBSectionTypeDWARFDebugMacInfo = 21,
    LLDBSectionTypeDWARFDebugPubNames = 22,
    LLDBSectionTypeDWARFDebugPubTypes = 23,
    LLDBSectionTypeDWARFDebugRanges = 24,
    LLDBSectionTypeDWARFDebugStr = 25,
    LLDBSectionTypeDWARFAppleNames = 26,
    LLDBSectionTypeDWARFAppleTypes = 27,
    LLDBSectionTypeDWARFAppleNamespaces = 28,
    LLDBSectionTypeDWARFAppleObjC = 29,
    LLDBSectionTypeELFSymbolTable = 30,
    LLDBSectionTypeELFDynamicSymbols = 31,
    LLDBSectionTypeELFRelocationEntries = 32,
    LLDBSectionTypeELFDynamicLinkInfo = 33,
    LLDBSectionTypeEHFrame = 34,
    LLDBSectionTypeCompactUnwind = 35,
    LLDBSectionTypeOther = 36,
};

typedef NS_OPTIONS(NSUInteger,LLDBEmulateInstructionOptions) {
    LLDBEmulateInstructionOptionsEmulateInstructionOptionNone = 0,
    LLDBEmulateInstructionOptionsEmulateInstructionOptionAutoAdvancePC = 1,
    LLDBEmulateInstructionOptionsEmulateInstructionOptionIgnoreConditions = 2,
};

typedef NS_OPTIONS(NSUInteger,LLDBFunctionNameType) {
    LLDBFunctionNameTypeNone = 0,
    LLDBFunctionNameTypeAuto = 2,
    LLDBFunctionNameTypeFull = 4,
    LLDBFunctionNameTypeBase = 8,
    LLDBFunctionNameTypeMethod = 16,
    LLDBFunctionNameTypeSelector = 32,
    LLDBFunctionNameTypeAny = 2,
};

typedef NS_ENUM(NSUInteger,LLDBBasicType) {
    LLDBBasicTypeInvalid = 0,
    LLDBBasicTypeVoid = 1,
    LLDBBasicTypeChar = 2,
    LLDBBasicTypeSignedChar = 3,
    LLDBBasicTypeUnsignedChar = 4,
    LLDBBasicTypeWChar = 5,
    LLDBBasicTypeSignedWChar = 6,
    LLDBBasicTypeUnsignedWChar = 7,
    LLDBBasicTypeChar16 = 8,
    LLDBBasicTypeChar32 = 9,
    LLDBBasicTypeShort = 10,
    LLDBBasicTypeUnsignedShort = 11,
    LLDBBasicTypeInt = 12,
    LLDBBasicTypeUnsignedInt = 13,
    LLDBBasicTypeLong = 14,
    LLDBBasicTypeUnsignedLong = 15,
    LLDBBasicTypeLongLong = 16,
    LLDBBasicTypeUnsignedLongLong = 17,
    LLDBBasicTypeInt128 = 18,
    LLDBBasicTypeUnsignedInt128 = 19,
    LLDBBasicTypeBool = 20,
    LLDBBasicTypeHalf = 21,
    LLDBBasicTypeFloat = 22,
    LLDBBasicTypeDouble = 23,
    LLDBBasicTypeLongDouble = 24,
    LLDBBasicTypeFloatComplex = 25,
    LLDBBasicTypeDoubleComplex = 26,
    LLDBBasicTypeLongDoubleComplex = 27,
    LLDBBasicTypeObjCID = 28,
    LLDBBasicTypeObjCClass = 29,
    LLDBBasicTypeObjCSel = 30,
    LLDBBasicTypeNullPtr = 31,
    LLDBBasicTypeOther = 32,
};

typedef NS_OPTIONS(NSUInteger,LLDBTypeClass) {
    LLDBTypeClassInvalid = 0,
    LLDBTypeClassArray = 1,
    LLDBTypeClassBlockPointer = 2,
    LLDBTypeClassBuiltin = 4,
    LLDBTypeClassClass = 8,
    LLDBTypeClassComplexFloat = 16,
    LLDBTypeClassComplexInteger = 32,
    LLDBTypeClassEnumeration = 64,
    LLDBTypeClassFunction = 128,
    LLDBTypeClassMemberPointer = 256,
    LLDBTypeClassObjCObject = 512,
    LLDBTypeClassObjCInterface = 1024,
    LLDBTypeClassObjCObjectPointer = 2048,
    LLDBTypeClassPointer = 4096,
    LLDBTypeClassReference = 8192,
    LLDBTypeClassStruct = 16384,
    LLDBTypeClassTypedef = 32768,
    LLDBTypeClassUnion = 65536,
    LLDBTypeClassVector = 131072,
    LLDBTypeClassOther = 2147483648,
    LLDBTypeClassAny = 4294967295,
};

typedef NS_ENUM(NSUInteger,LLDBTemplateArgumentKind) {
    LLDBTemplateArgumentKindNull = 0,
    LLDBTemplateArgumentKindType = 1,
    LLDBTemplateArgumentKindDeclaration = 2,
    LLDBTemplateArgumentKindIntegral = 3,
    LLDBTemplateArgumentKindTemplate = 4,
    LLDBTemplateArgumentKindTemplateExpansion = 5,
    LLDBTemplateArgumentKindExpression = 6,
    LLDBTemplateArgumentKindPack = 7,
};

typedef NS_OPTIONS(NSUInteger,LLDBTypeOptions) {
    LLDBTypeOptionsTypeOptionNone = 0,
    LLDBTypeOptionsTypeOptionCascade = 1,
    LLDBTypeOptionsTypeOptionSkipPointers = 2,
    LLDBTypeOptionsTypeOptionSkipReferences = 4,
    LLDBTypeOptionsTypeOptionHideChildren = 8,
    LLDBTypeOptionsTypeOptionHideValue = 16,
    LLDBTypeOptionsTypeOptionShowOneLiner = 32,
    LLDBTypeOptionsTypeOptionHideNames = 64,
};

typedef NS_ENUM(NSUInteger,LLDBFrameComparison) {
    LLDBFrameComparisonFrameCompareInvalid = 0,
    LLDBFrameComparisonFrameCompareUnknown = 1,
    LLDBFrameComparisonFrameCompareEqual = 2,
    LLDBFrameComparisonFrameCompareSameParent = 3,
    LLDBFrameComparisonFrameCompareYounger = 4,
    LLDBFrameComparisonFrameCompareOlder = 5,
};

typedef NS_ENUM(NSUInteger,LLDBAddressClass) {
    LLDBAddressClassInvalid = 0,
    LLDBAddressClassUnknown = 1,
    LLDBAddressClassCode = 2,
    LLDBAddressClassCodeAlternateISA = 3,
    LLDBAddressClassData = 4,
    LLDBAddressClassDebug = 5,
    LLDBAddressClassRuntime = 6,
};

typedef NS_OPTIONS(NSUInteger,LLDBFilePermissions) {
    LLDBFilePermissionsUserRead = 256,
    LLDBFilePermissionsUserWrite = 128,
    LLDBFilePermissionsUserExecute = 64,
    LLDBFilePermissionsGroupRead = 32,
    LLDBFilePermissionsGroupWrite = 16,
    LLDBFilePermissionsGroupExecute = 8,
    LLDBFilePermissionsWorldRead = 4,
    LLDBFilePermissionsWorldWrite = 2,
    LLDBFilePermissionsWorldExecute = 1,
    LLDBFilePermissionsUserRW = 384,
    LLDBFilePermissionsFileFilePermissionsUserRX = 320,
    LLDBFilePermissionsUserRWX = 448,
    LLDBFilePermissionsGroupRW = 48,
    LLDBFilePermissionsGroupRX = 40,
    LLDBFilePermissionsGroupRWX = 56,
    LLDBFilePermissionsWorldRW = 6,
    LLDBFilePermissionsWorldRX = 5,
    LLDBFilePermissionsWorldRWX = 7,
    LLDBFilePermissionsEveryoneR = 292,
    LLDBFilePermissionsEveryoneW = 146,
    LLDBFilePermissionsEveryoneX = 73,
    LLDBFilePermissionsEveryoneRW = 438,
    LLDBFilePermissionsEveryoneRX = 365,
    LLDBFilePermissionsEveryoneRWX = 511,
    LLDBFilePermissionsFileDefault = 384,
    LLDBFilePermissionsDirectoryDefault = 448,
};

typedef NS_ENUM(NSUInteger,LLDBQueueItemKind) {
    LLDBQueueItemKindUnknown = 0,
    LLDBQueueItemKindFunction = 1,
    LLDBQueueItemKindBlock = 2,
};

typedef NS_ENUM(NSUInteger,LLDBQueueKind) {
    LLDBQueueKindUnknown = 0,
    LLDBQueueKindSerial = 1,
    LLDBQueueKindConcurrent = 2,
};

typedef NS_ENUM(NSUInteger,LLDBExpressionEvaluationPhase) {
    LLDBExpressionEvaluationPhaseExpressionEvaluationParse = 0,
    LLDBExpressionEvaluationPhaseExpressionEvaluationIRGen = 1,
    LLDBExpressionEvaluationPhaseExpressionEvaluationExecution = 2,
    LLDBExpressionEvaluationPhaseExpressionEvaluationComplete = 3,
};

typedef NS_OPTIONS(NSUInteger,LLDBWatchpointKind) {
    LLDBWatchpointKindRead = 1,
    LLDBWatchpointKindWrite = 2,
};

typedef NS_ENUM(NSUInteger,LLDBGdbSignal) {
    LLDBGdbSignalBadAccess = 145,
    LLDBGdbSignalBadInstruction = 146,
    LLDBGdbSignalArithmetic = 147,
    LLDBGdbSignalEmulation = 148,
    LLDBGdbSignalSoftware = 149,
    LLDBGdbSignalBreakpoint = 150,
};

typedef NS_ENUM(NSUInteger,LLDBPathType) {
    LLDBPathTypeLLDBShlibDir = 0,
    LLDBPathTypeSupportExecutableDir = 1,
    LLDBPathTypeHeaderDir = 2,
    LLDBPathTypePythonDir = 3,
    LLDBPathTypeLLDBSystemPlugins = 4,
    LLDBPathTypeLLDBUserPlugins = 5,
    LLDBPathTypeLLDBTempSystemDir = 6,
    LLDBPathTypeClangDir = 7,
};

typedef NS_ENUM(NSUInteger,LLDBMemberFunctionKind) {
    LLDBMemberFunctionKindUnknown = 0,
    LLDBMemberFunctionKindConstructor = 1,
    LLDBMemberFunctionKindDestructor = 2,
    LLDBMemberFunctionKindInstanceMethod = 3,
    LLDBMemberFunctionKindStaticMethod = 4,
};

typedef NS_ENUM(NSUInteger,LLDBMatchType) {
    LLDBMatchTypeNormal = 0,
    LLDBMatchTypeRegex = 1,
    LLDBMatchTypeStartsWith = 2,
};

typedef NS_OPTIONS(NSUInteger,LLDBTypeFlags) {
    LLDBTypeFlagsTypeHasChildren = 1,
    LLDBTypeFlagsTypeHasValue = 2,
    LLDBTypeFlagsTypeIsArray = 4,
    LLDBTypeFlagsTypeIsBlock = 8,
    LLDBTypeFlagsTypeIsBuiltIn = 16,
    LLDBTypeFlagsTypeIsClass = 32,
    LLDBTypeFlagsTypeIsCPlusPlus = 64,
    LLDBTypeFlagsTypeIsEnumeration = 128,
    LLDBTypeFlagsTypeIsFuncPrototype = 256,
    LLDBTypeFlagsTypeIsMember = 512,
    LLDBTypeFlagsTypeIsObjC = 1024,
    LLDBTypeFlagsTypeIsPointer = 2048,
    LLDBTypeFlagsTypeIsReference = 4096,
    LLDBTypeFlagsTypeIsStructUnion = 8192,
    LLDBTypeFlagsTypeIsTemplate = 16384,
    LLDBTypeFlagsTypeIsTypedef = 32768,
    LLDBTypeFlagsTypeIsVector = 65536,
    LLDBTypeFlagsTypeIsScalar = 131072,
    LLDBTypeFlagsTypeIsInteger = 262144,
    LLDBTypeFlagsTypeIsFloat = 524288,
    LLDBTypeFlagsTypeIsComplex = 1048576,
    LLDBTypeFlagsTypeIsSigned = 2097152,
};

typedef NS_ENUM(NSUInteger,LLDBTypeSummaryCapping) {
    LLDBTypeSummaryCappingTypeSummaryCapped = 1,
    LLDBTypeSummaryCappingTypeSummaryUncapped = 0,
};
