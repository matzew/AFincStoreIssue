//
//  MyIncStore.m
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import "MyIncStore.h"
#import "MyIncStoreClient.h"

@implementation MyIncStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

// static hack:
NSManagedObjectModel *___model;
// "getter"
+ (NSManagedObjectModel *)model {
    return ___model;
}
// setter:
+ (void) setModel:(NSManagedObjectModel *)model {
    ___model = model;
}

// override the library Getter:
- (id <AFIncrementalStoreHTTPClient>)HTTPClient {
    return [MyIncStoreClient clientFor:[NSURL URLWithString:@"https://todo-aerogear.rhcloud.com/todo-server/"]];
}

@end
