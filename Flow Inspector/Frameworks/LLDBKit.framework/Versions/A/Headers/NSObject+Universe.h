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
#import "UniverseCommon.h"

@interface NSObject (Universe)
+ (id)allocWithZone:(struct _NSZone *)zone UNIVERSE_UNAVAILABLE_METHOD;
+ (id)copyWithZone:(struct _NSZone *)zone UNIVERSE_UNAVAILABLE_METHOD;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone UNIVERSE_UNAVAILABLE_METHOD;
+ (id)new UNIVERSE_UNAVAILABLE_METHOD;
- (id)copy UNIVERSE_UNAVAILABLE_METHOD;
+ (id)alloc UNIVERSE_UNAVAILABLE_METHOD;
//+ (instancetype)instantiation __attribute__((objc_method_family(new)));		//	Do not put the family attribute. Because returnning object is just plain `strong` semantics.
@end
