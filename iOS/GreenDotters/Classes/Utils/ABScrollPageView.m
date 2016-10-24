    //
//  CVScrollPageViewController.m
//  CapitalVueHD
//
//  Created by jishen on 9/4/10.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import "ABScrollPageView.h"


@interface ABScrollPageView()

//@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *arrayViewCache;
@property (nonatomic) NSUInteger cacheIndex;
@property (nonatomic) NSUInteger cacheSize;


- (void)loadScrollViewWithPage:(NSInteger)index;
- (IBAction)changePage:(id)sender;

@end

@implementation ABScrollPageView

@synthesize pageControlFrame = _pageControlFrame;

@synthesize indicatorStyle;

@synthesize scrollView;
@synthesize pageControl;
@synthesize viewControllers;
@synthesize arrayViewCache;

@synthesize cacheIndex;
@synthesize cacheSize;

@synthesize disableZooming;

- (void)setPageCount:(NSUInteger)count{
    pageCount = count;
    CGSize size = [pageControl sizeForNumberOfPages:count];
    CGPoint pt = pageControl.center;
    pageControl.frame = CGRectMake(0, 0, size.width+12, 15);
    pageControl.center = pt;


}

- (NSUInteger)pageCount{
    return pageCount;
}

- (id)initWithFrame:(CGRect)frame{
	if ((self = [super initWithFrame:frame])) {
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.bounds];
		
		sv.autoresizingMask = UIViewAutoresizingNone;
		sv.autoresizesSubviews = NO;
		self.scrollView = sv;
		
		NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:1];
		self.arrayViewCache = views;
        
        self.autoresizesSubviews = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
        
        
        [self addSubview:scrollView];
        
        self.cacheIndex = 0;
        self.cacheSize = 0;
        // added page controll
        CVPageControlView *vpagecontrol = [[CVPageControlView alloc] init];
        self.pageControl = vpagecontrol;
        pageControl.pageControlStyle = indicatorStyle;
        [pageControl setFrame:_pageControlFrame];
        pageControl.backgroundColor = [UIColor clearColor];
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
        pageControl.frame = CGRectMake(320-65, 16, 40, 15);
//        pageControl.layer.cornerRadius = 6;
//        pageControl.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        pageControl.clipsToBounds = YES;
        


        



	}
	
	return self;
}

- (void)showPrevPage{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page>1)
        [self turnToPage:page-1];
}

- (void)showNextPage{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page<pageCount-1)
        [self turnToPage:page+1];
}


- (void)checkButton:(NSInteger)index{

    
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/






- (void)setPageControlFrame:(CGRect)pageControlFrame {
	_pageControlFrame = pageControlFrame;
	[pageControl setFrame:_pageControlFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}









#pragma mark private method
- (void)loadPage:(NSInteger)index{
    [self loadScrollViewWithPage:index-1];
    [self loadScrollViewWithPage:index];
    [self loadScrollViewWithPage:index+1];
//    for (int i=0;i<[arrayViewCache count];i++){
//        if (i<index-1 || i>index+1){
//            UIView *v = [arrayViewCache objectAtIndex:i];
//            if (![v isKindOfClass:[NSNull class]])
//                [v removeFromSuperview];
//            [arrayViewCache replaceObjectAtIndex:i withObject:[NSNull null]];
//        }
//            
////        else
////            [self loadScrollViewWithPage:i];
//    }
}

- (void)loadScrollViewWithPage:(NSInteger)index {
    if (index < 0) return;
    if (index >= pageCount) return;
	
	UIView *pageView;
	CGRect pageFrame = self.frame;
	pageFrame.origin.x = pageFrame.size.width * index;
	pageFrame.origin.y = 0;
	
	pageView = [self dequeueReusablePage:index];
	if (nil == pageView) {
		UIView *vContent = [pageViewDelegate scrollPageView:self viewForPageAtIndex:index];
        vContent.tag = 800;
        pageView = [[UIScrollView alloc] initWithFrame:self.scrollView.bounds];
        ((UIScrollView *)pageView).maximumZoomScale = self.disableZooming?1:5.0;
        ((UIScrollView *)pageView).minimumZoomScale = self.disableZooming?1:0.5;
        ((UIScrollView *)pageView).delegate = self;
        [pageView addSubview:vContent];
		[self enqueueReusablePage:pageView atIndex:index];
	}
	
	if (nil == pageView.superview) {
        if ([pageView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)pageView).zoomScale = 1.0;
        }
		pageView.frame = pageFrame;
		[self.scrollView addSubview:pageView];
	}
}

- (void)turnToPage:(NSInteger)page{

	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadPage:page];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
    [pageViewDelegate didScrollToPageAtIndex:page];
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadPage:page];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (sender == self.scrollView) {
        if (pageControlUsed) {
            // do nothing - the scroll was initiated from the page control, not the user dragging
            return;
        }
        
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        // customized behavior by caller
        [pageViewDelegate didScrollToPageAtIndex:page];
        
        if ([(NSObject *)pageViewDelegate respondsToSelector:@selector(indexOfPagesOfPageControl:)])
            self.pageControl.currentPage = [pageViewDelegate indexOfPagesOfPageControl:page];
        else
            self.pageControl.currentPage = page;
        
        [self checkButton:page];
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        [self loadPage:page];
    }
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scv willDecelerate:(BOOL)decelerate{
    if (scv.contentOffset.x>scv.contentSize.width-scv.frame.size.width){
        if ([(NSObject *)pageViewDelegate respondsToSelector:@selector(didScrollToLast)])
        [pageViewDelegate didScrollToLast];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView1 {
    if (scrollView1 != self.scrollView) {
        return [scrollView1 viewWithTag:800];
    }
    return nil;
}



- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView1 withView:(UIView *)view atScale:(float)scale {
    //    NSLog(@"\nFrame:%@\nOffset:%@\Scroll Bounds:%@,Size:%@",NSStringFromCGRect(imgvPhoto.frame),NSStringFromCGPoint(scvPhoto.contentOffset),NSStringFromCGRect(scvPhoto.bounds),NSStringFromCGSize(scvPhoto.contentSize));
    //    float w = imgvPhoto.frame.size.width;
    //    float h = imgvPhoto.frame.size.height;
    //    float W = self.frame.size.width;
    //    float H = self.frame.size.height;
    //    
    //    
    //    //   [scvPhoto setContentSize:CGSizeMake(MAX(w,W),MAX(h,H))];
    ////    [scvPhoto setContentSize:imgvPhoto.frame.size];
    //
    //    imgvPhoto.center = CGPointMake(0.5f*MAX(w, W), 0.5f*MAX(h, H));
    UIView *v = nil;
    if (scrollView1 != self.scrollView) {
        v = [scrollView1 viewWithTag:800];
    }
    
    CGSize boundsSize = scrollView1.bounds.size;
    
    
    
    CGRect frameToCenter = v!=nil?v.frame:CGRectZero;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        v.frame = frameToCenter;
    }];
    
    
}

