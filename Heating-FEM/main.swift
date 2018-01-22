//
//  main.swift
//  Heating-FEM
//
//  Created by Mikołaj Stępniewski on 20/01/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

var globalData:GlobalData? = nil
fileprivate let saveToFile = false
fileprivate let _stride = 1
fileprivate let confFileName = "ovenConf"



func run() {
    if let dict = FileParser.getDictionary(fromJsonFile: confFileName) {
        if let gd = GlobalData(dict: dict) {
            globalData = gd
            gd.createGrid(materialDefinition: elementMaterialDefinition, borderConditions: borderConditions)
            gd.setStableTimeStep(for: .glass)
            
            let noTimeSteps = gd.tau/gd.d_tau
            var heatMap = Array(repeating: Array(repeating: Array(repeating: Double(),
                                count: gd.nH),
                                count: gd.nB),
                                count: Int(noTimeSteps)+1)
            
            //MARK: - Main loop.
            for (step, tau) in stride(from: 0, to: gd.tau+gd.d_tau, by: gd.d_tau).enumerated() {
                print("[⏰Time step: \(tau) s]")
                
                for i in (0 ..< gd.nB).reversed() {
                    for j in (0 ..< gd.nH) {
                        let node = gd.grid.ND[j*gd.nH+i]
                        heatMap[step][i][j] = node.temp
                    }
                }
                
                //printTemperatures(arr: heatMap[step])
                
                var start = Date()
                gd.compute()
                var end = Date()
                print("\tCompute time: \(end.timeIntervalSince(start))")
            
                start = Date()
                if let temperatures = Solver.gaussElimination(gk: Array(gd.H_global), rk: Array(gd.P_global)) {
                        //MARK: - Set temperatures to nodes.
                        for (i, node) in gd.grid.ND.enumerated() {
                            node.temp = temperatures[i]
                        }
                }
                end = Date()
                print("\tSolver time: \(end.timeIntervalSince(start))\n")
                
                //MARK: - Save heatmap to file in /Documents/ directory.
                if saveToFile && step % _stride == 0 {
                    _ = FileParser.write(array: heatMap[step], toFile: "Heating-FEM/heatmap-\(step).csv")
                }
            }
            
        } else {
            print("Typo in JSON data.")
        }
    } else {
        print("JsonParser returned nil.")
    }
}

private func printTemperatures(arr:[[Double]]) {
    for row in arr {
        for temp in row {
            print(String(format: "%.2f", temp), terminator:"  ")
        }
        print()
    }
    print("\n")
}



/// Function which defines parameters for certain element, based
/// on its location in grid array.
///
/// - Parameters:
///   - i: "horizontal" position in array grid.
///   - j: "vertical" position in array grid.
///   - nB: number of elements horizontally.
///   - nH: number of elements vertically.
/// - Returns: Dictionary initialized with parameters for heating simulation.
fileprivate func elementMaterialDefinition(i:Int, j:Int, nB:Int, nH:Int) -> Dictionary<String, Any> {
    var params = Dictionary<String, Any>()
    let noNodesPerGlassPane = 5
    
    // STRUCTURE OF OVEN DOOR WINDOW.
    
    if i >= 0 && i < noNodesPerGlassPane ||  i >= (nB-1)-noNodesPerGlassPane && i < nB {
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
    
    return params
}

fileprivate func borderConditions(i:Int, j:Int, nB:Int, nH:Int) -> Bool {
    return  i == 0 || i == nB-1 ? true: false
}


run()
