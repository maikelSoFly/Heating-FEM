//
//  GlobalData.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 01.11.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

class GlobalData {
    /// Grid height.                        [m]
    let H:Double
    /// Grid width.                         [m]
    let B:Double
    /// Initial temperature.                [K]
    let t_start:Double
    /// Simulation time.                    [s]
    let tau:Double
    /// Simulation step time.               [s]
    var d_tau:Double
    /// Ambient temperature.                [K]
    let t_ambient:Double
    /// Ambient temperature on the left.    [K]
    let t_ambient_l:Double
    /// Ambient temperature on the right.   [K]
    let t_ambient_r:Double
    /// Heat transfer coefficient.          [W / m2 * K]
    let alfa_global:Double
    /// Specific heat.                      [J / kg * K]
    let c_global:Double
    /// Thermal conductivity.               [W/ m * K]
    let k_global:Double
    /// Density.                            [kg / m3]
    let ro_global:Double
    /// Number of nodes in a column.
    let nH:Int
    /// Number of nodes in a row.
    let nB:Int
    /// Number of all nodes.
    let nh:Int
    /// Number of all elements.
    let ne:Int
    /// Shape functions derivatives in respect to local Ksis.
    private(set) var iPoints_dNdKsi:[[Double]]
    /// Shape functions derivatives in respect to local Etas.
    private(set) var iPoints_dNdEta:[[Double]]
    /// Shape functions of local points.
    private(set) var shapeFunctionsVals:[[Double]]
    /// H matrix for current element. H = [H]+[C]/dT.
    private(set) var H_current:[[Double]]
    /// H matrix for entire grid. H = [H]+[C]/dT.
    private(set) var H_global:[[Double]]
    /// P vector for current element. P = {P}+{[C]/dT}*{t0}.
    private(set) var P_current:[Double]
    /// P vector for entire grid. P = {P}+{[C]/dT}*{t0}.
    private(set) var P_global:[Double]
    let grid:Grid
    private(set) var localElement:LocalElement
    /// Gauss's integration points with anti-clockwise direction from left-bottom.
    let points2p = [
        [-0.577, -0.577],
        [0.577, -0.577],
        [0.577, 0.577],
        [-0.577, 0.577]
    ]
    
    enum ElementMaterial:String {
        case material0 = "Material (metal) from P.K."
        case glass = "Heat-resistant ceramic glass"
        case argon = "Argon"
    }
    
    
    
    init?(dict:Dictionary<String, Any>) {
        guard let H = dict["H"] as? Double else { return nil }
        self.H = H
        guard let B = dict["B"] as? Double else { return nil }
        self.B = B
        guard let nH = dict["nH"] as? Int else { return nil }
        self.nH = nH
        guard let nB = dict["nB"] as? Int else { return nil }
        self.nB = nB
        guard let t_start = dict["t_start"] as? Double else { return nil }
        self.t_start = t_start
        guard let tau = dict["tau"] as? Double else { return nil }
        self.tau = tau
        guard let d_tau = dict["d_tau"] as? Double else { return nil }
        self.d_tau = d_tau
        guard let t_ambient = dict["t_ambient"] as? Double else { return nil }
        self.t_ambient = t_ambient
        guard let t_ambient_l = dict["t_ambient_l"] as? Double else { return nil }
        self.t_ambient_l = t_ambient_l
        guard let t_ambient_r = dict["t_ambient_r"] as? Double else { return nil }
        self.t_ambient_r = t_ambient_r
        guard let alfa = dict["alfa"] as? Double else { return nil }
        self.alfa_global = alfa
        guard let c = dict["c"] as? Double else { return nil }
        self.c_global = c
        guard let k = dict["k"] as? Double else { return nil }
        self.k_global = k
        guard let ro = dict["ro"] as? Double else { return nil }
        self.ro_global = ro
        
        self.nh = nH * nB
        self.ne = (nH-1) * (nB-1)
        
        self.iPoints_dNdKsi = [[Double]]()
        self.iPoints_dNdEta = [[Double]]()
        self.shapeFunctionsVals = [[Double]]()
        
        self.localElement = LocalElement()
        
        self.H_global = Array(repeating: Array(repeating: Double(0), count: nh), count: nh)
        self.P_global = Array(repeating: Double(0), count: nh)
        self.H_current = Array(repeating: Array(repeating: Double(0), count: 4), count: 4)
        self.P_current = Array(repeating: Double(0), count: 4)
        
        self.grid = Grid()
        
        //MARK: - Initializing shape functions.
        let sfuncs = calculateShapeFunctions(integrationPoints: points2p)
        self.iPoints_dNdKsi = sfuncs.0
        self.iPoints_dNdEta = sfuncs.1
        self.shapeFunctionsVals = sfuncs.2
        
        //MARK: - Initializing local element.
        localElement = {
            var localNodes = Array(repeating: Node(), count: 4)
            for i in 0..<localNodes.count {
                localNodes[i] = Node(x: points2p[i][0], y: points2p[i][1])
            }
            let element = LocalElement(nodes: localNodes)
            
            return element
        }()
    }
    
    
    
