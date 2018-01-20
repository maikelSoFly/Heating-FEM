//
//  LocalElement.swift
//  FEM-GUI
//
//  Created by Mikołaj Stępniewski on 05.01.2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class LocalElement: NSObject {
    /// Array of nodes.
    let ND:[Node]
    /// Array of local surfaces.
    let localSF:[Surface]
   
    
    
    init(nodes:[Node]) {
        self.ND = nodes
        
        // Gauss's integration points for surface.
        self.localSF = [
            Surface(node1: Node(x: -1.0, y: 0.577), node2: Node(x: -1.0, y: -0.577)),
            Surface(node1: Node(x: -0.577, y: -1.0), node2: Node(x: 0.577, y: -1.0)),
            Surface(node1: Node(x: 1.0, y: -0.577), node2: Node(x: 1.0, y: 0.577)),
            Surface(node1: Node(x: 0.577, y: 1.0), node2: Node(x: -0.577, y: 1.0))
        ]
        
        //MARK: - Calculating shape functions values for surface's integration points.
        for i in 0..<4 {
            var shapeFunctionsVals = Array(repeating: Array(repeating: Double(), count: 4), count: 2)
            for j in 0..<2 {
                let x = localSF[i].ND[j].x
                let y = localSF[i].ND[j].y
                shapeFunctionsVals[j][0] = ShapeFunctionDefinition.value(ofShapeFunction: .first, ksi: x, eta: y)
                shapeFunctionsVals[j][1] = ShapeFunctionDefinition.value(ofShapeFunction: .second, ksi: x, eta: y)
                shapeFunctionsVals[j][2] = ShapeFunctionDefinition.value(ofShapeFunction: .third, ksi: x, eta: y)
                shapeFunctionsVals[j][3] = ShapeFunctionDefinition.value(ofShapeFunction: .fourth, ksi: x, eta: y)
            }
            localSF[i].shapeFunctionsVals = shapeFunctionsVals
        }
        
        super.init()
    }
    
    override init() {
        self.ND = [Node]()
        self.localSF = [Surface]()
    }
}
