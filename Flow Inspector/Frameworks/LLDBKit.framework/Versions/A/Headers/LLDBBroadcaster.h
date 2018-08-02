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

/*!
 Eonil: This seems to be an analogue to Cocoa target-action mechanism.
 */
@interface LLDBBroadcaster : LLDBObject

@property    (readonly,nonatomic,copy)    NSString*    name;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (instancetype)initWithName:(NSString*)name;
- (void)broadcastEventByType:(uint32_t)eventType unique:(BOOL)unique;
- (void)broadcastEvent:(LLDBEvent*)event unique:(BOOL)unique;
- (void)addInitialEventsToListener:(LLDBListener*)listener requestedEvents:(uint32_t)requestedEvents;

/* Return the event bits that were granted to the listener */
- (uint32_t)addListener:(LLDBListener*)listener eventMask:(uint32_t)eventMask;
- (BOOL)eventTypeHasListeners:(uint32_t)eventType;
- (BOOL)removeListener:(LLDBListener*)listener eventMask:(uint32_t)eventMask;

/* Defines sort order of broadcaster object. */
- (BOOL)isLessThanBroadcaster:(LLDBBroadcaster*)broadcaster;
- (BOOL)isLessThan:(id)object;

- (BOOL)isLessThanOrEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isGreaterThan:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isGreaterThanOrEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;

/* Performs identity comparison. */
- (BOOL)isEqualToBroadcaster:(LLDBBroadcaster*)broadcaster;
- (BOOL)isEqualTo:(id)object;
- (BOOL)isEqual:(id)object;
- (NSString *)description UNIVERSE_UNAVAILABLE_METHOD;

@end
