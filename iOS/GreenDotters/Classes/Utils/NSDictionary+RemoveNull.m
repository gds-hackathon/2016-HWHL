//
//  NSDictionary+RemoveNull.m
//  Mosaic
//
//  Created by yywang on 14-7-23.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "NSDictionary+RemoveNull.h"

@implementation NSDictionary (RemoveNull)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (id)objectForKey:(id)aKey{
    NSLog(@"^^^^^^^");
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSString class]] && ([obj isEqual:[NSNull null]] || [obj isEqualToString:@"<null>"])) {
        NSLog(@"^^^^^^^%@",obj);
        return @"";
    }
    return obj;
}

#pragma clang diagnostic pop

@end
