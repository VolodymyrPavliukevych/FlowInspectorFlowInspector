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

typedef	uint64_t	LLDBAddressType;
typedef uint64_t	LLDBThreadIDType;
typedef uint64_t	LLDBProcessIDType;
typedef uint64_t	LLDBQueueIDType;
typedef int32_t		LLDBBreakpointIDType;
typedef	uint64_t	LLDBOffsetType;
typedef uint64_t	LLDBUserIDType;
typedef	int32_t		LLDBWatchIDType;

@class	LLDBDebugger;
@class	LLDBBreakpoint;
@class	LLDBBreakpointLocation;
@class	LLDBWatchpoint;

@class	LLDBTarget;
@class  LLDBLaunchInfo;
@class	LLDBProcess;
@class	LLDBThread;
@class	LLDBFrame;

@class	LLDBSourceManager;
@class	LLDBFileSpec;
@class	LLDBLineEntry;

@class	LLDBModule;
@class	LLDBCompileUnit;
@class	LLDBSection;
@class	LLDBFunction;
@class	LLDBBlock;
@class	LLDBInstructionList;
@class	LLDBInstruction;
@class	LLDBSymbol;
@class	LLDBValueList;
@class	LLDBValue;
@class	LLDBSymbolContext;

@class	LLDBBroadcaster;
@class	LLDBListener;
@class	LLDBEvent;

@class	LLDBError;
@class	LLDBAddress;
@class	LLDBData;
@class	LLDBFileHandle;

@class	LLDBObject;

@class LLDBSymbolContext;
@class LLDBSymbolContextList;

@class LLDBType;
