//
//  Task.h
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * project;
@property (nonatomic, retain) NSNumber * taskId;

@end