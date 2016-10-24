//
//  MNavigationController.h
//  Mosaic
//
//  Created by Stan Wu on 14-5-7.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNavigationController : UINavigationController<UINavigationControllerDelegate>{
    BOOL bShowTabBar;
    NSSet *setShowTabBar;
    NSSet *setTransparentTabBar;
    NSSet *setHideNavBar;
}

@end
