//
//  MyIncStoreClient.m
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import "MyIncStoreClient.h"

@implementation MyIncStoreClient

+ (MyIncStoreClient *) clientFor:(NSURL *)baseURL {
    return [[self alloc] initWithBaseURL:baseURL];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
}

// no caching:
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest* req = [super requestWithMethod:method path:path parameters:parameters];
    // disable the default cookie handling in the override:
    [req setHTTPShouldHandleCookies:NO];
    return req;
}





/////      AFIncrementalStoreHTTPClient     functions.........


-(NSDictionary *)representationsForRelationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fromResponse:(NSHTTPURLResponse *)response {
    NSMutableDictionary *relationshipReps = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id name, id relationship, BOOL *stop) {
        if ([entity.name isEqualToString:@"Task"])
        {
            if ([name isEqualToString:@"tags"])
            {
                
                /// hrm.......... this just adds the IDs......
                NSArray *orderIDs = [representation objectForKey:@"tags"];
                [relationshipReps setObject:orderIDs forKey:name];
                

                /// shouldnt it go and look up the /tags URI,
                /// to filter those TAG objects, that we want ???
                
                
                
                
//                NSLog(@"\n\n%@\n\n", [[representation objectForKey:@"tags"] class]);
//                NSLog(@"\n\n%@\n\n", [representation objectForKey:@"tags"]);
//                if (orderIDs) {
//                    NSMutableArray *orderReps = [[NSMutableDictionary dictionaryWithCapacity:orderIDs.count] array];
//
//                    for (NSString *orderID in orderIDs) {
//                                            NSLog(@"\n\n%@\n\n\n", orderID);
//                        [orderReps addObject:[NSDictionary dictionaryWithObjectsAndKeys:orderID, @"id", nil]];
//                    }
//                    [relationshipReps setObject:orderReps forKey:name];
//                }
            }
        }
    }];
    
    
    
    
    return relationshipReps;
}

// never invoked........
-(NSMutableURLRequest *)requestWithMethod:(NSString *)method pathForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context {
    NSLog(@"\n\nrequestWithMethod\n\n");
    return [super requestWithMethod:method pathForRelationship:relationship forObjectWithID:objectID withContext:context];
    
    
}

-(NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fromResponse:(NSHTTPURLResponse *)response {
    // ODD... we only have the referenced ID here...
    // I was expecting a JSON response of the /tags URI.......
    if ([entity.name isEqualToString:@"Tag"]) {
        return [representation description];
    } else {
        return [super resourceIdentifierForRepresentation:representation ofEntity:entity fromResponse:response];
    }
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    
    NSLog(@"\n\nattributesForRepresentation ->%@\n", representation);
    
    // For the TASK entity, we get [something like:]
//    {
//        date = "2012-01-20";
//        description = "my wife's birthday";
//        id = 86;
//        project = 71;
//        tags =     (
//                    31
//                    );
//        title = hb;
//    } 
    

    // BUT... for the TAG entity..... we just get the ID (number).....  (here 31)
    // Unfortunately there was NO request gone to /tags ...........
    
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    if ([entity.name isEqualToString:@"Tag"]) {
        NSString *tagId = [representation valueForKey:@"id"];
        [mutablePropertyValues setValue:tagId forKey:@"tagId"];
    } else if ([entity.name isEqualToString:@"Task"]) {
        NSString *description = [representation valueForKey:@"description"];
        [mutablePropertyValues setValue:description forKey:@"desc"];
        NSString *taskId = [representation valueForKey:@"id"];
        [mutablePropertyValues setValue:taskId forKey:@"taskId"];

    }

    
    return mutablePropertyValues;
}

// hrm.... but the requestWithMethod:pathForRelationship is NOT inviked....
-(BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID inManagedObjectContext:(NSManagedObjectContext *)context {
    return YES;
}


@end
