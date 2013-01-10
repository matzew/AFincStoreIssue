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


- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
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


@end
