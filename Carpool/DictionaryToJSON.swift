//
//  DictionaryToJSON.swift
//  ComeUp
//
//  Created by Eva on 17.05.16.
//  Copyright © 2016 Caroline. All rights reserved.
//

import Foundation

class DictionaryToJSON{
    
    static func create(dictionary: NSDictionary) -> NSData?{
        do {
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted);
        }
        catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    static func revert(json: String) -> [String:AnyObject]? {
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
}