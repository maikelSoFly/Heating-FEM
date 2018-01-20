//
//  Grid.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class Grid {
    /// Array of all nodes.
    private(set) var ND:[Node]
    /// Array of all elements.
    private(set) var EL:[Element]
    
    
    
    init() {
        self.ND = [Node]()
        self.EL = [Element]()
    }
    
    init(nodes:[Node], elements:[Element]) {
        self.ND = nodes
        self.EL = elements
    }
    
    // MARK: - Creating grid.
    /// Creates grid of finite elements, translated to cartesian coordinates system.
    ///
    /// - Parameters:
    ///   - H: Height of element
    ///   - B: Width of element
    ///   - nH: Number of nodes vertically
    ///   - nB: Number of nodes horizontally
    /// - Returns: returns Grid object
    func createGrid(H:Double, B:Double, nH:Int, nB:Int, startTemp:Double,
                    materialDefinition: ((Int, Int, Int, Int) -> Dictionary<String, Any>)? = nil) {
       
        //MARK: - Memory alocating.
        var nodes = Array(repeating: Array(repeating: Node(), count: nH), count: nB)
        var elements = Array(repeating: Array(repeating: Element(), count: nH-1), count: nB-1)
        
        // MARK: Creating and initializing nodes.
        let elWidth = (B/Double(nB-1))
        let elHeight = (H/Double(nH-1))
        for i in 0..<nB {
            for j in 0..<nH {
                let x = Double(i) * elWidth
                let y = Double(j) * elHeight
                // Create boundry conditions
                let status = i == 0 || i == nB-1 /*|| j == 0 || j == nH-1*/ ? true : false
                nodes[i][j] = Node(x: x, y: y, status: status, id: i*nB + j, startTemp:startTemp)
            }
        }
        
        // MARK: Creating and initializing elements.
        for i in 0..<(nB-1) {
            for j in 0..<(nH-1) {
                let nodesForElement = [ nodes[i][j],
                                        nodes[i+1][j],
                                        nodes[i+1][j+1],
                                        nodes[i][j+1]
                ]
                // If meterial function is defined, create element with individual
                // heat siulation's parameters.
                // Otherwise create element without individual heat siulation's parameters.
                if let fun = materialDefinition {
                    elements[i][j] = Element(nodes: nodesForElement, iid: i*(nB-1) + j, parameters: fun(i, j, nB-1, nH-1))
                } else {
                    elements[i][j] = Element(nodes: nodesForElement, iid: i*(nB-1) + j)
                }
            }
        }
        
        // Flattening arrays with joined() method.
        self.ND = Array(nodes.joined())
        self.EL = Array(elements.joined())
    }
    
    
    func printGrid() {
        for element in EL {
            print("element \(element.iid)", terminator:":\t\t")
            for node in element.ND {
                print(node.status == true ? "•\(node.iid)" : node.iid, terminator:" ")
            }
            print()
        }
        print("\n\tNodes in system:\n")
        for i in (0..<globalData!.nB).reversed() {
            for j in 0..<globalData!.nH {
                let node = ND[j*globalData!.nH + i]
                print(node.status ? "\(node.iid)•" : node.iid, terminator:"\t")
            }
            print()
        }
    }
    
    
    func writeGrid(toJsonFile filename:String) {
        let JsonGrid = JSONSerializer.toJson(self, prettify: true)
        JsonParser.write(data: JsonGrid, toFile: filename)
    }
}

