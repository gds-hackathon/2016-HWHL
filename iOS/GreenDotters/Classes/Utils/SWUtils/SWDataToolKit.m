//
//  SWDataToolKit.m
//  SWToolKit
//
//  Created by Wu Stan on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWDataToolKit.h"
#import "SWUIToolKit.h"
#import <CoreText/CoreText.h>
#import <CommonCrypto/CommonCrypto.h>
#import "GreenDotters-Swift.h"
#import <AdSupport/AdSupport.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "VXHanConvert.h"

@implementation NSString(SWExtensions)




- (NSString *)imageCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *imagesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"images"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ImageDirectoryExcluded"]){
        NSURL *url = [NSURL fileURLWithPath:imagesPath];
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if (success)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ImageDirectoryExcluded"];
    }
    
    NSString *path = [imagesPath stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)temporaryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *tmpPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"tmp"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TmpDirectoryExcluded"]){
        NSURL *url = [NSURL fileURLWithPath:tmpPath];
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if (success)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TmpDirectoryExcluded"];
    }
    

    NSString *path = [tmpPath stringByAppendingPathComponent:self];
    

    
    return path;
}

- (NSString *)bundlePath{
    NSString *path = [[NSBundle mainBundle] pathForResource:self ofType:nil];
    
    return path;
}

- (NSString *)mediaCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *imagesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"medias"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"MediaDirectoryExcluded"]){
        NSURL *url = [NSURL fileURLWithPath:imagesPath];
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if (success)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MediaDirectoryExcluded"];
    }
    
    NSString *path = [imagesPath stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)fileName{
    NSArray *ary = [self componentsSeparatedByString:@"/"];
    NSMutableString *fileName = [NSMutableString string];
    
    for (int i=0;i<[ary count];i++)
        [fileName appendString:[ary objectAtIndex:i]];
    
    return fileName;
}

- (int)indexInString:(NSString *)str{
    int dret = -1;
    NSArray *ary = [str componentsSeparatedByString:@","];
    for (int i=0;i<ary.count;i++){
        if ([self isEqualToString:[ary objectAtIndex:i]])
            dret = i;
    }
    
    return dret;
}

- (NSMutableArray *)indexesInString:(NSString *)str{
    NSArray *ary = [self componentsSeparatedByString:@","];
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<ary.count;i++){
        NSString *substr = [ary objectAtIndex:i];
        
        [mut addObject:[NSNumber numberWithInt:[substr indexInString:str]]];
    }
    
    return mut;
}

- (NSString *)stringByResolvingEmotions{
    NSString *result = self;

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]"
                                                                      options:0
                                                                        error:nil];
    NSDictionary *emotionsMap = [NSDictionary dictionaryWithContentsOfFile:[@"SWToolKit.bundle/Emoticons/EmoticonsMap.plist" bundlePath]];
    NSArray *chunks = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    for (int i=(int)chunks.count-1;i>=0;i--){
        NSTextCheckingResult *chunk = [chunks objectAtIndex:i];
        int total = (int)chunk.numberOfRanges;
        for (int j=total-1;j>=0;j--){
            NSRange range = [chunk rangeAtIndex:j];
            
            NSString *mark = [self substringWithRange:range];
            NSString *img = [NSString stringWithFormat:@"<img src=\"SWToolKit.bundle/Emoticons/images/%@.png\">",[[emotionsMap objectForKey:@"name"] objectForKey:mark]];
            result = [result stringByReplacingOccurrencesOfString:mark withString:img];
        }
    }
        
    return result;
}

