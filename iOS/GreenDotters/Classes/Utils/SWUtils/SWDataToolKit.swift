//
//  SWDataToolKit.swift
//  ReservationClient
//
//  Created by Stan Wu on 15/3/29.
//  Copyright (c) 2015 Stan Wu. All rights reserved.
//

import Foundation
import UIKit
import AdSupport
import CommonCrypto
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


extension String{
    static func UUIDString() -> String{
        var UUID : String?

        let device = UIDevice.current
        if device.responds(to: #selector(getter: UIDevice.identifierForVendor)) {
            UUID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }else{
            UUID = UserDefaults.standard.object(forKey: "UUID") as! String?
            if UUID == nil{
                let uuidref:CFUUID = CFUUIDCreate(nil);
                let uuidstr:CFString = CFUUIDCreateString(nil, uuidref);
                UUID = uuidstr as String;
                
                UserDefaults.standard.set(UUID!, forKey: "UUID")
            }
        }

        
        return UUID!;
    }
        
    func HMACSHA1StringWithKey(_ key: String) -> String{
        
        return self.hmac(key: key, algorithm: HMAC.Algorithm.sha1)!.uppercased()
    }
    
    func bundlePath() -> String{
        return Bundle.main.path(forResource: self, ofType: nil)!
    }
    
    var imageCachePath: String{
        get{
            var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
            
            let imagesPath = (paths[0] as NSString).appendingPathComponent("images")
            
            if !FileManager.default.fileExists(atPath: imagesPath){
                do {
                    try FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            if !UserDefaults.standard.bool(forKey: "ImageDirectoryExcluded"){
                let url = URL(fileURLWithPath: imagesPath)
                
                //            var error:NSError?
                var success: Bool
                do {
                    try (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                    success = true
                } catch _ as NSError {
                    //                error = error1
                    success = false
                }
                
                if success{
                    UserDefaults.standard.set(true, forKey: "ImageDirectoryExcluded")
                }
            }
            
            let path = (imagesPath as NSString).appendingPathComponent(self)
            
            return path;
        } 
    }
    
    var mediaCachePath: String{
        get{
            var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
            
            let imagesPath = (paths[0] as NSString).appendingPathComponent("medias")
            
            if !FileManager.default.fileExists(atPath: imagesPath){
                do {
                    try FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            if !UserDefaults.standard.bool(forKey: "MediaDirectoryExcluded"){
                let url = URL(fileURLWithPath: imagesPath)
                
                //            var error:NSError?
                var success: Bool
                do {
                    try (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                    success = true
                } catch _ as NSError {
                    //                error = error1
                    success = false
                }
                
                if success{
                    UserDefaults.standard.set(true, forKey: "MediaDirectoryExcluded")
                }
            }
            
            let path = (imagesPath as NSString).appendingPathComponent(self)
            
            return path;
        }
    }
    
    var documentPath: String{
        get{
            var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
            
            let path = (paths[0] as NSString).appendingPathComponent(self)
            
            return path
        }
        
    }
    
    var documentURL: URL{
        get{
            return URL(fileURLWithPath: self.documentPath)
        }
    }
    
    var temporaryPath: String{
        get{
            var paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
            
            let imagesPath = (paths[0] as NSString).appendingPathComponent("tmp")
            
            if !FileManager.default.fileExists(atPath: imagesPath){
                do {
                    try FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                }
            }
            
            if !UserDefaults.standard.bool(forKey: "TmpDirectoryExcluded"){
                let url = URL(fileURLWithPath: imagesPath)
                
                //            var error:NSError?
                var success: Bool
                do {
                    try (url as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
                    success = true
                } catch _ as NSError {
                    //                error = error1
                    success = false
                }
                
                if success{
                    UserDefaults.standard.set(true, forKey: "TmpDirectoryExcluded")
                }
            }
            
            let path = (imagesPath as NSString).appendingPathComponent(self)
            
            return path;
        }
        
        
    }
    
    var temporaryURL: URL{
        get{
            return URL(fileURLWithPath: self.temporaryPath)
        }
    }

    func isValidPhone() -> Bool{
        let phoneRegex = "^1\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        
        return phoneTest.evaluate(with: self)
    }
    
    var length: Int{
        return self.characters.count
    }
    
    func drawInRect(_ rect: CGRect, withAttributes attrs: [String : Any]?){
        (self as NSString).draw(in: rect, withAttributes: attrs)
    }
    
    func URLEncodedString() -> String{
        let mutstr = NSMutableString()
        
        if let data = self.data(using: String.Encoding.utf8){
            let a = (data as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: data.count)
            let len = data.count
            
            for i in 0..<len{
                let c:Character = Character(UnicodeScalar(a[i]))
                if ((c>="a" && c<="z") || (c>="A" && c<="Z") || (c>="0" && c<="9") || c=="." || c=="-"){
                    mutstr.appendFormat("%c", a[i])
                }else{
                    mutstr.appendFormat("%%%02x", CUnsignedInt(a[i]))
                }
            }
        }
        
        return mutstr as String
    }
    
    func numberOfLinesForString(_ size: CGSize, font: UIFont) -> Int {
        let textStorage = NSTextStorage(string: self, attributes: [NSFontAttributeName: font])
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.textStorage = textStorage
        layoutManager.addTextContainer(textContainer)
        
        var numberOfLines = 0
        var index = 0
        var lineRange : NSRange = NSMakeRange(0, 0)
        
        while index < layoutManager.numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            index += 1
        }
 
        
        return numberOfLines
    }
        
}

extension Data{
    func MD5String() -> String{
        return self.md5.hex.uppercased()
    }
    
    func SHA1String() -> String{
        return self.sha1.hex.uppercased()
    }
    
    
    func hmac_sha1(_ data: Data, key: Data) -> (Data?) {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))
        if (result != nil) {
            CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
                (key as NSData).bytes, size_t(key.count),
                (data as NSData).bytes, size_t(data.count),
                result!.mutableBytes)
        }
        return result as (Data?)
    }
}

extension Date{
    func dateString() -> String{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        formatter.dateFormat = "yyyy-MM-dd"
        var strDate = formatter.string(from: self)
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date1 = formatter.string(from: self)
        let date2 = formatter.string(from: Date())
        
        if date1==date2{
            formatter.dateFormat = "HH:mm"
            
            var timeInterval = Date().timeIntervalSince(self)
            if timeInterval < 0{
                timeInterval = 0
            }
            
            if timeInterval > 3600{
                strDate = NSLocalizedString("今天", comment: "今天") + "\(formatter.string(from: self))"
            }else{
                let min = Int(timeInterval/60)
                strDate = "\(min)" + NSLocalizedString("分钟前", comment: "分钟前")
            }
        }else{
            formatter.dateFormat = "yyyy-MM-dd 00:00"
            let tempdate = formatter.date(from: formatter.string(from: Date()))
            if tempdate?.timeIntervalSince(self) < 3600*24{
                formatter.dateFormat = "HH:mm"
                
                strDate = NSLocalizedString("昨天", comment: "昨天") + "\(formatter.string(from: self))"
            }else{
                formatter.dateFormat = "yyyy"
                let date1 = formatter.string(from: self)
                let date2 = formatter.string(from: Date())
                
                if date1==date2{
                    formatter.dateFormat = "MM-dd HH:mm"
                    strDate = formatter.string(from: self)
                }
            }
        }

        return strDate;
    }
}
