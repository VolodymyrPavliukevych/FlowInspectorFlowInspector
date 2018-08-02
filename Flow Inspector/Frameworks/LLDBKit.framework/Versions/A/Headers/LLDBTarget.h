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
#import	"LLDBObject.h"
#import "LLDBDeclarations.h"

@interface	LLDBTarget: LLDBObject
@property (readonly, nonatomic, copy) LLDBDebugger*	debugger;
@property (readonly, nonatomic, copy) LLDBProcess* process;
@property (readonly, nonatomic, assign) uint32_t numberOfModules;
@property (readonly, nonatomic, assign) uint32_t numberOfBreakpoints;
@property (readonly, nonatomic, copy) LLDBBroadcaster* broadcaster;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;

- (LLDBFileSpec*)executableFileSpec;
- (LLDBBreakpoint*)createBreakpointByLocationWithFileSpec:(LLDBFileSpec*)fileSpec lineNumber:(uint32_t)lineNumber;
- (LLDBBreakpoint*)createBreakpointByName:(NSString*)symbolName;
- (LLDBBreakpoint*)createBreakpointByName:(NSString*)symbolName moduleName:(NSString*)moduleName;
- (LLDBBreakpoint *)createBreakpointByAddress:(uint64_t) address;
- (LLDBBreakpoint *)createBreakpointByLLDBAddress:(LLDBAddress *) address;
- (LLDBProcess *)launchProcessWithInfo:(LLDBLaunchInfo *) info andError:(LLDBError *__autoreleasing *)error;
- (LLDBProcess *)launchProcessSimplyWithWorkingDirectory:(NSString *)workingDirectory
                                            andArguments:(NSArray<NSString *> *) arguments
                                          andEnvironment:(NSArray<NSString *> *) environment;
- (LLDBProcess*)instantiateProcessByLaunchingSimplyWithArguments:(NSArray*)arguments environments:(NSArray*)environments workingDirectory:(NSString*)workingDirectory;
- (LLDBProcess*)attachToProcessWithID:(uint64_t)pid error:(LLDBError**)error;
- (LLDBModule*)moduleAtIndex:(uint32_t)index;
- (LLDBModule*)findModule:(LLDBFileSpec*)fileSpec;
- (NSString*)triple;
- (LLDBBreakpoint*)breakpointAtIndex:(uint32_t)index;
- (BOOL) isEqualToTarget:(LLDBTarget*)object;
- (BOOL) isEqual:(id)object;
- (LLDBLaunchInfo *) launchInfo;
- (LLDBType *) findFirstType:(NSString *) typeName;
- (LLDBSymbolContextList *) findFunction:(NSString *) name;
@end


@interface LLDBTarget (LLDBObjectiveCLayerExtensions)
- (NSArray*)allBreakpoints;
- (NSString *)description;
@end
