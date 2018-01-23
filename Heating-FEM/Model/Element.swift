//
//  Element.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Element {
    /// Array of nodes.
    let ND:[Node]
    /// Array of surfaces.
    let SF:[Surface]
    /// Individual identifier.
    let iid:Int
    /// Array of border surfaces.
    private(set) var borderSurfaces:[Surface]
    /// Array of border surfaces indexes.
    private(set) var borderSurfacesIndexes:[Int]
    /// Designated material of element.
    private(set) var material:GlobalData.ElementMaterial
    //MARK: - Individual heat simulation's parameters.
    /// Heat transfer coefficient.          [W / m2 * C]
    private(set) var alfa:Double?
    /// Specific heat.                      [J / kg * C]
    private(set) var c:Double?
    /// Thermal conductivity.               [W/ m * C]
    private(set) var k:Double?
    /// Density.                            [kg / m3]
    private(set) var ro:Double?
    /// Ambient temperature on the left.    [C]
    private(set) var t_ambient_l:Double?
    /// Ambient temperature on the right.   [C]
    private(set) var t_ambient_r:Double?
    /// Specifies if element has individual heat simulation's parameters.
    private(set) var hasParams:Bool
    
    
    
    init(nodes:[Node], iid:Int, parameters:Dictionary<String, Any>? = nil) {
        self.ND = nodes
        self.iid = iid
        self.borderSurfacesIndexes = [Int]()
        self.borderSurfaces = [Surface]()
        if let params = parameters {
            self.material = params["material"] as? GlobalData.ElementMaterial ?? GlobalData.ElementMaterial.material0
            self.alfa = params["alfa"] as? Double
            self.c = params["c"] as? Double
            self.k = params["k"] as? Double
            self.ro = params["ro"] as? Double
            self.t_ambient_l = params["t_ambient_l"] as? Double ?? nil
            self.t_ambient_r = params["t_ambient_r"] as? Double ?? nil
            self.hasParams = true
        }
        else {
            material = .material0
            hasParams = false
        }
        
        
        self.SF = [
            Surface(node1: nodes[3], node2: nodes[0]),
            Surface(node1: nodes[0], node2: nodes[1]),
            Surface(node1: nodes[1], node2: nodes[2]),
            Surface(node1: nodes[2], node2: nodes[3])
        ]
        
        //MARK: - Counting border surfaces
        for (i, surface) in SF.enumerated() {
            if surface.ND[0].status == true && surface.ND[1].status == true {
                if i == 0 {
                    surface.t_ambient = t_ambient_l
                }
                else if i == 2 {
                    surface.t_ambient = t_ambient_r
                }
                borderSurfacesIndexes.append(i)
                borderSurfaces.append(surface)
            }
        }
    }
    
    init() {
        self.ND = [Node]()
        self.borderSurfacesIndexes = [Int]()
        self.borderSurfaces = [Surface]()
        self.material = .material0
        self.SF = [Surface]()
        self.iid = 0;
        self.hasParams = false
    }
    
    public func printNodes() {
        print("\n\nELEMENT \(self.iid).\n\nNode / Coords:\n")
        for node in ND {
            print("\tID: \(node.iid)\t[\(node.x), \(node.y)]")
        }
    }
}
