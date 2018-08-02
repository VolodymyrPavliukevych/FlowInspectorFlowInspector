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

@interface LLDBCompileUnit : LLDBObject
- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;

@property	(readonly,nonatomic,copy)	LLDBFileSpec*		fileSpec;
@property	(readonly,nonatomic,assign)	uint32_t			numberOfLineEntries;
- (LLDBLineEntry*)lineEntryAtIndex:(uint32_t)index;

- (LLDBFileSpec*)supportFileAtIndex:(uint32_t)index;
@property	(readonly,nonatomic,assign)	uint32_t			numberOfSupportFiles;

- (BOOL)isEqualToCompileUnit:(LLDBCompileUnit*)compileUnit;
- (BOOL)isEqualTo:(id)object;
- (BOOL)isEqual:(id)object;
- (NSString *)description;
@end
