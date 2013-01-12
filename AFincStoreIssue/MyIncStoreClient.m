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






#pragma mark AFIncrementalStoreHTTPClient


/////      AFIncrementalStoreHTTPClient     functions.........



// for post/put...
-(NSDictionary *)representationOfAttributes:(NSDictionary *)attributes ofManagedObject:(NSManagedObject *)managedObject {
    // get the given managed bean as key/valye store (dictionary)
    NSDictionary *managedObjectRepresentation =  [[super representationOfAttributes:attributes ofManagedObject:managedObject] mutableCopy];
    
    // dictionary with key/value pairs, to be sent to the server
    NSMutableDictionary *externalRepresentation = [NSMutableDictionary dictionaryWithCapacity:managedObjectRepresentation.count];
    
    if ([@"Tag" isEqualToString:managedObject.entity.name]) {
        // the title
        NSString *title =[managedObject valueForKey:@"title"];
        [externalRepresentation setValue:title forKey:@"title"];
        
        // the id mapping
        NSNumber *tagId = [managedObject valueForKey:@"tagId"];
        [externalRepresentation setValue:tagId forKey:@"id"];
        
    }
    
    return externalRepresentation;
}


-(NSDictionary *)representationsForRelationshipsFromRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fromResponse:(NSHTTPURLResponse *)response {
    NSMutableDictionary *relationshipReps = [NSMutableDictionary dictionaryWithCapacity:[entity.relationshipsByName count]];
    
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(id name, id relationship, BOOL *stop) {
        if ([entity.name isEqualToString:@"Task"])
        {
            if ([name isEqualToString:@"tags"])
            {
                
                /// hrm the 'tags' field in the JSON contains ONLY the tag ids...
                // .......... this just adds the IDs......
                
                // not sure if that is really correct........
                NSArray *orderIDs = [representation objectForKey:@"tags"];
                [relationshipReps setObject:orderIDs forKey:name];
            }
        }
    }];
    
    
    
    
    return relationshipReps;
}

/**
 * The default for AFIS is to fetch relations from something like:
 *
 * ```/entityPlural/{id}/relationship```
 *
 * But, we don't support that - instead we have flat URIs...:
 *
 * ```/entityPlural```
 *
 * So we just use the name of the relationship as the URI....
 *
 */
- (NSString *)pathForRelationship:(NSRelationshipDescription *)relationship
                        forObject:(NSManagedObject *)object {
    
    // if the relationship is named 'tags' the URI would be /tags
    return relationship.name;
}


-(NSString *)resourceIdentifierForRepresentation:(NSDictionary *)representation ofEntity:(NSEntityDescription *)entity fromResponse:(NSHTTPURLResponse *)response {
    
    // when parsing the 'tags' field, on the /tasks request, we are only having the referenced ID here...
    // if NOT overriding this, I get an exception, because 'allKeys' is called on the __NSCFNumber (-> the referenced id)
    
    
    // Not sure why... but I was expecting a JSON response of another request against  /tags URI (to look up the details of the
    // referenced items.....
    if ([entity.name isEqualToString:@"Tag"]) {
        
        // hack... see above comment...
        return [representation description];
    } else {
        // for Task entity we are OK in using the default...
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
    
    
    // BUT...
    // for the TAG entity..... we just get the ID (number).....
    // Unfortunately there was NO request gone to /tags ...........
    if ([representation isKindOfClass:[NSNumber class]]) {
        // hrm...... I need to put the ID (number) into a dictionary????
        representation = [NSDictionary dictionaryWithObjectsAndKeys:representation, @"id", nil];
    }
    
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

-(BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID inManagedObjectContext:(NSManagedObjectContext *)context {
    return YES;
}

//-(BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID inManagedObjectContext:(NSManagedObjectContext *)context {
//    return YES;
//}

@end
