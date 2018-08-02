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

@interface LLDBData : LLDBObject

@property (readwrite, nonatomic, assign) uint8_t addressByteSize;
@property (readonly, nonatomic, assign) size_t byteSize;
@property (readwrite, nonatomic, assign) LLDBByteOrder byteOrder;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (size_t)readRawDataWithOffset:(LLDBOffsetType)offset buffer:(void*)buffer size:(size_t)size error:(LLDBError**)error;

// it would be nice to have SetData(SBError, const void*, size_t) when endianness and address size can be
// inferred from the existing DataExtractor, but having two SetData() signatures triggers a SWIG bug where
// the typemap isn't applied before resolving the overload, and thus the right function never gets called
- (void)setDataWithBuffer:(void const*)buffer size:(size_t)size endian:(LLDBByteOrder)endian addressSize:(uint8_t)addressSize error:(LLDBError**)error;
- (void)append:(LLDBData*)data;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description;
@end
