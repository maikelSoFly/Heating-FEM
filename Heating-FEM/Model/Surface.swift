//
//  Surface.swift
//  FEM-GUI
//
//  Created by Mikołaj Stępniewski on 03.01.2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Surface {
    /// Array of nodes.
    let ND:[Node]
    /// Optional shape function values for the nodes of surface.
    var shapeFunctionsVals:[[Double]]?
    /// Temperature of environment.
    var t_ambient:Double?
    
    
    
    init(node1:Node, node2:Node) {
        self.ND = [node1, node2]
    }
    
    init() {
        self.ND = [Node]()
    }
}
