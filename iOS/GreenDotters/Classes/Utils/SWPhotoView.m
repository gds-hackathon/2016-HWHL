//
//  SWPhotoView.m
//  AiBa
//
//  Created by Stan Wu on 12-11-1.
//
//

#import "SWPhotoView.h"
#import "SWToolKit.h"

@implementation SWPhotoView
@synthesize dicInfo,dataImage,delegate;

- (void)dealloc{
    self.dicInfo = nil;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scvBG = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scvBG];
        
        self.dataImage = [NSMutableData data];
        llDownloadedSize = 0;
        llFileSize = 0;
        
        imgvPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        imgvPhoto.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [scvBG addSubview:imgvPhoto];
        
        progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(60, imgvPhoto.frame.origin.y+200+30, ScreenWidth-120, 10)];
        progressBar.hidden = YES;
        [self addSubview:progressBar];
        
        lblProgress = [UILabel createLabelWithFrame:CGRectMake(60, progressBar.frame.origin.y+10+10, ScreenWidth-120, 14) font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        lblProgress.hidden = YES;
        lblProgress.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lblProgress];
    
    }
    return self;
}

- (void)showInfo:(NSDictionary *)dic{
    if (!dic){
        imgvPhoto.image = nil;
        return;
    }
//    NSLog(@"Image URL Info:%@",dic);
    NSString *path = [[[dic objectForKey:@"small_url"] fileName] imageCachePath];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [imgvPhoto setImage:img];
    
    progressBar.progress = 0;
    lblProgress.text = NSLocalizedString(@"正在载入  0K / 0K", @"正在载入  0K / 0K");
    progressBar.hidden = NO;
    lblProgress.hidden = NO;
    
    [self loadBigPhoto];
}

- (void)loadBigPhoto{
    if (!bBigPhotoShowed && !bLoadingImage){
        NSString *path = [[[dicInfo objectForKey:@"origin_url"] fileName] imageCachePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
            self.dataImage = [NSMutableData dataWithContentsOfFile:path];
            [self connectionDidFinishLoading:nil];
        }else{
            bLoadingImage = YES;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dicInfo objectForKey:@"origin_url"]]];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [connection start];
        }
    }
}

- (void)setDicInfo:(NSDictionary *)dic{
    if (dicInfo!=dic){
        dicInfo = dic;
        
        [self showInfo:dic];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    llDownloadedSize += data.length;
    [dataImage appendData:data];
    
    float fprogress = 0==llFileSize?0:(float)llDownloadedSize/(float)llFileSize;
    progressBar.progress = fprogress;
    lblProgress.text = [NSString stringWithFormat:NSLocalizedString(@"正在载入  %lldK / %lldK", @"正在载入  %lldK / %lldK"),llDownloadedSize/1024,llFileSize/1024];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Fail With Error:%@",error);
    bLoadingImage = NO;
    self.dataImage = [NSMutableData data];
    
    if ([(NSObject *)self.delegate respondsToSelector:@selector(photoDownloadFailed)])
        [self.delegate photoDownloadFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSLog(@"Finish  Loading");
    progressBar.hidden = YES;
    lblProgress.hidden = YES;
    UIImage *img = [UIImage imageWithData:dataImage];
    [imgvPhoto setImage:img];
    
    CGSize size = img.size;
    float w = size.width;
    float h = size.height;
    float W = ScreenWidth;
    
    float fw = w/W;
    h = h/fw;
    if (fw==0)
        h = 0;
    
    
    [scvBG setContentSize:CGSizeMake(ScreenWidth, MAX(h, scvBG.frame.size.height))];
    CGRect newframe = CGRectMake(0, (scvBG.contentSize.height-h)/2, ScreenWidth, h);
    
    [UIView animateWithDuration:0.5f animations:^{
        imgvPhoto.frame = newframe;
    }];
    bBigPhotoShowed = YES;
    bLoadingImage = NO;
    //save image

    NSString *path = [[[dicInfo objectForKey:@"origin_url"] fileName] imageCachePath];
    [dataImage writeToFile:path atomically:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
//        NSLog(@"Header Fields:%@",[(NSHTTPURLResponse *)response allHeaderFields]);
//        NSLog(@"Status Code %d:%@",[(NSHTTPURLResponse *)response statusCode],[NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse *)response statusCode]]);
    }
    
    llFileSize = response.expectedContentLength;
//    NSLog(@"Expected Content Length:%lld",response.expectedContentLength);
//    NSLog(@"Expected File Name:%@",response.suggestedFilename);
//    NSLog(@"URL:%@",response.URL);
//    NSLog(@"MIME Type:%@",response.MIMEType);
//    NSLog(@"Text Encoding Name:%@",response.textEncodingName);
    
}

@end
