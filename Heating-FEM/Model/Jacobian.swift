//
//  Jacobian.swift
//  FEM-GUI
//
//  Created by Mikołaj Stępniewski on 04.01.2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation


class Jacobian {
    /// Jacobian matrix itself.
    private(set) var matrix:[[Double]]
    /// Inverted jacobian matrix.
    let matrixInverted:[[Double]]
    /// Integration point for which the jacobian matrix is being calculated.
    let ipi:Int
    /// Shape functions derivatives with repspect to Ksi for integration point.
    let ips_dNdKsi:[[Double]]
    /// Shape functions derivatives with repspect to Eta for integration point.
    let ips_dNdEta:[[Double]]
    /// Determinant of jacobian matrix.
    let det:Double
   
    
    
    init(_ ipi:Int, xs:[Double], ys:[Double], dNdKsis:[[Double]],  dNdEtas:[[Double]]) {
        self.ips_dNdKsi = dNdKsis
        self.ips_dNdEta = dNdEtas
        self.ipi = ipi
        
        matrix = Array(repeating: Array(repeating: Double(0), count: 2), count: 2)
        
        for i in 0..<4 {
            matrix[0][0] += self.ips_dNdKsi[ipi][i] * xs[i]  // dxdKsi
            matrix[0][1] += self.ips_dNdKsi[ipi][i] * ys[i]  // dydKsi
            matrix[1][0] += self.ips_dNdEta[ipi][i] * xs[i]  // dxdEta
            matrix[1][1] += self.ips_dNdEta[ipi][i] * ys[i]  // dydEta
        }
        
        self.det = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
        let c = 1.0/det
    
        matrixInverted = [
            [matrix[1][1] * c, -matrix[0][1] * c],
            [-matrix[1][0] * c, matrix[0][0] * c]
        ]
    }
}
