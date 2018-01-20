//
//  JSONParser.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

open class JsonParser: NSObject {
    open static func getDictionary(fromFile filename:String, ofType type:String) -> Dictionary<String, Any>? {
        var dictionary:Dictionary<String, Any>?
        
        if let path = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                dictionary = jsonResult as? Dictionary<String, Any>
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path")
        }

        return dictionary
    }
    
    open static func write(data:String, toFile filename:String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(filename)
       
            do {
                try data.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Writing to file error: \(error.localizedDescription)")
            }
            print("\n\tWrite to file succeeded\n\t\(fileURL)")
        } else {
            print("FileManager error")
        }
    }
}
