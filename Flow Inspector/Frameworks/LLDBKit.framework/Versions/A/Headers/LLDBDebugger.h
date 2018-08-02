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
#import "LLDBEnums.h"

extern NSString* const LLDBArchDefault;
extern NSString* const LLDBArchDefault32Bit;
extern NSString* const LLDBArchDefault64Bit;

@interface	LLDBDebugger : LLDBObject

@property (readwrite, nonatomic, assign) BOOL async;
@property (readonly, nonatomic, copy) LLDBListener* listener;
@property (readwrite, nonatomic, assign) FILE* inputFileHandle;
@property (readwrite, nonatomic, assign) FILE* outputFileHandle;
@property (readwrite, nonatomic, assign) FILE* errorFileHandle;
//@property (readwrite, nonatomic, strong) LLDBFileHandle* outputFileHandle;
@property (readonly, nonatomic, assign) uint32_t numberOfTargets;
@property (readonly, nonatomic, copy) LLDBSourceManager* sourceManager;

- (instancetype)init;
- (NSString*)stringOfState:(LLDBStateType)state;
- (LLDBTarget*)createTargetWithFilename:(NSString*)filename;
- (LLDBTarget*)createTargetWithFilename:(NSString*)filename andArchname:(NSString*)archname;
- (LLDBTarget *)createTargetWithFilename:(NSString *)filename andTargetTriple:(NSString *)targetTriple platform:(NSString *)platform addDependentModules:(BOOL) addModules andError:(LLDBError *__autoreleasing *)error;
- (BOOL)deleteTarget:(LLDBTarget*)target;
- (void)setOutputFileHandle:(FILE *)outputFileHandle transferOwnership:(BOOL)transferOwnership;
- (LLDBTarget*)targetAtIndex:(uint32_t)index;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (void)dealloc;
- (NSString *)description;

@end









