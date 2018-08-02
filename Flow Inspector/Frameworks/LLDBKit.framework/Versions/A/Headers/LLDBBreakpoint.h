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

typedef BOOL(^LLDBBreakpointHitCallback)(LLDBProcess* process, LLDBThread* thread, LLDBBreakpointLocation* location);

@interface	LLDBBreakpoint : LLDBObject

@property (readwrite, nonatomic, assign) LLDBBreakpointIDType ID;
@property (readwrite, nonatomic, assign,getter = isEnabled) BOOL enabled;
@property (readwrite, nonatomic, assign,getter = isOntShot) BOOL oneShot;
@property (readonly, nonatomic, assign, getter = isOnternal) BOOL internal;
@property (readonly, nonatomic, assign) uint32_t hitCount;
@property (readwrite, nonatomic, assign) uint32_t ignoreCount;
@property (readwrite, nonatomic, assign) size_t resolvedLocations;
@property (readwrite, nonatomic, copy) NSString* condition;
@property (readwrite, nonatomic, assign) LLDBThreadIDType threadID;
@property (readwrite, nonatomic, assign) uint32_t threadIndex;
@property (readwrite, nonatomic, copy) NSString* threadName;
@property (readwrite, nonatomic, copy) NSString* queueName;
@property (readwrite, nonatomic, copy) LLDBBreakpointHitCallback callback;
@property (readonly,nonatomic,assign) size_t numberOfResolvedLocations;
@property (readonly,nonatomic,assign) size_t numberOfLocations;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqualToBreakpoint:(LLDBBreakpoint*)breakpoint;
- (BOOL)isEqualTo:(id)object;
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end
