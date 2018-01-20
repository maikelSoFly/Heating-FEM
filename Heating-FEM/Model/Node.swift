//
//  Node.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Node: NSObject {
    /// Global x coordinate.
    let x:Double
    /// Global y coordinate.
    let y:Double
    /// Border condition.
    let status:Bool
    /// Individual identifier.
    let iid:Int
    /// Current temperature.
    var temp:Double
    
    
    
    init(x:Double, y:Double) {
        self.x = x
        self.y = y
        self.status = false
        self.iid = -1
        self.temp = 0.0
    }
    
    init(x:Double, y:Double, status:Bool, id:Int, startTemp:Double) {
        self.x = x
        self.y = y
        self.status = status
        self.iid = id
        self.temp = startTemp
    }
    
    override init() {
        self.x = 0
        self.y = 0
        self.status = false
        self.iid = 0
        self.temp = 0.0
    }
}
