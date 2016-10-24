//
//  MNavigationController.m
//  Mosaic
//
//  Created by Stan Wu on 14-5-7.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "MNavigationController.h"
#import "SWToolKit.h"

@interface MNavigationController ()

@end

@implementation MNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    // Do any additional setup after loading the view.
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, sw_get_navigation_bar_height())];
        imgv.backgroundColor = THEME_COLOR;
        
//        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, imgv.frame.size.height-.5f, ScreenWidth, .5f)];
//        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
//        [imgv addSubview:line];
        
        UIGraphicsBeginImageContextWithOptions(imgv.frame.size, YES, [UIScreen mainScreen].scale);
        [imgv.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsPopContext();
        
        [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationItem.leftBarButtonItems = nil;
    
    bShowTabBar = YES;
    
    self.delegate = self;
    setShowTabBar = [NSSet setWithObjects:@"RegisterViewController",@"OAMeViewController",@"OATrystsViewController",@"OANearbyViewController",@"MMeViewController", nil];
    setTransparentTabBar = [NSSet setWithObjects:@"Affair.MLogin1ViewController", nil];
    
    setHideNavBar = [NSSet setWithObjects:@"ViewController", nil];

    
}


- (void)showNormalBar{
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, sw_get_navigation_bar_height())];
    imgv.backgroundColor = THEME_COLOR;
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, imgv.frame.size.height-.5f, ScreenWidth, .5f)];
//    line.backgroundColor = [UIColor colorWithRed:.01 green:.01 blue:.01 alpha:1];
    line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [imgv addSubview:line];
    
    UIGraphicsBeginImageContextWithOptions(imgv.frame.size, YES, [UIScreen mainScreen].scale);
    [imgv.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    
    [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowImage = [[UIImage alloc] init];
}

- (void)showTransparentBar{
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.translucent = YES;
}

- (void)showClearNavigationBar{
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
//        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        if (sw_get_navigation_bar_height()==64) {
            //[UIImage imageNamed:@"MProfileHeadNav"]
            
//            self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        }else{
            //[UIImage imageNamed:@"MProfileHeadNav2"]
            [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSString *vcname = NSStringFromClass([viewController class]);
    vcname = [[vcname componentsSeparatedByString:@"."] lastObject];
    
    if ([setShowTabBar containsObject:vcname])
        bShowTabBar = YES;
    else
        bShowTabBar = NO;
    
    if ([setTransparentTabBar containsObject:vcname]){
        [self showTransparentBar];
    }else{
        [self showNormalBar];
    }
    
    if ([setHideNavBar containsObject:vcname]){
        self.navigationBar.hidden = YES;
    }else{
        self.navigationBar.hidden = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:bShowTabBar?@"ShowTabBar":@"HideTabBar" object:nil];
}


@end
