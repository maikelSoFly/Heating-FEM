//
//  JSONParser.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

open class FileParser: NSObject {
   static func getDictionary(fromJsonFile filename:String) -> Dictionary<String, Any>? {
        var dictionary:Dictionary<String, Any>?
        
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
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
    
    
    static func write(array:[[Double]], toFile filename:String) -> Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(filename)
            var data:String = ""
            for row in array {
                data += (row.map{String(describing: $0)}).joined(separator: ",") + "\n"
            }
            
            do {
                try data.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Writing to file error: \(error.localizedDescription)")
            }
            return true
        } else {
            return false
        }
    }
    
    
    static func write(data:String, toFile filename:String) -> Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(filename)
            
            do {
                try data.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Writing to file error: \(error.localizedDescription)")
            }
            return true
        } else {
            return false
        }
    }
}
