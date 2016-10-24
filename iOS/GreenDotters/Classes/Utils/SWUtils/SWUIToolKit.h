//
//  SWUIToolKit.h
//  Nurse
//
//  Created by Wu Stan on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


#pragma mark -
#pragma mark Definations
#define kNavBGName      @""


#pragma mark -  UILabel Category
@interface UILabel(SWUIToolKit)

+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font;
+ (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)color;

@end








#pragma mark -
#pragma mark UIImage Category
@interface UIImage(SWUIToolKit)

- (UIImage *)fixOrientation;
- (UIImage *)resizedImage:(CGSize)newSize;
- (UIImage *)croppedImage:(CGRect)area;
- (BOOL)hasFace;

@end


#pragma mark -
#pragma mark SWNavigationViewController

@interface SWNavigationViewController : UINavigationController<UINavigationControllerDelegate> {
    BOOL bShowTabBar;
}

@property BOOL bShowTabBar;

@end

@interface UINavigationBar (UINavigationBar_CustomBG)

@end


#pragma mark -
#pragma mark SWLabel
@interface SWLabel : UIView{
    NSString *strText;
    UIFont *fontLabel;
    UIColor *textColor;
    CGSize contentSize;
}
@property (nonatomic,copy) NSString *text;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic) float lineBreak;
@property (nonatomic) int numberOfLines;

- (void)sizeToFit;

@end




#pragma mark -  UIAlertView Extensions
@interface UIAlertView(SWExtensions)

+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel;
+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate;
+ (void)showAlertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel;
+ (UIAlertView *)alertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate;
+ (UIAlertView *)alertWithTitle:(NSString *)strtitle message:(NSString *)strmessage cancelButton:(NSString *)strcancel delegate:(id<UIAlertViewDelegate>)alertdelegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end


#pragma mark - UIImage Extensions
@interface UIImage(SWExtensions)

- (UIImage *)normalizedImage;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end


#pragma mark - SWEmoticonsKeyboard



#pragma mark - Custom Corner Radius TableView Cell and TableView
typedef enum{
    SWCCCellTypeTop = 1,
    SWCCCellTypeMiddle,
    SWCCCellTypeBottom,
    SWCCCellTypeSingle
}SWCCCellType;

@interface SWCCTableViewCell:UITableViewCell{
    UIImageView *lineTop,*lineBottom;
    
    SWCCCellType cellType;
    float fTitlePadding;
    BOOL bAnimated;
    NSIndexPath *indexPath;
    UIColor *seperatorColor;
}
@property float fTitlePadding;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) UIColor *seperatorColor;
@end

@interface SWRoundedCell:UITableViewCell{
    UIImageView *lineTop,*lineBottom;
    CAShapeLayer *shapeLayer;
    
    SWCCCellType cellType;
    BOOL bAnimated;
    NSIndexPath *indexPath;
}
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) UIColor *strokeColor,*fillColor;
@property (nonatomic) float cornerRadius,padding;

@end

@interface UIView(SWExtensions)

+ (UIView *)noDataTipsForTableView:(UITableView *)tableView target:(id)target;

@end
