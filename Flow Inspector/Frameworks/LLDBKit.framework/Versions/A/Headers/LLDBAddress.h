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

@interface LLDBAddress : LLDBObject
@property (readonly,nonatomic,assign) LLDBAddressType fileAddress;
// The following functions grab individual objects for a given address and
// are less efficient if you want more than one symbol related objects.
// Use one of the following when you want multiple debug symbol related
// objects for an address:
//    lldb::SBSymbolContext SBAddress::GetSymbolContext (uint32_t resolve_scope);
//    lldb::SBSymbolContext SBTarget::ResolveSymbolContextForAddress (const SBAddress &addr, uint32_t resolve_scope);
// One or more bits from the SymbolContextItem enumerations can be logically
// OR'ed together to more efficiently retrieve multiple symbol objects.
@property (readonly,nonatomic,copy) LLDBSection* section;
@property (readonly,nonatomic,assign) LLDBAddressType offset;
@property (readonly,nonatomic,copy) LLDBModule* module;
@property (readonly,nonatomic,copy) LLDBCompileUnit* compileUnit;
@property (readonly,nonatomic,copy) LLDBFunction* function;
@property (readonly,nonatomic,copy) LLDBBlock* block;
@property (readonly,nonatomic,copy) LLDBSymbol* symbol;
@property (readonly,nonatomic,copy) LLDBLineEntry* lineEntry;
@property (readonly,nonatomic,assign) LLDBAddressClass addressClass;

- (instancetype)init UNIVERSE_UNAVAILABLE_METHOD;
- (instancetype)initWithAddress:(LLDBAddressType) address andTarget:(LLDBTarget *) target;
- (LLDBAddressType)loadAddressWithTarget:(LLDBTarget*)target;
- (void)setAddressWithSection:(LLDBSection*)section offset:(LLDBAddressType)offset;
- (void)setLoadAddress:(LLDBAddressType)loadAddress target:(LLDBTarget*)target;
- (BOOL)offsetAddress:(LLDBAddressType)offset;

//// The following queries can lookup symbol information for a given address.
//// An address might refer to code or data from an existing module, or it
//// might refer to something on the stack or heap. The following functions
//// will only return valid values if the address has been resolved to a code
//// or data address using "void SBAddress::SetLoadAddress(...)" or
//// "lldb::SBAddress SBTarget::ResolveLoadAddress (...)".
- (LLDBSymbolContext*)symbolContext:(uint32_t)resolveScope;
- (BOOL)isEqualTo:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (BOOL)isEqual:(id)object UNIVERSE_UNAVAILABLE_METHOD;
- (NSString *)description;
@end
