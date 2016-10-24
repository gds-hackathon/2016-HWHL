//
//  CustomLabel.h
//  AttrubitedLabelDemo
//
//  Created by leejan97 on 13-12-19.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#define kTouchTextAttribute @"TouchTextAttribute"
@class CustomLabel;
@protocol CustomLabelDelegate<NSObject>
- (void)attributedTextView:(CustomLabel *)view touchBegin:(NSString *)text;
- (void)attributedTextView:(CustomLabel *)view touchEnd:(NSString *)text;
@end

@interface CustomLabel : UILabel
{
    
}
@property (nonatomic, retain) NSMutableAttributedString *attString;
@property (nonatomic, weak) id<CustomLabelDelegate> delegate;

//set text color
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length;

//set text font
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length;

//set text style
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length;

@end
