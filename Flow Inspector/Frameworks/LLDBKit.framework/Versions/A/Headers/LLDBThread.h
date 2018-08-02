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
#import "LLDBEnums.h"


@interface	LLDBThread : LLDBObject

@property(readonly,nonatomic,assign) LLDBStopReason	stopReason;
@property(readonly,nonatomic,assign) size_t stopReasonDataCount;
@property (readonly,nonatomic,assign) LLDBThreadIDType threadID;
@property (readonly,nonatomic,assign) uint32_t indexID;
@property (readonly,nonatomic,copy) NSString* name;
@property (readonly,nonatomic,copy) NSString* queueName;
@property (readonly,nonatomic,assign) LLDBQueueIDType queueID;
@property (readonly,nonatomic,assign,getter=isSuspended) BOOL suspended;
@property (readonly,nonatomic,assign,getter=isStopped) BOOL stopped;
@property (readonly,nonatomic,assign) uint32_t numberOfFrames;
@property (readonly,nonatomic,assign) LLDBFrame* selectedFrame;
@property (readonly,nonatomic,strong) LLDBProcess* process;
@property (readonly,nonatomic,copy) NSString* status;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;

//--------------------------------------------------------------------------
/// Get information associated with a stop reason.
///
/// Breakpoint stop reasons will have data that consists of pairs of
/// breakpoint IDs followed by the breakpoint location IDs (they always come
/// in pairs).
///
/// Stop Reason              Count Data Type
/// ======================== ===== =========================================
/// eStopReasonNone          0
/// eStopReasonTrace         0
/// eStopReasonBreakpoint    N     duple: {breakpoint id, location id}
/// eStopReasonWatchpoint    1     watchpoint id
/// eStopReasonSignal        1     unix signal number
/// eStopReasonException     N     exception data
/// eStopReasonExec          0
/// eStopReasonPlanComplete  0
//--------------------------------------------------------------------------

- (uint64_t)stopReasonDataAtIndex:(uint32_t)index;
- (size_t)stopDescription:(char*)destination length:(size_t)length;
- (NSString*)stopDescription;
- (LLDBValue*)stopReturnValue;
- (void)stepOver;
- (void)stepOverWithRunMode:(LLDBRunMode)stopOtherThreads;
- (void)stepInto;
- (void)stepIntoWithRunMode:(LLDBRunMode)stopOtherThreads;
- (void)stepOut;
- (void)stepOutOfFrame:(LLDBFrame*)frame;
- (void)stepInstruction:(BOOL)stepOver;
- (LLDBError*)stepOverUntilFrame:(LLDBFrame*)frame file:(LLDBFileSpec*)fileSpec line:(uint32_t)line;
- (LLDBError*)jumpToFile:(LLDBFileSpec*)fileSpec line:(uint32_t)line;
- (void)runToAddress:(LLDBAddressType)address;
- (LLDBError*)returnFromFrame:(LLDBFrame*)frame returnValue:(LLDBValue**)returnValue;

//--------------------------------------------------------------------------
/// LLDB currently supports process centric debugging which means when any
/// thread in a process stops, all other threads are stopped. The Suspend()
/// call here tells our process to suspend a thread and not let it run when
/// the other threads in a process are allowed to run. So when
/// SBProcess::Continue() is called, any threads that aren't suspended will
/// be allowed to run. If any of the SBThread functions for stepping are
/// called (StepOver, StepInto, StepOut, StepInstruction, RunToAddres), the
/// thread will not be allowed to run and these funtions will simply return.
///
/// Eventually we plan to add support for thread centric debugging where
/// each thread is controlled individually and each thread would broadcast
/// its state, but we haven't implemented this yet.
///
/// Likewise the SBThread::Resume() call will again allow the thread to run
/// when the process is continued.
///
/// Suspend() and Resume() functions are not currently reference counted, if
/// anyone has the need for them to be reference counted, please let us
/// know.
//--------------------------------------------------------------------------
- (BOOL)suspend;
- (BOOL)resume;
- (LLDBFrame*)frameAtIndex:(uint32_t)index;
- (LLDBFrame*)setSelectedFrameByIndex:(uint32_t)frameIndex;
- (BOOL)isEqualToThread:(LLDBThread*)object;
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end
















