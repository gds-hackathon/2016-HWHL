//
//  NSData+Base128.h
//  Mosaic
//
//  Created by Stan Wu on 14-5-3.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base128)

- (NSData *)base128DecodedData;
- (NSData *)base128EncodedData;

@end
