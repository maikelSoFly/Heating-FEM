//
//  Integral.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 09.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

enum TabType {
    case t2p, t3p
}

class Integral: NSObject {
    static let tab2p:[[Double]] = [
        [1, -1/sqrt(3), 1],
        [2, 1/sqrt(3), 1]
    ]
    static let tab3p:[[Double]] = [
        [1, -0.7745, 5/9],
        [2, 0.0, 8/9],
        [3, 0.7745, 5/9]
    ]
    
    
    static func getDoubleIntegral(of function: (Double, Double) -> Double, type:TabType) -> Double {
        var sum:Double = 0.0
        let tab = (type == .t2p) ? Integral.tab2p : Integral.tab3p
        let npc = tab.count
        
        for i in 0..<npc {
            for j in 0..<npc {
                sum += function(tab[i][1], tab[j][1]) * tab[i][2] * tab[j][2]
            }
        }
        return sum
    }
}
