//
//  CVPageControlView.m
//  CapitalValDemo
//
//  Created by leon on 10-8-23.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import "CVPageControlView.h"

@interface CVPageControlView()

- (void)changeIconImage:(NSInteger)page;

@end


@implementation CVPageControlView

@synthesize pageControlStyle;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		pageControlStyle = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (1 == pageControlStyle) {
		[self changeIconImage:0];
	}
}
 

- (void)changeIconImage:(NSInteger)page {
	for (int i=0; i<self.numberOfPages; i++) {
		UIImageView *pageIcon = [self.subviews objectAtIndex:i];
//        [pageIcon setImage:nil];
        pageIcon.layer.cornerRadius = pageIcon.frame.size.width/2;
		if (i==page) {
            pageIcon.backgroundColor = 0==pageControlStyle?[UIColor whiteColor]:[UIColor blackColor];
            pageIcon.layer.borderWidth = 0;
        }
        else {
            pageIcon.backgroundColor = [UIColor clearColor];
            pageIcon.layer.borderColor = 0==pageControlStyle?[UIColor whiteColor].CGColor:[UIColor blackColor].CGColor;
            pageIcon.layer.borderWidth = pageIcon.frame.size.width*.2f;
        }
	}
}

- (void)setCurrentPage:(NSInteger)page {
	[super setCurrentPage:page];
    [self changeIconImage:page];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//	NSLog(@"gbgbgb");
//}




@end
