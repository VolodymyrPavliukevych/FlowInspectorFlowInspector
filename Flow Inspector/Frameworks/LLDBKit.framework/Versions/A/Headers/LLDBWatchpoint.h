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

@interface LLDBWatchpoint : LLDBObject

@property (readonly, nonatomic, copy) LLDBError* error;
//@property (readonly, nonatomic, copy) LLDBWatchIDType ID;
//@property (readonly, nonatomic, copy) int32_t hardwareIndex;
//@property (readonly, nonatomic, copy) LLDBAddressType watchAddress;
//@property (readonly, nonatomic, copy) size_t watchSize;
@property (readwrite,nonatomic, assign,getter = isEnabled) BOOL enabled;
//@property (readonly, nonatomic, copy) uint32_t hitCount;
@property (readwrite,nonatomic, assign) uint32_t ignoreCount;
@property (readwrite,nonatomic, copy) NSString* condition;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description;

@end
