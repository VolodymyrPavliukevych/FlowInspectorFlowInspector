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

@interface LLDBListener : LLDBObject
- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (instancetype)initWithName:(NSString*)name;

- (void)addEvent:(LLDBEvent*)event;
- (uint32_t)startListeningForEventClass:(LLDBDebugger*)debugger broadcasterClass:(NSString*)broadcasterClass eventMask:(uint32_t)eventMask;
- (BOOL)stopListeningForEventClass:(LLDBDebugger*)debugger broadcasterClass:(NSString*)broadcasterClass eventMask:(uint32_t)eventMask;
- (uint32_t)startListeningForEvents:(LLDBDebugger*)debugger broadcasterClass:(NSString*)broadcasterClass eventMask:(uint32_t)eventMask;
- (BOOL)stopListeningForEvents:(LLDBDebugger*)debugger broadcasterClass:(NSString*)broadcasterClass eventMask:(uint32_t)eventMask;
- (BOOL)waitForEvent:(uint32_t)numSeconds event:(LLDBEvent**)event;
- (BOOL)waitForEventForBroadcasterWithType:(uint32_t)numSeconds broadcaster:(LLDBBroadcaster*)broadcaster eventTypeMask:(uint32_t)eventTypeMask event:(LLDBEvent*)event;
- (BOOL)peekAtNextEvent:(LLDBEvent*)event;
- (BOOL)peekAtNextEventForBroadcaster:(LLDBBroadcaster*)broadcaster event:(LLDBEvent*)event;
- (BOOL)peekAtNextEventForBroadcasterWithType:(LLDBBroadcaster*)broadcaster eventTypeMask:(uint32_t)eventTypeMask event:(LLDBEvent*)event;
- (BOOL)nextEvent:(LLDBEvent*)event;
- (BOOL)nextEventForBroadcaster:(LLDBBroadcaster*)broadcaster event:(LLDBEvent*)event;
- (BOOL)nextEventForBroadcasterWithType:(LLDBBroadcaster*)broadcaster eventTypeMask:(uint32_t)eventTypeMask event:(LLDBEvent*)event;
- (BOOL)handleBroadcastEvent:(LLDBEvent*)event;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description UNIVERSE_UNAVAILABLE_METHOD;

@end
