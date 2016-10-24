//
//  ProjectUtils.swift
//  Affair
//
//  Created by Stan Wu on 15/10/21.
//  Copyright © 2015年 Stan Wu. All rights reserved.
//

import Foundation


struct ProjectDefinitions {
    static let MAX_AGE = 55,MIN_AGE = 20,MIN_HEIGHT = 150,MAX_HEIGHT = 200,MIN_WEIGHT = 40,MAX_WEIGHT = 100
    static let PurpleColor = UIColor(red: 0.66, green: 0.4, blue: 0.69, alpha: 1)
    static let SuperVIPColor = ProjectDefinitions.PurpleColor
    static let VIPColor = UIColor(red: 0.66, green: 0.4, blue: 0.69, alpha: 1)
    static let YellowColor = UIColor(red: 1, green: 0.7, blue: 0.2, alpha: 1)
    static let ThemeColor = UIColor(red: 0.33, green: 0.75, blue: 0.29, alpha: 1)
    static let OrangeColor = UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
    
    static let SUBJECT_OTHER_TAG = 1000
    
    static func area(_ province: Int,city: Int) -> String{
        let provinces = (MDataProvider.profilePlist().object(forKey: "profile") as! NSDictionary).object(forKey: "provinces") as! NSArray
        let cities = (MDataProvider.profilePlist().object(forKey: "profile") as! NSDictionary).object(forKey: "cities") as! NSArray
        
        if 0 == province{
            return NSLocalizedString("未填", comment: "未填")
        }else{
            let pstr = provinces.object(at: province) as! String
            let cstr = 0 == city ? "" : cities.object(at: city)
            
            return "\(pstr)\(cstr)"
        }
    }
    
}

struct ProjectNotifications{
    static let REFRESH_PROMPTS_UI = "PromptsUpdated"
    static let START_PLAYING_MESSAGE = "StartPlayingMessage"
    static let STOP_PLAYING_MESSAGE = "StopPlayingMessage"
    static let TRYST_DELETED = "TrystDeleted"
    static let REFRESH_PURCHASE_UI = "PurchaseUINeedsUpdate"
    static let REFRESH_TRYST_LIST = "RefreshTrystList"
    static let HIDE_TRYST_ACTIONS = "HideTrystActions"
    static let NEAR_SEARCH_OPTIONS_UPDATED = "NearSearchOptionsUpdated"
    static let STATUS_SEARCH_OPTIONS_UPDATED = "StatusSearchOptionsUpdated"
}

@objc protocol OACellDelegate: NSObjectProtocol{
    @objc func avatarDidClicked(_ dicInfo: NSDictionary?)
}