-(NSString *)URLEncode
{
    NSMutableString *mutstr = [NSMutableString string];
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    const unsigned char *a = data.bytes;
//    const unsigned char *a = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger len = data.length;
    
    for (int i=0;i<len;i++){
        unsigned char c = a[i];
        if ((c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9') || c=='.' || c=='-')
            [mutstr appendFormat:@"%c",c];
        else
            [mutstr appendFormat:@"%%%02x",(unsigned int)c];
    }
    
    return mutstr;
    
	NSString *str = nil;
    //	$entities = array('%21', '%2A', '%27', '%28', '%29', '%3B', '%3A', '%40', '%26', '%3D', '%2B', '%24', '%2C', '%2F', '%3F', '%25', '%23', '%5B', '%5D');
    //	$replacements = array('!', '*', "'", "(", ")", ";", ":", "@", "&", "=", "+", "$", ",", "/", "?", "%", "#", "[", "]");
	NSArray *replaceArray = [NSArray arrayWithObjects:@"!",@"*",@"'",@"(",@")",@";",@":",@"@",@"&",@"=",@"+",@"$",@",",@"/",@"?",@"%",@"#",@"[",@"]",@" ",@"\"",nil];
	NSArray *codeArray = [NSArray arrayWithObjects:@"%21",@"%2A",@"%27",@"%28",@"%29",@"%3B",@"%3A",@"%40",@"%26",@"%3D",
						  @"%2B",@"%24",@"%2C",@"%2F",@"%3F",@"%25",@"%23",@"%5B",@"%5D",@"%20",@"%22",nil];
    //	NSLog(@"decoded:%@",self);
	str = [self stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:15] withString:[codeArray objectAtIndex:15]];
	for(int i=0;i<21;i++)
	{
		if(15!=i)
			str = [str stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:i] withString:[codeArray objectAtIndex:i]];
	}
    
    //	NSLog(@"encoded:%@",str);
	return str;
}

- (BOOL)isValidEmailAddress{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}


+ (NSString *)UUIDString{
    NSString *UUID = nil;
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(identifierForVendor)])
        UUID = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    else{
        UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
        if (!UUID){
            CFUUIDRef uuidref = CFUUIDCreate(NULL);
            CFStringRef uuidstr = CFUUIDCreateString(NULL, uuidref);
            UUID = (__bridge_transfer NSString *)uuidstr;
            CFRelease(uuidref);
            [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:@"UUID"];
        }
    }

    return UUID;
}



+(NSString *)MACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
    
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    // Error...
    NSLog(@"Get Mac Address Failed:%@",errorFlag);
    return nil;
}

- (NSString *)HMACSHA1StringWithKey:(NSString *)key{
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
    NSData *keydata = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *selfdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, [keydata bytes], [key length], [selfdata bytes], [selfdata length], result);
    
    NSMutableString *str = [NSMutableString string];

    for (int i=0;i<CC_SHA1_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}

- (NSData *)HMACSHA1WithKey:(NSString *)key{
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
    NSData *keydata = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *selfdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, [keydata bytes], [key length], [selfdata bytes], [selfdata length], result);
        
    NSData *data = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    
    return data;
}

#ifdef InAiBa

+ (NSString *)areaForInfo:(NSDictionary *)info{
    int dProvince = [[info objectForKey:@"province"] intValue];
    int dCity = [[info objectForKey:@"city"] intValue];
    NSDictionary *dicProfilePlist = [MDataProvider profilePlist];
    NSArray *arycities = [dicProfilePlist objectForKey:@"cities"];
    NSArray *aryprovinces = [dicProfilePlist objectForKey:@"provinces"];
    NSString *strprovince = [aryprovinces objectAtIndex:dProvince];
    NSString *strcity = [arycities objectAtIndex:dCity];
    if (0==dCity || [strprovince isEqualToString:NSLocalizedString(@"北京", @"北京")] || [strprovince isEqualToString:NSLocalizedString(@"上海", @"上海")] || [strprovince isEqualToString:NSLocalizedString(@"天津", @"天津")] || [strprovince isEqualToString:NSLocalizedString(@"重庆", @"重庆")])
        strcity = @"";
    
    return [strprovince stringByAppendingString:strcity];
}

+ (NSString *)originAreaForInfo:(NSDictionary *)info{
    int dProvince = [[info objectForKey:@"origin_province"] intValue];
    int dCity = [[info objectForKey:@"origin_city"] intValue];
    NSDictionary *dicProfilePlist = [MDataProvider profilePlist];
    NSArray *arycities = [dicProfilePlist objectForKey:@"cities"];
    NSArray *aryprovinces = [dicProfilePlist objectForKey:@"provinces"];
    NSString *strprovince = [aryprovinces objectAtIndex:dProvince];
    NSString *strcity = [arycities objectAtIndex:dCity];
    if (0==dCity || [strprovince isEqualToString:NSLocalizedString(@"北京", @"北京")] || [strprovince isEqualToString:NSLocalizedString(@"上海", @"上海")] || [strprovince isEqualToString:NSLocalizedString(@"天津", @"天津")] || [strprovince isEqualToString:NSLocalizedString(@"重庆", @"重庆")])
        strcity = @"";
    
    return [strprovince stringByAppendingString:strcity];
}

