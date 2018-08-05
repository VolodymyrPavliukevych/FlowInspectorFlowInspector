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
#import "LLDBObject.h"
#import "LLDBDeclarations.h"
//#import "LLDBStateType.h"
#import "LLDBEnums.h"

@interface	LLDBProcess : LLDBObject

@property (readonly, nonatomic, strong) LLDBTarget* target;
@property (readonly, nonatomic, assign) LLDBByteOrder byteOrder;
@property (readonly, nonatomic, assign) NSUInteger numberOfThreads;
@property (readonly, nonatomic, copy) LLDBThread* selectedThread;
@property (readonly, nonatomic, assign) LLDBStateType state;
@property (readonly, nonatomic, assign) int exitStatus;
@property (readonly, nonatomic, assign) NSString* exitDescription;

//------------------------------------------------------------------
/// Gets the process ID
///
/// Returns the process identifier for the process as it is known
/// on the system on which the process is running. For unix systems
/// this is typically the same as if you called "getpid()" in the
/// process.
///
/// @return
///     Returns LLDB_INVALID_PROCESS_ID if this object does not
///     contain a valid process object, or if the process has not
///     been launched. Returns a valid process ID if the process is
///     valid.
//------------------------------------------------------------------
@property (readonly, nonatomic, assign) LLDBProcessIDType processID;

//------------------------------------------------------------------
/// Gets the unique ID associated with this process object
///
/// Unique IDs start at 1 and increment up with each new process
/// instance. Since starting a process on a system might always
/// create a process with the same process ID, there needs to be a
/// way to tell two process instances apart.
///
/// @return
///     Returns a non-zero integer ID if this object contains a
///     valid process object, zero if this object does not contain
///     a valid process object.
//------------------------------------------------------------------
@property (readonly,nonatomic,assign) uint32_t uniqueID;
@property (readonly,nonatomic,assign) uint32_t addressByteSize;

//------------------------------------------------------------------
/// Return the number of different thread-origin extended backtraces
/// this process can support.
///
/// When the process is stopped and you have an SBThread, lldb may be
/// able to show a backtrace of when that thread was originally created,
/// or the work item was enqueued to it (in the case of a libdispatch
/// queue).
///
/// @return
///   The number of thread-origin extended backtrace types that may be
///   available.
//------------------------------------------------------------------
@property (readonly, nonatomic, assign) uint32_t numberOfExtendedBacktraceTypes;
@property (readonly, nonatomic, copy) LLDBBroadcaster* broadcaster;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (size_t)putStandardInput:(const char*)source length:(size_t)length;
- (size_t)getStandardOutput:(char*)destination length:(size_t)length;
- (size_t)getStandardError:(char*)destination length:(size_t)length;
- (size_t)asynchronousProfileData:(char*)destination length:(size_t)length;
- (LLDBThread*)threadAtIndex:(NSUInteger)index;
- (LLDBThread*)threadByID:(LLDBThreadIDType)threadID;
- (LLDBThread*)threadByIndexID:(uint32_t)indexID;
- (BOOL)setSelectedThread:(LLDBThread*)thread;

- (LLDBError*)destroy;
- (LLDBError*)continue;
- (LLDBError*)stop;
- (LLDBError*)kill;
- (LLDBError*)detach;
- (LLDBError*)detach:(BOOL)keepStopped;
- (LLDBError*)signal:(int)signal;

- (void)sendAsynchronousInterrupt;
- (uint32_t)stopID:(BOOL)includeExpressionStops;
- (uint32_t)stopID;

- (size_t)readMemory:(LLDBAddressType)address buffer:(void*)buffer size:(size_t)size error:(LLDBError**)error;
- (size_t)writeMemory:(LLDBAddressType)address buffer:(const void*)buffer size:(size_t)size error:(LLDBError**)error;
- (size_t)readCString:(LLDBAddressType)address buffer:(void *)buffer size:(size_t)size error:(LLDBError *__autoreleasing *)error;
    
+ (LLDBStateType)stateFromEvent:(LLDBEvent*)event;
+ (BOOL)restartedFromEvent:(LLDBEvent*)event;
+ (size_t)numberOfRestartedReasonsFromEvent:(LLDBEvent*)event;
+ (NSString*)restartedReasonAtIndexFromEvent:(LLDBEvent*)event index:(size_t)index;

- (uint32_t)numberOfSupportedHardwareWatchpoints:(LLDBError**)error;
- (uint32_t)loadImage:(LLDBFileSpec*)imageSpec error:(LLDBError**)error;
- (LLDBError*)unloadImage:(uint32_t)imageToken;

//------------------------------------------------------------------
/// Return the name of one of the thread-origin extended backtrace
/// methods.
///
/// @param [in] index
///   The index of the name to return.  They will be returned in
///   the order that the user will most likely want to see them.
///   e.g. if the type at index 0 is not available for a thread,
///   see if the type at index 1 provides an extended backtrace.
///
/// @return
///   The name at that index.
//------------------------------------------------------------------
- (NSString*)extendedBacktraceTypeAtIndex:(uint32_t)index;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description;
@end












