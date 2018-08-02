//
//  LLDBLaunchInfo.h
//  LLDBKit
//
//  Created by Volodymyr Pavliukevych on 6/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

#pragma once
#import "LLDBObject.h"
#import "LLDBDeclarations.h"

@interface LLDBLaunchInfo : LLDBObject {}
- (instancetype)init;
- (instancetype)initWithArgs:(const char **) args;
- (void) setEnvironment:(const char **) environment append:(BOOL) append;
- (void) setArgument:(const char **) arguments append:(BOOL) append;
- (NSDictionary<NSString *, NSString*> *) getEnvironment;
- (NSString *) description;

@end
