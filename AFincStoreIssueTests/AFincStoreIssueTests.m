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

- (void)testFetchTags
{
    NSManagedObjectContext *context = __managedObjectContext;
    
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"AFIncrementalStoreContextDidFetchRemoteValues" object:context queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        NSArray *fetchedObjects = [userInfo objectForKey:@"AFIncrementalStoreFetchedObjectsKey"];
        
        for(Tag *tag in fetchedObjects) {
            NSLog(@"Tag(%@) -> title: %@", tag.tagId, tag.title);
        }
        
        _finishedFlag = YES;
    }];
    
    [context executeFetchRequest:fetchRequest error:&error];
    
    // keep the run loop going
    while(!_finishedFlag) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)testFetchTasks
{
    NSManagedObjectContext *context = __managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"AFIncrementalStoreContextDidFetchRemoteValues" object:context queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        NSArray *fetchedObjects = [userInfo objectForKey:@"AFIncrementalStoreFetchedObjectsKey"];
        
        for(Task *task in fetchedObjects) {
            NSLog(@"Task(%@) -> title: %@ (desc: '%@')", task.taskId, task.title, task.desc);
        }
        _finishedFlag = YES;
    }];
    
    [context executeFetchRequest:fetchRequest error:&error];
    
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
