//
//  MyIncStoreClient.h
//  AFincStoreIssue
//
//  Created by Matthias Wessendorf on 1/10/13.
//  Copyright (c) 2013 Matthias Wessendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFRESTClient.h"
#import "AFIncrementalStore.h"


@interface MyIncStoreClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (MyIncStoreClient *) clientFor:(NSURL *)baseURL;

@end
