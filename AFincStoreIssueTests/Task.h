//
//  Task.h
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * project;
@property (nonatomic, retain) NSNumber * taskId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