+ (NSString *)stringWithInfo:(NSDictionary *)info{

    
    return [NSString stringWithInfo:info seperator:@" " withGender:NO];
    
}

+ (NSString *)stringWithInfo:(NSDictionary *)info seperator:(NSString *)seperator withGender:(BOOL)with{
    NSMutableArray *ary = [NSMutableArray array];
    
    int dgender = [[info objectForKey:@"gender"] intValue];
    NSString *gender = 1==dgender?NSLocalizedString(@"男", @"男"):(2==dgender?NSLocalizedString(@"女", @"女"):nil);
    if (with && gender)
        [ary addObject:gender];
    
    int province = [[info objectForKey:@"province"] intValue];
    if (province>0)
        [ary addObject:[NSString areaForInfo:info]];
    
    int height = [[info objectForKey:@"height"] intValue];
    if (height>0)
        [ary addObject:[NSString stringWithFormat:@"%dcm",height]];
    
    NSDictionary *dicProfile = [MDataProvider profilePlist];
    int education = [[info objectForKey:@"education"] intValue];
    if (education>0)
        [ary addObject:[[dicProfile objectForKey:@"education"] objectAtIndex:education]];
    
    
    NSMutableString *str = [NSMutableString string];
    for (int i=0;i<ary.count;i++){
        if (0!=i)
            [str appendFormat:@" %@ ",seperator];
        
        [str appendString:[ary objectAtIndex:i]];
    }
    
    return str;

}

#endif


- (NSString *)simplifiedChinese{
    NSString *input = self;
    if (![input length]) {
        return input;
    }
    
    NSUInteger length = [input length];
    unichar *chars = (unichar *)calloc(length, sizeof(unichar));
    if (chars) {
        [input getCharacters:chars range:NSMakeRange(0, length)];
        for (NSUInteger i = 0; i < length; i++) {
            unichar f = VXUCS2TradToSimpChinese(chars[i]);
            if (f) {
                chars[i] = f;
            }
        }
        
        NSString *output = [[NSString alloc] initWithCharacters:chars length:length];
        free(chars);
        return output;
    }
    
    
    return input;
}

- (NSString *)traditionalChinese{
    NSString *input = self;
    if (![input length]) {
        return input;
    }
    
    NSUInteger length = [input length];
    unichar *chars = (unichar *)calloc(length, sizeof(unichar));
    if (chars) {
        [input getCharacters:chars range:NSMakeRange(0, length)];
        for (NSUInteger i = 0; i < length; i++) {
            unichar f = VXUCS2SimpToTradChinese(chars[i]);
            if (f) {
                chars[i] = f;
            }
        }
        
        NSString *output = [[NSString alloc] initWithCharacters:chars length:length];
        free(chars);
        return output;
    }
    
    
    return input;
}

@end



@implementation NSArray(SWExtensions)

- (BOOL)shouldLoadMore{
    return [self shouldLoadMoreByPageLimit:20];
}

- (BOOL)shouldLoadMoreByPageLimit:(NSUInteger)pageLimit{
    return (self.count>0 && 0==self.count%pageLimit);
}

@end


@implementation NSDictionary (NSDictionary_Extensions)




