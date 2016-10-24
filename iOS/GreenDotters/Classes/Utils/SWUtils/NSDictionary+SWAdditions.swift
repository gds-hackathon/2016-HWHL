//
//  NSDictionary+SWAdditions.swift
//  Affair
//
//  Created by Stan Wu on 10/4/16.
//  Copyright © 2016 Stan Wu. All rights reserved.
//
import Foundation

extension NSDictionary{
    func int(forKey key: Any) -> Int? {
        if let str = self.object(forKey: key) as? NSString {
            return str.integerValue
        }
        
        return self.object(forKey: key) as? Int
    }
    
    func double(forKey key: Any) -> Double? {
        if let str = self.object(forKey: key) as? NSString {
            return str.doubleValue
        }
        
        return self.object(forKey: key) as? Double
    }
    
    func bool(forKey key: Any) -> Bool? {
        if let str = self.object(forKey: key) as? NSString {
            return str.boolValue
        }
        
        return self.object(forKey: key) as? Bool
    }
    
    func intValue(_ key: Any) -> Int {
        return self.int(forKey: key) ?? 0
    }
    
    func doubleValue(_ key: Any) -> Double {
        return self.double(forKey: key) ?? 0
    }
    
    func boolValue(_ key: Any) -> Bool {
        return self.bool(forKey: key) ?? false
    }
}
