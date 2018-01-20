//
//  Solver.swift
//  FEM-GUI
//
//  Created by Mikołaj Stępniewski on 04.01.2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Solver {
    static func gaussElimination(n:Int, gk:[[Double]], rk:[Double]) -> [Double] {
        
        var m:Double, s:Double, e:Double = pow(10, -12)
        var results = Array(repeating: Double(), count: n)
        
        var tabAB = Array(repeating: Array(repeating: Double(), count: n+1), count: n)
        
        for i in 0..<n {
            for j in 0..<n {
                tabAB[j][i] = gk[j][i]
            }
        }
        
        for i in 0..<n {
            tabAB[i][n] = rk[i]
        }
        
        for i in 0..<(n-1) {
            for j in (i+1)..<n {
                if abs(tabAB[i][i]) < e {
                    print("Solver ERROR: NaN")
                    break
                }
                
                m = -tabAB[j][i] / tabAB[i][i]
                for k in 0..<(n+1) {
                    tabAB[j][k] += m * tabAB[i][k]
                }
            }
        }
        
        for i in (0...(n-1)).reversed() {
            s = tabAB[i][n]
            for j in (0...(n-1)).reversed() {
                s -= tabAB[i][j] * results[j]
            }
            if abs(tabAB[i][i]) < e {
                print("Solver ERROR: NaN")
                break
            }
            results[i] = s/tabAB[i][i]
        }
        
        return results
    }
}
