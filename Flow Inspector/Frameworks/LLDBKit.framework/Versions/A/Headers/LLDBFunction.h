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

@interface LLDBFunction : LLDBObject
@property (readonly, nonatomic, copy) NSString* name;
@property (readonly, nonatomic, copy) NSString* mangledName;
@property (readonly, nonatomic, copy) LLDBAddress* startAddress;
@property (readonly, nonatomic, copy) LLDBAddress* endAddress;
@property (readonly, nonatomic, assign) uint32_t prologueByteSize;
/*@property (readonly, nonatomic, copy) LLDBType* type;*/
@property (readonly, nonatomic, copy) LLDBBlock* block;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (LLDBInstructionList*)instructionsForTarget:(LLDBTarget*)target;
- (LLDBInstructionList*)instructionsForTarget:(LLDBTarget*)target flavor:(NSString*)flavor;
- (BOOL)isEqualToFunction:(LLDBFunction*)object;
- (BOOL)isEqual:(id)object;
- (NSString *)description;

@end
