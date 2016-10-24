//
//  SWPhotoView.h
//  AiBa
//
//  Created by Stan Wu on 12-11-1.
//
//

#import <UIKit/UIKit.h>

@protocol SWPhotoViewDelegate

@optional
- (void)photoDownloadFailed;

@end

@interface SWPhotoView : UIView<NSURLConnectionDataDelegate>{
    UIScrollView *scvBG;
    UIImageView *imgvPhoto;
    UIProgressView *progressBar;
    UILabel *lblProgress;
    
    NSDictionary *dicInfo;
    NSMutableData *dataImage;
    long long llFileSize,llDownloadedSize;
    BOOL bBigPhotoShowed,bLoadingImage;
}
@property (nonatomic,strong) NSDictionary *dicInfo;
@property (nonatomic,strong) NSMutableData *dataImage;

@property (nonatomic,weak) id<SWPhotoViewDelegate> delegate;

- (void)loadBigPhoto;

@end
