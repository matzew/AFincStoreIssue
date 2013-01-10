//
//  MyIncStore.h
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFIncrementalStore.h"


@interface MyIncStore : AFIncrementalStore

// tmp hack:
+ (void) setModel:(NSManagedObjectModel *)model;

@end