- (NSString *)addUrl:(NSString *)strText{
    NSString *result = strText;
    
    //    NSArray *ary = [strText componentsSeparatedByString:@"@"];
    
    NSString *substring = strText;
    
    NSRange range;
    
    while ([substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location!=NSNotFound) {
        range = [substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        if (range.location<[strText length]-7){
            substring = [substring substringFromIndex:range.location+7];
            NSString *strUrl = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            
            int cnindex = 0;
            for (int i=0;i<[strUrl length];i++){
                if ([strUrl characterAtIndex:i]>128){
                    cnindex = i;
                    break;
                }
            }
            
            if (cnindex!=0)
                strUrl = [strUrl substringToIndex:cnindex];
            
            
            
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://%@",strUrl] withString:@"shoturl" options:NSCaseInsensitiveSearch range:NSRangeFromString([NSString stringWithFormat:@"{0,%d}",(int)[result length]])];
            result = [result stringByReplacingOccurrencesOfString:@"shoturl"  withString:[NSString stringWithFormat:@"<a href='web://%@'>http://%@</a>",[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strUrl]];
        }
        else
            break;
    }
    
    substring = result;
    while ([substring rangeOfString:@"@"].location!=NSNotFound) {
        range = [substring rangeOfString:@"@"];
        if (range.location<[strText length]-1){
            substring = [substring substringFromIndex:range.location+1];
            NSString *strAt = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",strAt] withString:@"atsomeone"];
            result = [result stringByReplacingOccurrencesOfString:@"atsomeone"  withString:[NSString stringWithFormat:@"<a href='profile://aiba.com/%@'>@%@</a>",[strAt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strAt]];
        }else
            break;
    }
    
    return result;
}

- (NSString *)dateString{
    NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[[self objectForKey:@"dateline"] doubleValue]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:created_date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:created_date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"HH:mm"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:created_date];
        if (timeInterval<0)
            timeInterval = 0;
        if (timeInterval>3600){
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"今天", @"今天"),strDate];
        }
        else{
            strDate = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", @"%d分钟前"),(int)(timeInterval/60)];
        }
    }else {
        [formatter setDateFormat:@"yyyy-MM-dd 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:created_date]<3600*24){
            [formatter setDateFormat:@"HH:mm"];
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"昨天", @"昨天"),strDate];
        }else{
            [formatter setDateFormat:@"yyyy"];
            date1 = [formatter stringFromDate:created_date];
            date2 = [formatter stringFromDate:[NSDate date]];
            
            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"MM-dd HH:mm"];
                strDate = [formatter stringFromDate:created_date];
            }
        }
    }
    
    
    return strDate;
}

- (NSString *)htmlString{
    NSDictionary *origin = self;
    
    BOOL bRetweet = (BOOL)[self objectForKey:@"origin"];
    NSDictionary *retweet = nil;
    //    bRetweet = NO;
    if (bRetweet){
        //        NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
        //        for (NSString *key in self.allKeys){
        //            if ([key rangeOfString:@"origin"].location!=NSNotFound){
        //                NSString *newkey = [key stringByReplacingOccurrencesOfString:@"origin" withString:@""];
        //                newkey = [newkey stringByReplacingOccurrencesOfString:@"_" withString:@""];
        //                [mutdict setObject:[self objectForKey:key] forKey:newkey];
        //            }
        //        }
        //        if ([mutdict.allKeys count]>0)
        //            retweet = [NSDictionary dictionaryWithDictionary:mutdict];
        retweet = [self objectForKey:@"origin"];
    }
    
    NSString *strSource = [[self objectForKey:@"platform"] intValue]<=1?NSLocalizedString(@"来自网页版", @"来自网页版"):([[self objectForKey:@"platform"] intValue]==2?NSLocalizedString(@"来自iPhone客户端", @"来自iPhone客户端"):NSLocalizedString(@"来自Android客户端", @"来自Android客户端"));
    NSMutableString *strMut = [NSMutableString string];
    if (retweet){
        //original text
        [strMut appendFormat:@"<div class=\"content_text\">%@</div>",[self addUrl:[origin objectForKey:@"content"]]];
        [strMut appendString:@"<div class=\"pop_top\"></div><div class=\"pop_middle\">"];
        //retweet text
        [strMut appendString:[self addUrl:[NSString stringWithFormat:@"@%@:%@",[retweet objectForKey:@"nickname"],[retweet objectForKey:@"content"]]]];
        //retweet image
        if ([retweet objectForKey:@"picture"] && [[retweet objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"> <img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";' src=\"%@\" /></span></a></div>",[[retweet objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[retweet objectForKey:@"picture"]];
        [strMut appendString:@"</div><div class=\"pop_bottom\"></div><p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }else{
        [strMut appendString:[self addUrl:[origin objectForKey:@"content"]]];
        if ([origin objectForKey:@"picture"] && [[origin objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"><img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";'  src=\"%@\" /></span></a></div>",[[origin objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[origin objectForKey:@"picture"]];
        [strMut appendString:@"<p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"detail.html" ofType:nil];
    NSString *strDetail = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *ret = [NSString stringWithFormat:strDetail,strMut];
    
    return ret;
    
}

- (NSString *)fileId{
    NSString *fileid = [self objectForKey:@"fileid"];
    if (fileid && fileid.length>0)
        return fileid;
    else
        return nil;
}


@end



@implementation NSDate(SWExtensions)

- (NSString *)dateString{
    NSDate *created_date = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:created_date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:created_date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"HH:mm"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self];
        if (timeInterval<0)
            timeInterval = 0;
        if (timeInterval>3600){
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"今天", @"今天"),strDate];
        }
        else{
            strDate = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", @"%d分钟前"),(int)(timeInterval/60)];
        }
    }else {
        [formatter setDateFormat:@"yyyy-MM-dd 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:created_date]<3600*24){
            [formatter setDateFormat:@"HH:mm"];
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"昨天", @"昨天"),strDate];
        }else{
            [formatter setDateFormat:@"yyyy"];
            date1 = [formatter stringFromDate:created_date];
            date2 = [formatter stringFromDate:[NSDate date]];
            
            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"MM-dd HH:mm"];
                strDate = [formatter stringFromDate:created_date];
            }
        }
    }
    
    
    return strDate;
}

- (NSString *)animalString{
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:NSLocalizedString(@"鼠", @"鼠"),NSLocalizedString(@"牛", @"牛"),NSLocalizedString(@"虎", @"虎"),NSLocalizedString(@"兔", @"兔"),NSLocalizedString(@"龙", @"龙"),NSLocalizedString(@"蛇", @"蛇"),NSLocalizedString(@"马", @"马"),NSLocalizedString(@"羊", @"羊"),NSLocalizedString(@"猴", @"猴"),NSLocalizedString(@"鸡", @"鸡"),NSLocalizedString(@"狗", @"狗"),NSLocalizedString(@"猪", @"猪"),nil];

    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static NSInteger wCurYear,wCurMonth,wCurDay;
    static NSInteger nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    
    return szShuXiang;
}

