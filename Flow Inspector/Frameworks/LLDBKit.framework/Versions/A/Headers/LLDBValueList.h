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

@interface LLDBValueList : LLDBObject
@property (readonly, nonatomic, assign) uint32_t size;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (LLDBValue*)valueAtIndex:(uint32_t)index;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description UNIVERSE_UNAVAILABLE_METHOD;

@end
