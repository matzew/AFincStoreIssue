//
//  AFincStoreIssueTests.m
//  AFincStoreIssueTests
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import "AFincStoreIssueTests.h"
#import <CoreData/CoreData.h>
#import "MyIncStore.h"

//models:
#import "Tag.h"
#import "Task.h"

@implementation AFincStoreIssueTests {
    // CoreData bits.......
    NSManagedObjectContext *__managedObjectContext;
    NSManagedObjectModel * __managedObjectModel;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    
    // flag to abort:
    BOOL _finishedFlag;
    
}

- (void)setUp
{
    [super setUp];
    
    // create the model object.....
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"TestModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    
    // pass it to the Store.....
    [MyIncStore setModel:__managedObjectModel];
    
    
    // get the CoreData stack:
    __managedObjectContext = [self managedObjectContext];
    
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSaveAndUpdateTag
{
    NSManagedObjectContext *context = __managedObjectContext;
    
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
    tag.title = @"CD Tag";
    tag.tagId = nil;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"AFIncrementalStoreContextDidSaveRemoteValues" object:context queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        
        // the save was done..., server DID assign an ID:
        NSLog(@" Tag ID: %@", tag.tagId);
        
        // update the title:
        tag.title = @"Updated Tag";
        
        
        // and save:
        NSError *error = nil;
        if ([context save:&error]) {
            NSLog(@"The update was successful!");
        } else {
            NSLog(@"The update wasn't successful: %@", [error userInfo]);
            //_finishedFlag = YES;
        }
        
    }];
    
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"The save was successful!");
        //_finishedFlag =YES;
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}



#pragma mark - Core Data

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    MyIncStore *incrementalStore = (MyIncStore *)[__persistentStoreCoordinator addPersistentStoreWithType:[MyIncStore type] configuration:nil URL:nil options:nil error:nil];
    NSError *error = nil;
    if (![incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

@end
