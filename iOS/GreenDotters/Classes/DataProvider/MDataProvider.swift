//
//  MDataProvider.swift
//  Mosaic
//
//  Created by Stan Wu on 15/7/3.
//  Copyright (c) 2015 Stan Wu. All rights reserved.
//

import UIKit
import CoreLocation

class MDataProvider: NSObject {
    //  MARK: - APIs
    static let dicAPI = NSDictionary(contentsOfFile: "api.plist".bundlePath()) as NSDictionary!
    static let dicProfilePlist = NSDictionary(contentsOfFile: "ProfileInfo.plist".bundlePath()) as NSDictionary!
    
    class func getShopInfo(_ parameters: NSDictionary?, completionBlock:  @escaping (_ code: Int, _ data: Any?, _ message: String?) -> Void) {
        MDataProvider.getData("getShopInfo", parameters: parameters, completionBlock: completionBlock)
    }
    
    class func getDiscountedPrice(_ parameters: NSDictionary?, completionBlock:  @escaping (_ code: Int, _ data: Any?, _ message: String?) -> Void) {
        MDataProvider.getData("getDiscountedPrice", parameters: parameters, completionBlock: completionBlock)
    }
    
    class func makePurchase(_ parameters: NSDictionary?, completionBlock:  @escaping (_ code: Int, _ data: Any?, _ message: String?) -> Void) {
        MDataProvider.getData("getOrder", parameters: parameters, completionBlock: completionBlock)
    }
    
    class func getOrder(_ parameters: NSDictionary?, completionBlock:  @escaping (_ code: Int, _ data: Any?, _ message: String?) -> Void) {
        MDataProvider.getData("getOrder", parameters: parameters, completionBlock: completionBlock)
    }
    
    class func login(_ parameters: NSDictionary?) -> NSDictionary?{
        UserDefaults.standard.removeObject(forKey: "access_token")
        
        
        let dictR = MDataProvider.getData("login", parameters: parameters)
        
        if let result = dictR{
            if let userInfo = result.object(forKey: "data") as! NSDictionary?{
                let access_token = userInfo.object(forKey: "access_token") as! String
                UserDefaults.standard.set(access_token, forKey: "access_token")
                UserDefaults.standard.set(userInfo, forKey: "UserInfo")
                if let _ = userInfo.object(forKey: "uid") as? String{
//                    let account = TDGAAccount.setAccount(uid)
//                    TalkingDataAppCpa.onLogin(uid)
                    
//                    let gender = userInfo.objectForKey("gender")?.integerValue ?? 0
//                    account.setAccountType(kAccountRegistered)
//                    account.setGender(0 == gender ? kGenderUnknown : (1 == gender ? kGenderMale : kGenderFemale))
                    
                    if let accountInfo = parameters{
                        UserDefaults.standard.set(accountInfo, forKey: "AccountInfo")
                    }
                }
            }
        }
        
        return dictR
    }
    
    //  MARK: - Push
    class func recordDevice(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("recordDevice", parameters: dict)
    }
    
    class func getPrompts(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getPrompts", parameters: dict)
    }
    