#pragma mark public method
- (void)enqueueReusablePage:(UIView *)pageView atIndex:(NSUInteger)index {
	NSUInteger cacheCount;
	
	cacheCount = [arrayViewCache count];
	if (index < cacheCount) {
		[arrayViewCache replaceObjectAtIndex:index withObject:pageView];
	} else {
		for (unsigned i = cacheCount; i < index; i++) {
			[arrayViewCache addObject:[NSNull null]];
		}
		if(pageView)
		[arrayViewCache addObject:pageView];
		else {
			[arrayViewCache addObject:[NSNull null]];
		}

	}

}

/*
 * For performance reasons, a scrollPageView should generally reuse page objects.
 * It returns a reusable page object.
 *
 * @return: A page object or nil if no such object exists in the reusable-cell queue.
 */
- (UIView *)dequeueReusablePage:(NSUInteger)index {
    UIView *pageView;
	
	pageView = nil;
	
	if (index < [arrayViewCache count]) {
		pageView = [arrayViewCache objectAtIndex:index];
		if ([NSNull null] == (NSNull *)pageView) {
			pageView = nil;
		}
	}
	
	return pageView;
}

- (void)clearReusablePage {
	NSUInteger i, arrayCount;
	UIView *v;
	
	arrayCount = [arrayViewCache count];
	for (i = 0; i < arrayCount; i++) {
		v = [arrayViewCache objectAtIndex:i];
		// clear subviews form the view
		if ([NSNull null] != (NSNull *)v) {
			[v removeFromSuperview];
		}
		[arrayViewCache replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}

- (void)reloadData {
	//pageCount = [pageViewDelegate numberOfPagesInScrollPageView];
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageCount, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
	if (pageCount > 0) {
		[self clearReusablePage];
		/*
		arrayViewCache = nil;
		NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:1];
		self.arrayViewCache = views;
		[views release];
		 */
	}
    
        
	if ([(NSObject *)pageViewDelegate respondsToSelector:@selector(numberOfPagesOfPageControl:)])
        pageControl.numberOfPages = [pageViewDelegate numberOfPagesOfPageControl:0];
    else
        pageControl.numberOfPages = pageCount;
    pageControl.currentPage = 0;
	
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if ([(NSObject *)pageViewDelegate respondsToSelector:@selector(indexOfPagesOfPageControl:)])
        self.pageControl.currentPage = [pageViewDelegate indexOfPagesOfPageControl:page];
    else
        self.pageControl.currentPage = page;

	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadPage:page];

	[pageControl updateCurrentPageDisplay];
}

- (void)setDelegate:(id)delegate {
	pageViewDelegate = delegate;
}

@end
