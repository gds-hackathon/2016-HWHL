//
//  SWAnalyticsHelper.swift
//  Affair
//
//  Created by Stan Wu on 15/11/17.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import UIKit

@objc class SWAnalyticsHelper: NSObject {
    @objc enum PaySource: Int32{
        //  1-App Store,2-支付宝,3-网银,4-财付通,5-移动通信,6-联通通信,7-电信通信,8-paypal,21-微信支付

        case apple = 1,alipay,unionPay,tencentPay,chinaMobile,chinaUnicom,chinaTelecom,payPal
        case weixin = 21
    }
    
    class func pay(_ productIdentifer: String!,source: PaySource){
        let productIdentifer: String! = productIdentifer ?? (UserDefaults.standard.object(forKey: "LastProductID") as? String)
        //  supervip1,12Month,6Month,3Month,1Month

        if productIdentifer == nil{
            return
        }
        
        
        var item: String = ""
        var price: Double = 0
        var buy_type = 0
        
        switch productIdentifer{
        case "12MonthVIP":
            item = NSLocalizedString("12个月会员", comment: "12个月会员")
            price = 488
        case "6MonthVIP":
            item = NSLocalizedString("6个月会员", comment: "6个月会员")
            price = 298
        case "3MonthVIP":
            item = NSLocalizedString("3个月会员", comment: "3个月会员")
            price = 198
        case "1MonthVIP":
            item = NSLocalizedString("1个月会员", comment: "1个月会员")
            price = 98
        case "SuperVIP":
            item = NSLocalizedString("旗舰会员", comment: "旗舰会员")
            price = 998
        case "15Coin","30Coin","49Coin","99Coin","999Coin":
            buy_type = 1
            item = "\((productIdentifer as NSString).integerValue)" + NSLocalizedString("枚喵币", comment: "枚喵币")
            price = Double((productIdentifer as NSString).integerValue * 2)
        default:()
        }
        
        if item.length == 0 || price == 0{
            print("record purchase log failed")
            return
        }
        
        let platform: String
        
        switch source{
        case .apple: platform = "苹果"
        case .alipay: platform = "支付宝"
        case .weixin: platform = "微信"
        case .unionPay: platform = "银联"
        default: platform = "其他\(source.rawValue)"
        }
        

        SWAnalyticsHelper.trackEvent("充值成功", properties: ["产品ID":productIdentifer,"购买类型":(0 == buy_type ? "会员" : "喵币"),"支付方式":platform,"价格":"\(price)"])
        MobClickGameAnalytics.pay(price, source: source.rawValue, item: item, amount: 1, price: price)
    }
    
    @objc class func alipay(_ subject: String,price: Double){
        MobClickGameAnalytics.pay(price, source: PaySource.alipay.rawValue, item: subject, amount: 1, price: price)
    }
    
    class func trackEvent(_ eventID: String, properties: [AnyHashable: Any]?){
        SWAnalyticsHelper.trackEvent(eventID, nil, properties)
    }
        
    class func trackEvent(_ eventID: String, _ label: String? = nil, _ parameters: [AnyHashable: Any]? = nil){
        if label == nil && parameters == nil{
            MobClick.event(eventID)
        }else if label != nil && parameters != nil{
            MobClick.event(eventID, label: label)
        }else if label != nil{
            MobClick.event(eventID, label: label)
        }else{
            MobClick.event(eventID, attributes: parameters)
        }
        
//        if let param = parameters{
//            Zhuge.sharedInstance().track(eventID, properties: param)
//        }else{
//            Zhuge.sharedInstance().track(eventID)
//        }
        
    }
    
    class func trackPageBegin(_ pageName: String){
        MobClick.beginLogPageView(pageName)
    }
    
    class func trackPageEnd(_ pageName: String){
        MobClick.endLogPageView(pageName)
    }
    
    class func trackRegister(){
        if let uid = MDataProvider.myInfo()?.object(forKey: "uid") as? String{
            
            
            trackUserAccount()
        }
    }
    
    class func trackLogin(){
        if let uid = MDataProvider.myInfo()?.object(forKey: "uid") as? String{
            
            
            trackUserAccount()
        }
    }
    
    class func trackUserAccount(){
        if let userInfo = MDataProvider.myInfo(){
            guard let uid = userInfo.object(forKey: "uid") as? String else{
                return
            }
            
            //  Add attributes that defined by Zhuge already
            let gender = userInfo.int(forKey: "gender") ?? 0
        
            var user = [String:String]()
            user["name"] = userInfo.object(forKey: "nickname") as? String
            if gender > 0{
                user["gender"] = 2 == gender ? "女" : "男"
            }
            
            if let birthday = userInfo.int(forKey: "birthday") {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy/MM/dd"
                user["birthday"] = fmt.string(from: Date(timeIntervalSince1970: TimeInterval(birthday)))
            }
            
            user["weixin"] = userInfo.object(forKey: "weixin") as? String
            user["mobile"] = userInfo.object(forKey: "phone") as? String
    
            user["avatar"] = userInfo.object(forKey: "avatar") as? String
            user["location"] = SWUtils.area(userInfo.int(forKey: "province"), city: userInfo.int(forKey: "city"))
            
            //  Append other attributes
            for (_,key) in userInfo.allKeys.enumerated(){
                if let k = key as? String{
                    if let v = userInfo.object(forKey: k) as? String{
                        if user[k] == nil{
                            user[k] = v
                        }
                    }
                 }
            }
            
            //  Clear needless attributes
            user["access_token"] = nil
            user["xmpp_password"] = nil
            user["password"] = nil
            if let introduction = user["introduction"]{
                if introduction.length > 80{
                    user["introduction"] = introduction.substring(to: introduction.characters.index(introduction.startIndex, offsetBy: 79))
                }
            }
            
//            Zhuge.sharedInstance().identify(uid, properties: user)
        }
    }

}