    class func getNoticeList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getNoticeList", parameters: dict)
    }
    
    class func pushMessage(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("pushMessage", parameters: dict)
    }
    
    //  MARK: - Config
    class func getAppConfig(_ dict: NSDictionary?) -> NSDictionary?{
        var param = dict
        if param == nil{
            param = NSDictionary(object: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!,forKey: "app_version" as NSCopying)
        }
        return MDataProvider.getData("getAppConfig", parameters: param)
    }

    
    //  MARK: - Purchase
    class func getOrderNo(_ dict: NSDictionary?) -> NSDictionary?{
        let result =  MDataProvider.getData("getOrderNo", parameters: dict)
        
        if let productID = dict?.object(forKey: "product_id") as? String{
            UserDefaults.standard.set(productID, forKey: "LastProductID");
        }
        
        /*
        if let order_number = result?.objectForKey("data")?.objectForKey("order_number") as? String{
            let productID = dict?.objectForKey("product_id") as! String
            var price:Double = 0
            var payment_type = NSLocalizedString("苹果", comment: "苹果")
            
            switch productID{
                case "supervip1":price = 998
                case "7Day":price = 30
                case "1Month":price = 98
                case "3Month":price = 198
                case "6Month":price = 298
                case "12Month":price = 488
            default:()
            }
            
            if let source = dict?.objectForKey("source") as? String{
                switch source{
                    case "alipay","alipaywap":payment_type = NSLocalizedString("支付宝", comment: "支付宝")
                default:()
                }
            }
        }
        */
        return result
    }
    
    class func rechargeAccount(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("rechargeAccount", parameters: dict)
    }
    

    //  MARK: - Status
    class func getStatus(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getContentList", parameters: dict)
    }
    
    class func getUserContent(_ dict: NSDictionary?) -> NSDictionary?{
        return  MDataProvider.getData("getUserContent", parameters: dict)
    }
    
    class func getPrivateContent(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getPrivateContent", parameters: dict)
    }
    
    class func getLikedContentList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getLikedContentList", parameters: dict)
    }
    
    class func getCommentList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getCommentList", parameters: dict)
    }
    
    class func commentContent(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("commentContent", parameters: dict)
    }
    
    class func likeContent(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("likeContent", parameters: dict)
    }
    
    class func deleteContent(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("deleteContent", parameters: dict)
    }
    
    class func getContentDetail(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getContentDetail", parameters: dict)
    }
    
    class func getContentLikedList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getContentLikedList", parameters: dict)
    }
    
    class func getLikedMyContentList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getLikedMyContentList", parameters: dict)
    }
    
    class func addNewStatus(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("publishContent", parameters: dict)
    }
    
    //  MARK: - Tryst
    class func createTryst(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("createTryst", parameters: dict)
    }
    
    class func getTrystList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getTrystList", parameters: dict)
    }
    
    class func applyTryst(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("applyTryst", parameters: dict)
    }
    
    class func deleteTryst(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("deleteTryst", parameters: dict)
    }
    
    
    //  MARK: - User
    class func changePassword(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("changePassword", parameters: dict)
    }
    
    class func getAvatars(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getAvatars", parameters: dict)
    }
    
    class func getTemplets(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getTemplets", parameters: dict)
    }
    
    class func getBlockedUserList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getBlockedUserList", parameters: dict)
    }
    
    class func getVisitorList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getVisitorList", parameters: dict)
    }
    
    class func getFollowerList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getFollowerList", parameters: dict)
    }
    
    class func getFolloweeList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getFolloweeList", parameters: dict)
    }
    
    class func followUser(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("followUser", parameters: dict)
    }
    
    class func stopFollowUser(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("stopFollowUser", parameters: dict)
    }
    
    
    
    class func getPrivatePhotos(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getPrivatePhotos", parameters: dict)
    }
    
    class func uploadPhoto(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("uploadPhoto", parameters: dict)
    }
    

    class func updateLocation(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("updateLocation", parameters: dict)
    }
    
    class func getUserList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getUserList", parameters: dict)
    }
    
    class func searchUser(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("searchUser", parameters: dict)
    }
    
    class func getMyProfile() -> NSDictionary?{
        let dict = MDataProvider.getDetailProfile(nil)
        
        return dict
    }
    
    class func getSurpriseList() -> NSDictionary?{
        return MDataProvider.getData("getSurpriseList", parameters: nil)
    }
    
    
    class func getDetailProfile(_ dict: NSDictionary?) -> NSDictionary?{
        let ret = MDataProvider.getData("getDetailProfile", parameters: dict)

        if let profile:NSDictionary = ret?.object(forKey: "data") as? NSDictionary{
            let uid:String = profile.object(forKey: "uid") as! String
            
            if uid == MDataProvider.myUID(){
                let oldprofile = UserDefaults.standard.object(forKey: "UserInfo") as? NSDictionary
                UserDefaults.standard.set(profile, forKey: "UserInfo");
                
                SWUtils.RunOnMainThread({ () -> Void in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: ProjectNotifications.REFRESH_PURCHASE_UI), object: nil, userInfo: nil)
                })
                
 
            }
        }
        
        return ret
    }

    class func getRegisterAuthCode(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getRegisterAuthCode", parameters: dict)
    }
    
    class func checkRegisterAuthCode(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("checkRegisterAuthCode", parameters: dict)
    }
    
    class func forgetPassword(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("forgetPassword", parameters: dict)
    }
    
    class func sendAuthCode(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("sendAuthCode", parameters: dict)
    }
    
    class func bindPhone(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("bindPhone", parameters: dict)
    }
    
    class func getHiStatus(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getHiStatus", parameters: dict)
    }

   
    class func reg(_ dict: NSDictionary?) -> NSDictionary?{
        let dictNew = NSMutableDictionary(dictionary: dict!)
        
        dictNew.setObject(MDataProvider.clientID(), forKey: "client_id" as NSCopying)
        
        let dictR = MDataProvider.getData("register", parameters: dictNew)

        if let access_token = (dictR?.object(forKey: "data") as? NSDictionary)?.object(forKey: "access_token") as? String{
            UserDefaults.standard.set(access_token, forKey: "access_token")
            UserDefaults.standard.set(dictR?.object(forKey: "data")!, forKey: "UserInfo")
            if let userInfo = dictR?.object(forKey: "data") as? NSDictionary{
                if let uid = userInfo.object(forKey: "uid") as? String{
//                    let account = TDGAAccount.setAccount(uid)
//                    TalkingDataAppCpa.onRegister(uid)
//                    
//                    let gender = userInfo.objectForKey("gender")?.integerValue ?? 0
//                    
//                    account.setAccountType(kAccountRegistered)
//                    account.setGender(0 == gender ? kGenderUnknown : (1 == gender ? kGenderMale : kGenderFemale))
                    
                    if let password = userInfo.object(forKey: "password") as? String{
                        UserDefaults.standard.set(["uid":uid,"password":password], forKey: "AccountInfo")
                    }
                }
            }
            
        }
        
        return dictR
    }
    
    
    
    
    
    class func updateProfile(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("updateProfile", parameters: dict)
    }
    
    class func getStatusesInfo(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getStatusesInfo", parameters: dict)
    }
    
    //  MARK: - Intimate Functions
    class func applyIntimate(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("applyIntimate", parameters: dict)
    }
    
    class func getIntimateList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getIntimateList", parameters: dict)
    }
    
    class func getApplyList(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getApplyList", parameters: dict)
    }
    
    class func acceptIntimate(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("acceptIntimate", parameters: dict)
    }
    
    class func refuseIntimate(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("refuseIntimate", parameters: dict)
    }
    
    //  MARK: - Photos
    class func updateAvatar(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("updateAvatar", parameters: dict)
    }
    
    class func deletePhoto(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("deletePhoto", parameters: dict)
    }
    
    // MARK: - Free VIP
    class func getFreeVIP(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getFreeVIP", parameters: dict)
    }
    
    class func getFreeStatus(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getFreeStatus", parameters: dict)
    }
    
    class func getFreeCoin(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getFreeCoin", parameters: dict)
    }
    
    class func unlockChat(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("unlockChat", parameters: dict)
    }
    
    //  MARK: - Notice Settings
    class func getNoticeSettings(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("getNoticeSettings", parameters: dict)
    }
    
    class func updateNoticeSettings(_ dict: NSDictionary?) -> NSDictionary?{
        return MDataProvider.getData("updateNoticeSettings", parameters: dict)
    }
    
    // MARK: - Utils Functions
    class func getDealerID() -> String!{
        if let userInfo = getUserInfo(){
            if let dealerID = userInfo.object(forKey: "dealer_id") as? String{
                return dealerID
            }else{
                return "0"
            }
        }else{
            return "0"
        }
    }
    
    class func getUserInfo() -> NSDictionary?{
        return UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary?
    }
    
    enum TrueWordType: Int{
        case classic,`private`
    }
    
    class func getRandomTrueWord(_ type: TrueWordType) -> NSDictionary?{
        let dicTrueWord = NSDictionary(contentsOfFile: "trueword.plist".bundlePath()) as NSDictionary!
        
        guard let questions = dicTrueWord?.object(forKey: type == .classic ? "classic" : "private") as? [NSDictionary] else{
            return nil
        }
        
        let index = Int(arc4random() % UInt32(questions.count))
        
        return questions[index]
    }
    
    // MARK: - Basic Functions
    class func paramString(_ param:NSDictionary) -> String{
        let requestTime = String(format: "%.0lf", Date().timeIntervalSince1970)
        let dictParamNew:NSMutableDictionary = NSMutableDictionary(dictionary: param)

        dictParamNew.setObject(requestTime, forKey: "request_time" as NSCopying)
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        dictParamNew.setObject(version, forKey: "app_version" as NSCopying)
        
        if let source = MDataProvider.channelID(){
            dictParamNew.setObject(source, forKey: "user_source" as NSCopying)
        }
        
        let access_token = UserDefaults.standard.object(forKey: "access_token") as! String?
        
        if let at = access_token {
            dictParamNew.setObject(at, forKey: "access_token" as NSCopying)
        }else{
            dictParamNew.setObject(clientID(), forKey: "client_id" as NSCopying)
        }
        dictParamNew.setObject(String.UUIDString(), forKey: "device_id" as NSCopying)
        
        
        if let locationInfo = UserDefaults.standard.object(forKey: "MyLocation") as? NSDictionary{
            let latitude = locationInfo.object(forKey: "latitude") as? String
            let longitude = locationInfo.object(forKey: "longitude") as? String
            
            if latitude != nil && longitude != nil{
                dictParamNew.setObject("\(latitude!)", forKey: "latitude" as NSCopying)
                dictParamNew.setObject("\(longitude!)", forKey: "longitude" as NSCopying)
            }
        }
        
        
        // concat parameters
        let str:NSMutableString = NSMutableString()
        
        for i in 0 ..< dictParamNew.allKeys.count{
            let key = dictParamNew.allKeys[i] as! String
            str.append("&")
            str.append("\(key)=\(dictParamNew.object(forKey: key)!)")
        }
        
        //add sign
        str.appendFormat("&sign=%@", sign(dictParamNew).lowercased())
        
        return str as String;
    }
    
    class func sign(_ param:NSDictionary) -> String{
        
        
        
        let keyItem1: String = clientID().data(using: String.Encoding.utf8, allowLossyConversion: false)!.MD5String()
        let keyItem2: String = String.UUIDString().data(using: String.Encoding.utf8, allowLossyConversion: false)!.MD5String()
        
        let requestTime = param.object(forKey: "request_time") as! String
        let keyItem3: String = requestTime.data(using: String.Encoding.utf8, allowLossyConversion: false)!.MD5String()
        
        let key = "\(keyItem1)\(keyItem2)\(keyItem3)".data(using: String.Encoding.utf8, allowLossyConversion: false)!.MD5String()
        
        //real_key
        let real_key = key.HMACSHA1StringWithKey(clientSecret())
        
        //data
        let dictNew = NSMutableDictionary(dictionary: param)
        
        
        let data: String = MDataProvider.sortParam(dictNew)
        
        
        //sign
        let sign = data.HMACSHA1StringWithKey(real_key)
        
        return sign
    }
    
    
    
    class func sortParam(_ param: NSDictionary) -> String{
        let strMul = NSMutableString()
        
        let keys = param.allKeys as! [String]
        
        let sortedArray = keys.sorted { (obj1: String, obj2: String) -> Bool in
            let result = obj1.compare(obj2, options: NSString.CompareOptions.numeric)
            if result != ComparisonResult.orderedDescending{
                return true
            }else{
                return false
            }
            
        }
        
        
        for key in sortedArray {
            strMul.append("\(key)=\(param.object(forKey: key)!)")
        }
        
        return strMul as String;
    }
    
    
    
    
    class func clientID() -> String{
        return "greendot_ios"
    }
    
    
    class func clientSecret() -> String{
        return "ac15bc3fb9e85961b3f0e61b4a96277dcabcde87";
    }
    
    class func getData(_ api: String,parameters: NSDictionary?, completionBlock:  @escaping (_ code: Int, _ data: Any?, _ message: String?) -> Void) {
        sw_dispatch_on_background_thread {
            let dict = MDataProvider.getData(api, parameters: parameters)
            
            sw_dispatch_on_main_thread {
                let code = dict?.int(forKey: "code") ?? 0
                let data = dict?.object(forKey: "data")
                let message = dict?.object(forKey: "message") as? String
                
                completionBlock(code, data, message)
            }
        }
    }
    
    class func getData(_ api: String,parameters: NSDictionary?) -> NSDictionary?{
        let is_api = !(((dicAPI?.object(forKey: api) as? String)?.hasPrefix("base") ?? false) || ((dicAPI?.object(forKey: api) as? String)?.hasPrefix("push") ?? false))

        var baseURL = dicAPI?.object(forKey: is_api ? "baseAPIURL" : "baseURL") as! String
        
#if arch(i386) || arch(x86_64)
        if AppDelegate.isBeta {
            baseURL = (dicAPI?.object(forKey: is_api ? "baseAPIURLLocal" : "baseURLLocal") as! String)
        }
#endif
        
        let url = URL(string: baseURL + (dicAPI?.object(forKey: api) as! String))!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 20)
        request.httpMethod = "POST"
        
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        var real_param = NSDictionary()
        
        if let param = parameters{
            real_param = param
        }
        
        let mut = NSMutableDictionary(dictionary: real_param);
        
        for key in real_param.allKeys{
            if real_param.object(forKey: key)! is [AnyObject] || real_param.object(forKey: key)! is NSArray || real_param.object(forKey: key)! is [String:AnyObject] || real_param.object(forKey: key)! is NSDictionary{
                mut.removeObject(forKey: key)
            }
        }
        
        real_param = NSDictionary(dictionary: mut)
        
        let pLast = paramString(real_param)
        
        print("\(url)?\(pLast)");
        
        request.httpBody = pLast.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        var data: Data?,error: NSError?,content: String?,dict: NSDictionary?
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        do {
            data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: response)
        } catch let error1 as NSError {
            error = error1
            data = nil
        }
        
        if let er = error{
            NSLog("API Error:%@", er)
        }
        
        if let d = data{
            content = NSString(data: d, encoding: String.Encoding.utf8.rawValue) as? String
            
            do{
                try dict = JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions()) as? NSDictionary
            }catch _ {
                print("Invalid Response:\(content)")
            }
        }
        
        
        
        if let result = dict
        {
            SWUtils.RunOnMainThread({ () -> Void in
                let code = (result.object(forKey: "code") as! NSNumber).intValue
                
                
                
                NSLog("response code:%d",code)
                
                if SWDefinitions.RETURN_SUCCESS_CODE != code{
                    if let msg = result.object(forKey: "message") as? String{
                        NSLog("return message:\(msg)")
                    }
                }
                
                if code==10007 || code==10006{
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "AccessTokenInvalid"), object: nil)
                }
            })
            
            return result;
        }
        
        
        return dict;
    }
    
    
    
    //  MARK: - Local Profile Functions
    class func profilePlist() -> NSDictionary{
        return dicProfilePlist!
    }

    class func myInfo() -> NSDictionary?{
        return UserDefaults.standard.object(forKey: "UserInfo") as? NSDictionary
    }
    
    class func isVIP() -> Bool{
        return (MDataProvider.myInfo()?.bool(forKey: "is_vip") ?? false) || self.isSuperVIP()
    }
    
    class func isSuperVIP() -> Bool{
        return MDataProvider.myInfo()?.bool(forKey: "is_super_vip") ?? false
    }
    
    class func myUID() -> String?{
        return (UserDefaults.standard.object(forKey: "UserInfo") as? NSDictionary)?.object(forKey: "uid") as? String
    }
    
    class func myIntUID() -> Int{
        if let uid = myUID(){
            return Int(uid) ?? 0
        }
        
        return 0
    }
    
    class func XMPPPassword() -> String?{
        return MDataProvider.myInfo()?.object(forKey: "xmpp_password") as? String
    }
    
    class func distance(_ locationInfo: NSDictionary?) -> String?{
        if locationInfo == nil{
            return nil
        }
        
        if let myLocation = UserDefaults.standard.object(forKey: "MyLocation") as? NSDictionary{
            let mylat = (myLocation.object(forKey: "latitude") as? NSString)?.doubleValue ?? 0
            let mylng = (myLocation.object(forKey: "longitude") as? NSString)?.doubleValue ?? 0
            
            let lat = (locationInfo?.object(forKey: "latitude") as? NSString)?.doubleValue ?? 0
            let lng = (locationInfo?.object(forKey: "longitude") as? NSString)?.doubleValue ?? 0
            
            if (mylat == 0 && mylng == 0) || (lat == 0 && lng == 0){
                return nil
            }
            
            let locA = CLLocation(latitude: mylat, longitude: mylng)
            let locB = CLLocation(latitude: lat, longitude: lng)
            
            let distance = locA.distance(from: locB)
            
            return "\(Int(distance/1000.0))km"
        }
        
        return nil
    }
    
    class func TA() -> String?{
        let gender = (UserDefaults.standard.object(forKey: "UserInfo") as? NSDictionary)?.int(forKey: "gender") ?? 0
        if 1==gender{
            return NSLocalizedString("她", comment: "她")
        }else{
            return NSLocalizedString("他", comment: "他")
        }
    }
    
    class func genderOfUser(_ info: NSDictionary?) -> String{
        let gender = info?.int(forKey: "gender") ?? 0
        if 1==gender{
            return NSLocalizedString("他", comment: "他")
        }else if 2==gender{
            return NSLocalizedString("她", comment: "她")
        }else{
            return "TA"
        }
    }
    
    class func randomNickname() -> String{
        let gender = MDataProvider.getUserInfo()?.int(forKey: "gender") ?? 1
        
        return MDataProvider.randomNickname(gender)
    }
    
    class func randomNickname(_ gender: Int) -> String{
//        var nickname: String!
        let filename = 2==gender ? "name-female.plist" : "name-male.plist"
        
        let dict = NSDictionary(contentsOfFile:filename.bundlePath())!
        let adjs = dict.object(forKey: "adj") as! NSArray
        let nouns = dict.object(forKey: "noun") as! NSArray
        
        let adj = adjs.object(at: Int(arc4random() % UInt32(adjs.count))) as! String
        let noun = nouns.object(at: Int(arc4random() % UInt32(nouns.count))) as! String
        
        return String(format: NSLocalizedString("%@的%@", comment: "%@的%@"), adj, noun)
    }
    
