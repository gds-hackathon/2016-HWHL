//
//  AppDelegate.swift
//  GreenDotters
//
//  Created by Stan Wu on 21/10/2016.
//  Copyright © 2016 Stan Wu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let internetReach = Reachability.forInternetConnection()
    var currentNetworkStatus: NetworkStatus!
    var window: UIWindow?
    var isLogout = false
    var isAccessTokenInvaid = false
    
    class var isBeta: Bool{
        get{
            return true
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        currentNetworkStatus = internetReach?.currentReachabilityStatus()
        internetReach?.startNotifier()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            let vc = PortalViewController()
            
            let nav = MNavigationController(rootViewController: vc)
            
            window?.rootViewController = nav
        } else {
            let vc = ViewController()
            
            let nav = MNavigationController(rootViewController: vc)
            
            window?.rootViewController = nav
        }
        
        
        window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterPortal), name: NSNotification.Name(rawValue: "LoginAccount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.accessTokenInvalid), name: NSNotification.Name(rawValue: "AccessTokenInvalid"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logoutAccount), name: NSNotification.Name(rawValue: "LogoutAccount"), object: nil)
        
        
        return true
    }
    
    func enterPortal() {
        let vc = PortalViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isTranslucent = false
        window?.rootViewController = nav
        
        isLogout = false
    }
    
    func logoutAccount() {
        if isLogout {
            return
        }
        
        isLogout = true
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "UserInfo")
        
        let vc = ViewController()
        
        let nav = MNavigationController(rootViewController: vc)
        
        self.window?.rootViewController = nav
    }
    
    func accessTokenInvalid() {
        if isAccessTokenInvaid {
            return
        }
        
        isAccessTokenInvaid = true
        
        OAAlertView.show(nil, message: "账户信息有所变动，请重新登录", cancel: nil) { (msg) in
            UserDefaults.standard.removeObject(forKey: "access_token")
            UserDefaults.standard.removeObject(forKey: "UserInfo")
            
            let vc = ViewController()
            
            let nav = MNavigationController(rootViewController: vc)
            
            self.window?.rootViewController = nav
            
            self.isAccessTokenInvaid = false
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let strurl = url.absoluteString
        
        if strurl.hasPrefix("greendot.alipay") {
            parseAlipay(url)
        }
        
        return true
    }
    
    func parseAlipay(_ url: URL!) {
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { (dict: [AnyHashable : Any]?) in
            guard let info = dict else {
                OAAlertView.show(nil, message: "消费失败", cancel: nil)
                return
            }
            
            let resultDic = info as NSDictionary
            let resultStatus = resultDic.intValue("resultStatus")
            
            if 9000 == resultStatus{
                OAAlertView.show(nil, message: "支付成功", cancel: nil)
            }else{
                var msg = "支付失败"
                
                switch resultStatus{
                case 4000:
                    msg = NSLocalizedString("支付失败", comment: "支付失败")
                case 6001:
                    msg = NSLocalizedString("支付已取消", comment: "支付已取消")
                case 6002:
                    msg = NSLocalizedString("网络连接出错", comment: "网络连接出错")
                default:()
                }
                
                if let memo = resultDic["memo"] as? String{
                    OAAlertView.show(nil, message: memo.length > 0 ? memo : msg, cancel: nil)
                }else{
                    OAAlertView.show(nil, message: msg, cancel: nil)
                }
            }

        }
    }
}