-(NSString *)LunarForSolar:(NSDate *)solarDate{
    //天干名称
    NSArray *cTianGan = [NSArray arrayWithObjects:NSLocalizedString(@"甲", @"甲"),NSLocalizedString(@"乙", @"乙"),NSLocalizedString(@"丙", @"丙"),NSLocalizedString(@"丁", @"丁"),NSLocalizedString(@"戊", @"戊"),NSLocalizedString(@"己", @"己"),NSLocalizedString(@"庚", @"庚"),NSLocalizedString(@"辛", @"辛"),NSLocalizedString(@"壬", @"壬"),NSLocalizedString(@"癸", @"癸"), nil];
    
    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:NSLocalizedString(@"子", @"子"),NSLocalizedString(@"丑", @"丑"),NSLocalizedString(@"寅", @"寅"),NSLocalizedString(@"卯", @"卯"),NSLocalizedString(@"辰", @"辰"),NSLocalizedString(@"巳", @"巳"),NSLocalizedString(@"午", @"午"),NSLocalizedString(@"未", @"未"),NSLocalizedString(@"申", @"申"),NSLocalizedString(@"酉", @"酉"),NSLocalizedString(@"戌", @"戌"),NSLocalizedString(@"亥", @"亥"),nil];
    
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:NSLocalizedString(@"鼠", @"鼠"),NSLocalizedString(@"牛", @"牛"),NSLocalizedString(@"虎", @"虎"),NSLocalizedString(@"兔", @"兔"),NSLocalizedString(@"龙", @"龙"),NSLocalizedString(@"蛇", @"蛇"),NSLocalizedString(@"马", @"马"),NSLocalizedString(@"羊", @"羊"),NSLocalizedString(@"猴", @"猴"),NSLocalizedString(@"鸡", @"鸡"),NSLocalizedString(@"狗", @"狗"),NSLocalizedString(@"猪", @"猪"),nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",NSLocalizedString(@"初一", @"初一"),NSLocalizedString(@"初二", @"初二"),NSLocalizedString(@"初三", @"初三"),NSLocalizedString(@"初四", @"初四"),NSLocalizedString(@"初五", @"初五"),NSLocalizedString(@"初六", @"初六"),NSLocalizedString(@"初七", @"初七"),NSLocalizedString(@"初八", @"初八"),NSLocalizedString(@"初九", @"初九"),NSLocalizedString(@"初十", @"初十"),
                         NSLocalizedString(@"十一", @"十一"),NSLocalizedString(@"十二", @"十二"),NSLocalizedString(@"十三", @"十三"),NSLocalizedString(@"十四", @"十四"),NSLocalizedString(@"十五", @"十五"),NSLocalizedString(@"十六", @"十六"),NSLocalizedString(@"十七", @"十七"),NSLocalizedString(@"十八", @"十八"),NSLocalizedString(@"十九", @"十九"),NSLocalizedString(@"二十", @"二十"),
                         NSLocalizedString(@"廿一", @"廿一"),NSLocalizedString(@"廿二", @"廿二"),NSLocalizedString(@"廿三", @"廿三"),NSLocalizedString(@"廿四", @"廿四"),NSLocalizedString(@"廿五", @"廿五"),NSLocalizedString(@"廿六", @"廿六"),NSLocalizedString(@"廿七", @"廿七"),NSLocalizedString(@"廿八", @"廿八"),NSLocalizedString(@"廿九", @"廿九"),NSLocalizedString(@"三十", @"三十"),nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",NSLocalizedString(@"正", @"正"),NSLocalizedString(@"二", @"二"),NSLocalizedString(@"三", @"三"),NSLocalizedString(@"四", @"四"),NSLocalizedString(@"五", @"五"),NSLocalizedString(@"六", @"六"),NSLocalizedString(@"七", @"七"),NSLocalizedString(@"八", @"八"),NSLocalizedString(@"九", @"九"),NSLocalizedString(@"十", @"十"),NSLocalizedString(@"十一", @"十一"),NSLocalizedString(@"腊", @"腊"),nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static NSInteger wCurYear,wCurMonth,wCurDay;
    static NSInteger nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:solarDate];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    NSString *szNongli = [NSString stringWithFormat:NSLocalizedString(@"%@(%@%@)年", @"%@(%@%@)年"),szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];
    
    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:NSLocalizedString(@"闰%@", @"闰%@"),(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    }
    else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth];
    }
    
    NSString *lunarDate = [NSString stringWithFormat:NSLocalizedString(@"%@ %@月 %@", @"%@ %@月 %@"),szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}


