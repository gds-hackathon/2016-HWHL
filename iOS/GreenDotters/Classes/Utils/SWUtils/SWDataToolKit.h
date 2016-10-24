//
//  SWDataToolKit.h
//  SWToolKit
//
//  Created by Wu Stan on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark -
#pragma mark NSDictionary Extensions
//@interface NSDictionary(CoreTextExtension)
//
//- (CGSize)sizeOf;
//
//@end
#define InAiBa

#pragma mark -
#pragma mark NSString Extensions
@interface NSString(SWExtensions)

//- (CGSize)sizeWithFont:(UIFont *)font width:(CGFloat)width;
- (NSString *)documentPath;
- (NSString *)temporaryPath;
- (NSString *)imageCachePath;
- (NSString *)bundlePath;
- (NSString *)mediaCachePath;
- (NSString *)fileName;
- (int)indexInString:(NSString *)str;
- (NSMutableArray *)indexesInString:(NSString *)str;
- (NSString *)stringByResolvingEmotions;
- (CGFloat)heightForPM;


-(NSString *)URLEncode;
- (BOOL)isValidEmailAddress;

+ (NSString *)UUIDString;
+(NSString *)MACAddress;
- (NSString *)HMACSHA1StringWithKey:(NSString *)key;
- (NSData *)HMACSHA1WithKey:(NSString *)key;

#ifdef InAiBa

+ (NSString *)areaForInfo:(NSDictionary *)info;
+ (NSString *)stringWithInfo:(NSDictionary *)info;
+ (NSString *)stringWithInfo:(NSDictionary *)info seperator:(NSString *)seperator withGender:(BOOL)with;

#endif

- (NSString *)simplifiedChinese;
- (NSString *)traditionalChinese;

@end

@interface NSArray(SWExtensions)

- (BOOL)shouldLoadMore;
- (BOOL)shouldLoadMoreByPageLimit:(NSUInteger)pageLimit;

@end

#define kContentFont        [UIFont systemFontOfSize:14]
#define kPMFont             [UIFont systemFontOfSize:15]
#define kPMCellContentWidth     (ScreenWidth-155.0)

@interface NSDictionary (NSDictionary_Extensions)

- (CGFloat)heightForPM;
- (NSString *)htmlString;
- (NSString *)dateString;
- (NSString *)fileId;

@end


@interface NSDate(SWExtensions)

- (NSString *)dateString;
- (NSString *)animalString;

@end

@interface NSData(SWExtensions)

- (NSString *)SHA1String;
- (NSString *)MD5String;


@end

@interface NSObject(SWExtensions)

+ (id)simplifiedChinese:(id)input;
+ (id)traditionalChinese:(id)input;
+ (void)registerRemoteNotifications;

@end


