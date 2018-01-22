//
//  Solver.swift
//  FEM-GUI
//
//  Created by Mikołaj Stępniewski on 04.01.2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Solver {
    static func gaussElimination(gk:Array<Array<Double>>, rk:Array<Double>) -> Array<Double>? {
        var A = gk, b = rk
        let n = b.count
        let EPSILON = 1e-10
        
        for p in 0 ..< n {
            //MARK: - Find pivot row and swap.
            var max = p
            for i in (p+1) ..< n {
                if abs(A[i][p]) > abs(A[max][p]) {
                    max = i
                }
            }
            
            let temp = A[p]
            A[p] = A[max]
            A[max] = temp
            
            let t = b[p]
            b[p] = b[max]
            b[max] = t
            
            if abs(A[p][p]) <= EPSILON {
                print("Matrix is singular or nearly singular")
                return nil
            }
            
            //MARK: - Pivot within A and b.
            for i in (p+1) ..< n {
                let alpha = A[i][p] / A[p][p]
                b[i] -= alpha * b[p]
                for j in p ..< n {
                    A[i][j] -= alpha * A[p][j]
                }
            }
        }
        
        //MARK: - Back substitution.
        var x = Array(repeating: Double(), count: n)
        
        for i in (0...(n-1)).reversed() {
            var sum = 0.0
            for j in (i+1) ..< n {
                sum += A[i][j] * x[j]
            }
            x[i] = (b[i] - sum) / A[i][i]
        }
        
        return x
    }
}