@end



@implementation NSData(SWExtensions)

- (NSString *)SHA1String{
    if (!self)
        return nil;
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1([self bytes], (unsigned int)self.length, result);
    
    NSMutableString *str = [NSMutableString string];
    
    for (int i=0;i<CC_SHA1_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}

- (NSString *)MD5String{
    if (!self)
        return nil;
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], (unsigned int)self.length, result);
    
    NSMutableString *str = [NSMutableString string];
    
    for (int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}



@end

@implementation NSObject(SWExtensions)

+ (id)simplifiedChinese:(id)input{
    if ([input isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:input];
        for (NSString *key in mut.allKeys){
            id ret = [NSObject simplifiedChinese:[mut objectForKey:key]];
            [mut setObject:ret forKey:key];
        }
        
        return mut;
    }else if ([input isKindOfClass:[NSArray class]]){
        NSMutableArray *mut = [NSMutableArray arrayWithArray:input];
        for (id obj in input){
            [mut replaceObjectAtIndex:[input indexOfObject:obj] withObject:[NSObject simplifiedChinese:obj]];
        }
        
        return mut;
    }else if ([input isKindOfClass:[NSString class]]){
        return [input simplifiedChinese];
    }else
        return input;
}

+ (id)traditionalChinese:(id)input{
    if ([input isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:input];
        for (NSString *key in mut.allKeys){
            id ret = [NSObject traditionalChinese:[mut objectForKey:key]];
            [mut setObject:ret forKey:key];
        }
        
        return mut;
    }else if ([input isKindOfClass:[NSArray class]]){
        NSMutableArray *mut = [NSMutableArray arrayWithArray:input];
        for (id obj in input){
            [mut replaceObjectAtIndex:[input indexOfObject:obj] withObject:[NSObject traditionalChinese:obj]];
        }
        
        return mut;
    }else if ([input isKindOfClass:[NSString class]]){
        return [input traditionalChinese];
    }else
        return input;
}

+ (void)registerRemoteNotifications{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysVer < 8){
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    else{
        //Types
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
//        //Actions
//        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
//        
//        acceptAction.identifier = @"ACCEPT_IDENTIFIER";
//        acceptAction.title = @"Accept";
//        
//        acceptAction.activationMode = UIUserNotificationActivationModeForeground;
//        acceptAction.destructive = NO;
//        acceptAction.authenticationRequired = NO;
//        
//        //Categories
//        UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
//        
//        inviteCategory.identifier = @"INVITE_CATEGORY";
//        
//        [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
//        
//        [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
//        
//        NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
        
        
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#else
    //iOS8之前注册push方法
    //注册Push服务，注册后才能收到推送
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
}

@end