//    @objc class func getSearchOptions(_ filterType: FilterOptionType) -> NSDictionary?{
//        let dicResult = NSMutableDictionary();
//        
//        let optionKey = filterType == .near ? "NearSearchOption" : "TrystFilterOption"
//        
//        if let dicOptions = UserDefaults.standard.object(forKey: optionKey) as? NSDictionary{
//            for key in dicOptions.allKeys as! [String]{
//                dicResult.setObject(dicOptions.object(forKey: key)!, forKey: key as NSCopying)
//            }
//            
//            let keys = "private,weixin,status,weixin".components(separatedBy: ",")
//            if !MDataProvider.isVIP(){
//                for key in keys{
//                    dicResult.removeObject(forKey: key)
//                }
//                
//                UserDefaults.standard.set(dicResult, forKey: optionKey)
//            }
//        }else{
//            let my_gender = MDataProvider.getUserInfo()?.int(forKey: "gender") ?? 0
//            let province = MDataProvider.getUserInfo()?.int(forKey: "province") ?? 0
//            let gender = 2 == my_gender ? 1 : 2
//            
//            dicResult.setObject("\(gender)", forKey: "gender" as NSCopying)
//            dicResult.setObject("\(province)", forKey: "province" as NSCopying)
//            
//            UserDefaults.standard.set(dicResult, forKey: optionKey)
//        }
//        
//        return NSDictionary(dictionary: dicResult)
//    }
//    
//   //   MARK: - Core Data
//    class func masterMOC() -> NSManagedObjectContext{
//        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        return appdelegate.masterMOC
//    }
//    
//    class func mainMOC() -> NSManagedObjectContext{
//        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        return appdelegate.mainMOC
//    }
//    
//    class func workerMOC() -> NSManagedObjectContext{
//        let appdelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        return appdelegate.workerMOC
//    }
    /*
    class func saveMOC(){
        MDataProvider.mainMOC().perform { () -> Void in
            do{
                try MDataProvider.mainMOC().save()
            }catch let error as NSError{
                print("Main Error:\(error.localizedDescription),\(error.localizedFailureReason),\(error.userInfo)")
                
                if let detailedErrors = error.userInfo[NSDetailedErrorsKey] as? [NSError]{
                    for detailedError in detailedErrors{
                        print("Detail Error:\(detailedError.userInfo)")
                    }
                }


            }
//            _ = try? MDataProvider.mainMOC().save()
        }
        
        MDataProvider.masterMOC().perform { () -> Void in
            do{
                try MDataProvider.masterMOC().save()
            }catch let error as NSError{
                print("Master Error:\(error.localizedDescription),\(error.localizedFailureReason),\(error.userInfo)")
            }
//            _ = try? MDataProvider.masterMOC().save()
        }
    }
    
    class func numberOfUnreadPM() -> Int{
        var newnum = 0
        SWUtils.RunOnMainThread { () -> Void in
            let fetchRequest = NSFetchRequest<SWCDUser>()
            let userEntity = NSEntityDescription.entity(forEntityName: "User", in: MDataProvider.mainMOC())
            let predicate = NSPredicate(format: "newnum>0 && lastcontact>%@ && uid!=%@ && uid>0",Date(timeIntervalSince1970: 0) as CVarArg,MDataProvider.myUID()!)
            let sort = NSSortDescriptor(key: "uid", ascending: true)
            
            fetchRequest.entity = userEntity
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sort]
            
   
            if let ary = try? MDataProvider.mainMOC().fetch(fetchRequest){
                for u in ary{
                    newnum += u.newnum?.intValue ?? 0
                }
            }
            
            
            
        }
        
        return newnum
    }
   
    
    class func ifHasPM() -> Bool{
        var ifHasMessage = false
        SWUtils.RunOnMainThread { () -> Void in
            let fetchRequest = NSFetchRequest<SWCDUser>()
            let userEntity = NSEntityDescription.entity(forEntityName: "User", in: MDataProvider.mainMOC())
            let predicate = NSPredicate(format: "lastcontact>%@ && uid!=%@ && uid>0",Date(timeIntervalSince1970: 0) as CVarArg,MDataProvider.myUID()!)
            let sort = NSSortDescriptor(key: "uid", ascending: true)
            
            fetchRequest.entity = userEntity
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sort]
            
            
            if let ary = try? MDataProvider.mainMOC().fetch(fetchRequest){
                ifHasMessage = ary.count > 0
            }
        }
        
        return ifHasMessage
    }
 */   
   
   //   MARK: - Image
    class func getImage(_ avatar: String?) -> String?{
        if  let str = avatar{
            return String(format: "%@?imageView2/1/w/150/h/150", str)
        }else{
            return nil
        }
        
    }
    
    class func getContentImage(_ avatar: String?) -> String?{
        if  let str = avatar{
            return String(format: "%@?imageView2/1/w/620/h/620", str)
        }else{
            return nil
        }
    }

    
    // MARK: - App Channel Functions
    class func channelID() -> String?{
        return nil
        /*
        var channel:String?
        
        let channelType = AppDelegate.channelType()

        switch channelType.rawValue{
        case MAppChannelType91.rawValue:
            channel = "91"
        case MAppChannelTypeKuaiYong.rawValue:
            channel = NSLocalizedString("快用", comment: "快用")
        case MAppChannelTypeTBT.rawValue:
            channel = NSLocalizedString("同步推", comment: "同步推")
        case MAppChannelTypeBeta.rawValue:
            channel = "Beta"
        default:()
        }
        
        return channel
 */
    }
    
    
//    class func showAlipay() -> Bool{
//        let locale = Locale.current
//        let countryCode: String! = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
//
//        let apple_reviewed = (UserDefaults.standard.object(forKey: "MosaicConfig") as? NSDictionary)?.bool(forKey: "apple_reviewed") ?? false
//        let channelType = AppDelegate.channelType()
//        
//        if (!apple_reviewed && MAppChannelTypeAppStore.rawValue == channelType.rawValue) || (countryCode != nil && countryCode.lowercased() != "cn"){
//            return false
//        }else{
//            return true
//        }
//        
//    }
//    
//    class func showApplePay() -> Bool{
//        if MAppChannelTypeAppStore.rawValue == AppDelegate.channelType().rawValue{
//            return true
//        }else{
//            return false
//        }
//    }
//    
    class func networkAvailable() -> Bool{
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appdelegate.currentNetworkStatus.rawValue != NotReachable.rawValue
    }

    class func currentNetworkStatus() -> NetworkStatus{
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        return appdelegate.currentNetworkStatus
    }
   


    
    
}
