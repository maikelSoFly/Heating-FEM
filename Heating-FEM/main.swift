//
//  main.swift
//  Heating-FEM
//
//  Created by Mikołaj Stępniewski on 20/01/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

var globalData:GlobalData? = nil


/// Function which defines parameters for certain element, based
/// on its location in grid array.
///
/// - Parameters:
///   - i: "horizontal" position in array grid.
///   - j: "vertical" position in array grid.
///   - nB: number of elements horizontally.
///   - nH: number of elements vertically.
/// - Returns: Dictionary initialized with parameters for heating simulation.
private func elementMaterialDefinition(i:Int, j:Int, nB:Int, nH:Int) -> Dictionary<String, Any> {
    var params = Dictionary<String, Any>()
    
    // STRUCTURE OF OVEN WINDOW.
    
    if i >= 0 && i < 2 ||  i >= 9 && i < nB {
        params = GlobalData.getParameters(for: .glass)
    } else {
        params = GlobalData.getParameters(for: .argon)
    }
    
    if(i == 0) {
        params["t_ambient_l"] = globalData?.t_ambient_l
    }
    else if(i == nB-1) {
        params["t_ambient_r"] = globalData?.t_ambient_r
        params["alfa"] = params["alfa_fan-forced_oven"]
    }
    
    //return GlobalData.getParameters(for: .material0)
    
    return params
}


//MARK: - Main program.
if let dict = JsonParser.getDictionary(fromFile: "data", ofType: "json") {
    if let gd = GlobalData(dict: dict) {
        globalData = gd
        gd.createGrid(materialDefinition: elementMaterialDefinition)
        
        /// Temperatures of every node in grid.
        var temperatures:[Double]
        let noTimeSteps = gd.tau/gd.d_tau
        var heatMap = Array(repeating: Array(repeating: Array(repeating: Double(),
                                                              count: gd.nH),
                                             count: gd.nB),
                            count: Int(noTimeSteps)+1)
        
        for (step, tau) in stride(from: 0, to: gd.tau+gd.d_tau, by: gd.d_tau).enumerated() {
            print("[time: \(tau) s]")
            
            for i in (0 ..< gd.nB).reversed() {
                for j in (0 ..< gd.nH) {
                    let node = gd.grid.ND[j*gd.nH+i]
                    heatMap[step][i][j] = node.temp
                    
                    print(String(format: "%.2f", node.temp), terminator:"  ")
                }
                print()
            }
            print("\n\n")
            
            gd.compute()
            temperatures = Solver.gaussElimination(n: gd.nh, gk: gd.H_global, rk: gd.P_global)
            
            //MARK: - Set temperatures to nodes.
            for (i, node) in gd.grid.ND.enumerated() {
                node.temp = temperatures[i]
            }
            
        }
        //TODO: Save heatMap to .csv
        print(heatMap[5])
    } else {
        print("Typo in JSON data.")
    }
} else {
    print("JsonParser returned nil.")
}

