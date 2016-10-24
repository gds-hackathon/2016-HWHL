//
//  SWToolKit.swift
//  ReservationClient
//
//  Created by Stan Wu on 15/3/29.
//  Copyright (c) 2015 Stan Wu. All rights reserved.
//

import Foundation
import UIKit

struct SWDefinitions {
    static let ScreenWidth = UIScreen.main.bounds.width
    static let ScreenHeight = UIScreen.main.bounds.height
    
    static let RETURN_SUCCESS_CODE = 200
}

public func sw_dispatch_on_main_thread(_ block: ()->()){
    if Thread.isMainThread{
        block()
    }else{
        DispatchQueue.main.sync(execute: block)
    }
}

public func sw_dispatch_on_background_thread(_ block: @escaping ()->()){
    if !Thread.current.isMainThread{
        block()
    }else{
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            block()
        }
    }
}

class SWUtils{    
    class func RunOnMainThread(_ block: ()->()){
        if Thread.isMainThread{
            block()
        }else{
            DispatchQueue.main.sync(execute: block)
        }
    }
    
    class func RunOnBackgroundThread(_ block: @escaping ()->()){
        if !Thread.isMainThread{
            block()
        }else{
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                block()
            }
        }
    }
    
    class func is_jailbroken() -> Bool{
        return UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!)
    }
    
    class func area(_ province: Int?,city: Int?) -> String?{
        let p = province ?? 0
        let c = city ?? 0
        var area:String?
        if 0==province{
            area = nil
        }else{
            if 0==city{
                area = ((MDataProvider.profilePlist().object(forKey: "profile") as? NSDictionary)?.object(forKey: "provinces") as? NSArray)?.object(at: p) as? String
            }else{
                let strProvince = ((MDataProvider.profilePlist().object(forKey: "profile") as? NSDictionary)?.object(forKey: "provinces") as? NSArray)?.object(at: p) as? String
                let strCity = ((MDataProvider.profilePlist().object(forKey: "profile") as? NSDictionary)?.object(forKey: "cities") as? NSArray)?.object(at: c) as? String
                
                area = "\(strProvince!)\(strCity!)"
                if 0 == c{
                    return strProvince!
                }
            }
        }
        
        return area
    }
    
}