    func createGrid(materialDefinition: ((Int, Int, Int, Int) -> Dictionary<String, Any>)? = nil) {
        //MARK: - Creating grid.
        if let def = materialDefinition {
            grid.createGrid(H: H, B: B, nH: nH, nB: nB, startTemp: t_start, materialDefinition: def)
        } else {
            grid.createGrid(H: H, B: B, nH: nH, nB: nB, startTemp: t_start)
        }
    }
    
    
    static func getParameters(for material:ElementMaterial) -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        
        switch material {
        case .material0:
            dict["material"] = ElementMaterial.material0
            dict["alfa"] = 300.0
            dict["c"] = 700.0
            dict["k"] = 25.0
            dict["ro"] = 7800.0
            break
        case .glass:
            dict["material"] = ElementMaterial.glass
            dict["alfa"] = 5.0
            dict["alfa_oven"] = 7.0
            dict["alfa_fan-forced_oven"] = 35.0
            dict["c"] = 850.0
            dict["k"] = 1.3
            dict["ro"] = 2550.0
        case .argon:
            dict["material"] = ElementMaterial.argon
            dict["c"] = 520.0
            dict["k"] = 0.017
            dict["ro"] = 1.7
        }
        
        return dict
    }
    
    
    /// Calculates values of shape functions for every integration point
    /// and their derivatives.
    ///
    /// - Parameter integrationPoints: 2d array of integration points coordinates.
    /// - Returns: three 2d arrays of dNdKsis, dNdEta and shape functions values for every
    /// integration point.
    func calculateShapeFunctions(integrationPoints:[[Double]]) -> ([[Double]], [[Double]], [[Double]]) {
        //  point[0] is Ksi,   point[1] is Eta
        var points_dNdKsi = [[Double]](), points_dNdEta = [[Double]](), shapeFunctions = [[Double]]()
        
        for point in integrationPoints {
            points_dNdKsi.append([
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .first, withRespectTo: .Ksi, x: point[1]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .second, withRespectTo: .Ksi, x: point[1]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .third, withRespectTo: .Ksi, x: point[1]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .fourth, withRespectTo: .Ksi, x: point[1])
            ])
            
            points_dNdEta.append([
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .first, withRespectTo: .Eta, x: point[0]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .second, withRespectTo: .Eta, x: point[0]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .third, withRespectTo: .Eta, x: point[0]),
                ShapeFunctionDefinition.derrValue(ofShapeFunction: .fourth, withRespectTo: .Eta, x: point[0])
            ])
            
            shapeFunctions.append([
                ShapeFunctionDefinition.value(ofShapeFunction: .first, ksi: point[0], eta: point[1]),
                ShapeFunctionDefinition.value(ofShapeFunction: .second, ksi: point[0], eta: point[1]),
                ShapeFunctionDefinition.value(ofShapeFunction: .third, ksi: point[0], eta: point[1]),
                ShapeFunctionDefinition.value(ofShapeFunction: .fourth, ksi: point[0], eta: point[1])
            ])
        }
        
        return (points_dNdKsi, points_dNdEta, shapeFunctions)
    }
    
    
    
    /// Computes H ( [H]+[C]/dT ) matrix and P ( {P}+{[C]/dT}*{t0} ) vector.
    func compute() {
        //MARK: - Initialize new global [H] matrix and {P} vector with zeros.
        H_global = Array(repeating: Array(repeating: Double(0), count: nh), count: nh)
        P_global = Array(repeating: Double(0), count: nh)

        
        /// Shape function's derivative with respect to x.
        var dNdx = Array(repeating: Double(), count: 4)
        /// Shape function's derivative with respect to y.
        var dNdy = Array(repeating: Double(), count: 4)
        /// X coordinates of current element's nodes.
        var coordsX = Array(repeating: Double(), count: 4)
        /// Y coordinates of current element's nodes.
        var coordsY = Array(repeating: Double(), count: 4)
        /// Temperatures of current element's nodes at current time step.
        var temperatures_start = Array(repeating: Double(), count: 4)
        /// Determinant of matrix.
        var detJ = 0.0
        /// Interpolated temperature of current integration point at current time step.
        var t0:Double
        /// i,j element of [C] matrix.
        var C_ij:Double
        
        
        //MARK: - Loop through every element in the grid.
        for element in grid.EL {
            //MARK: - Initialize element-local H matrix and P vector with zeros.
            self.H_current = Array(repeating: Array(repeating: Double(0), count: 4), count: 4)
            self.P_current = Array(repeating: Double(0), count: 4)
            //MARK: - Get heat simulation's parameters.
            // If element has its own heat simulation's parameters - use them.
            // Otherwise use global parameters from data.json.
            let alfa = element.alfa ?? alfa_global
            let c = element.c ?? c_global
            let k = element.k ?? k_global
            let ro = element.ro ?? ro_global
            
            //MARK: - Copy parameters of current element's nodes into arrays.
            for i in 0..<4 {
                coordsX[i] = element.ND[i].x
                coordsY[i] = element.ND[i].y
                temperatures_start[i] =  element.ND[i].temp
            }
            
            //MARK: - Loop through every integration point of the element.
            for ipi in 0..<4 {
                // Get jacobian corresponding to current integration point.
                let jacobian = Jacobian(intPoint: ipi, xs: coordsX, ys: coordsY, dNdKsis: iPoints_dNdKsi, dNdEtas: iPoints_dNdEta)
                detJ = abs(jacobian.det)
                let dNdKsi = iPoints_dNdKsi[ipi], dNdEta = iPoints_dNdEta[ipi]
                t0 = 0.0
                
                //MARK: - Compute dNdx and dNdy vectors and t0.
                for i in 0..<4 {
                    dNdx[i] = jacobian.matrixInverted[0][0] * dNdKsi[i] +
                              jacobian.matrixInverted[0][1] * dNdEta[i]
                    
                    dNdy[i] = jacobian.matrixInverted[1][0] * dNdKsi[i] +
                              jacobian.matrixInverted[1][1] * dNdEta[i]
                    
                    //MARK: - Interpolating temperature of current IP, from every other element's IPs.
                    t0 += temperatures_start[i] * shapeFunctionsVals[ipi][i]
                }
            
                //MARK: - Volume integral.
                for i in 0..<4 {
                    for j in 0..<4 {
                        C_ij = c * ro * shapeFunctionsVals[ipi][i] * shapeFunctionsVals[ipi][j] * detJ
                        H_current[i][j] += k * (dNdx[i] * dNdx[j] + dNdy[i] * dNdy[j]) * detJ + (C_ij / d_tau)
                        P_current[i] += (C_ij / d_tau) * t0
                    }
                }
            }
  
            
            //MARK: - BOUNDRY CONDITIONS.
            //MARK: - Loop through every border surface in current element.
            for (i, surface) in element.borderSurfaces.enumerated() {
                let siid = element.borderSurfacesIndexes[i]
                let t_ambient = surface.t_ambient ?? self.t_ambient
                
                // 0.5 * length of local surface.
                detJ = 0.5 * sqrt(pow(surface.ND[0].x - surface.ND[1].x, 2) +
                                 pow(surface.ND[0].y - surface.ND[1].y, 2))
             
                //MARK: - Area integral.
                let shapeFunc = localElement.localSF[siid].shapeFunctionsVals
                for i in 0..<2 {
                    for j in 0..<4 {
                        for k in 0..<4 {
                            H_current[j][k] += alfa * shapeFunc![i][j] * shapeFunc![i][k] * detJ
                        }
                        P_current[j] += alfa * t_ambient * shapeFunc![i][j] * detJ
                    }
                }
            }
            
            //MARK: - AGREGATION FROM LOCAL TO GLOBAL.
            for i in 0..<4 {
                let first = element.ND[i].iid
                for j in 0..<4 {
                    let next = element.ND[j].iid
                    H_global[first][next] += H_current[i][j]
                }
                P_global[first] += P_current[i]
            }
        }
    }
}
