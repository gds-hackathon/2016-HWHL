//
//  CVScrollPageViewController.h
//  CapitalVueHD
//
//  Created by jishen on 9/4/10.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CVPageControlView.h"

#define CVSCROLLPAGE_INDICTOR_WIDTH  150
#define CVSCROLLPAGE_INDICTOR_HEIGHT 18

@protocol CVScrollPageViewDeleage

//- (NSUInteger)numberOfPagesInScrollPageView;
- (UIView *)scrollPageView:(id)scrollPageView viewForPageAtIndex:(NSUInteger)index;
- (void)didScrollToPageAtIndex:(NSUInteger)index;
@end

enum pageIndicatorStyle {
	CVScrollPageIndicatorStyleLight,
	CVScrollPageIndicatorStyleHigh
};

@interface CVScrollPageViewController : UIViewController <UIScrollViewDelegate> {
	id<CVScrollPageViewDeleage> __weak pageViewDelegate;
	NSUInteger pageCount;
	UIScrollView *scrollView;
	NSUInteger indicatorStyle;
	CVPageControlView *pageControl;
@private
	CGRect _frame;
	CGRect _pageControlFrame;
	
    NSMutableArray *viewControllers;
	NSMutableArray *arrayViewCache;
	
	// FIXME, cacheIndex should moved;
	NSUInteger cacheSize;
	NSUInteger cacheIndex;
	
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect pageControlFrame;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic) NSUInteger indicatorStyle;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) CVPageControlView *pageControl;

- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (void)enqueueReusablePage:(UIView *)pageView atIndex:(NSUInteger)index;
- (UIView *)dequeueReusablePage:(NSUInteger)index;
- (void)clearReusablePage;

@end
