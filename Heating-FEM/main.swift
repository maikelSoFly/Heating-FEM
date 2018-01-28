//
//  main.swift
//  Heating-FEM
//
//  Created by Mikołaj Stępniewski on 20/01/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

var globalData:GlobalData? = nil
private let saveToFile = false
/// Save to file every nth time step.
private let saveToFileStride = 1
private let confFileName = "oven_conf"
private let ovenConvectionType:GlobalData.ConvectionType = .fanForced


func run() {
    if let dict = FileParser.getDictionary(fromJsonFile: confFileName) {
        if let gd = GlobalData(dict: dict) {
            globalData = gd
            gd.createMesh(materialDefinition: elementMaterialDefinition, boundryCondition: boundryCondition)
            gd.setStableTimeStep(forMaterial: .glass)
            
            
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
                        let node = gd.mesh.ND[j*gd.nB + i]
                        heatMap[step][i][j] = node.temp
                    }
                }
                
                //printTemperatures(arr: heatMap[step])
                
                var start = Date()
                gd.compute()
                print("\tCompute time: \(Date().timeIntervalSince(start))")
            
                start = Date()
                if let temperatures = Solver.gaussElimination(gk: Array(gd.H_global), rk: Array(gd.P_global)) {
                        //MARK: - Set temperatures to nodes.
                        for (i, node) in gd.mesh.ND.enumerated() {
                            node.temp = temperatures[i]
                        }
                }
                print("\tSolver time: \(Date().timeIntervalSince(start))\n")
                
                //MARK: - Save heatmap to file in /Documents directory.
                if saveToFile && step % saveToFileStride == 0 {
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
/// on its location in the mesh array.
///
/// - Parameters:
///   - i: "horizontal" position in the mesh.
///   - j: "vertical" position in the mesh.
///   - nB: number of elements horizontally.
///   - nH: number of elements vertically.
/// - Returns: Dictionary initialized with parameters for heating simulation.
private func elementMaterialDefinition(i:Int, j:Int, nB:Int, nH:Int) -> Dictionary<String, Any> {
    var params = Dictionary<String, Any>()
    let noElementsPerGlassPane = 5
    
    // STRUCTURE OF OVEN DOOR WINDOW.
    
    if i >= 0 && i < noElementsPerGlassPane || i >= nB-noElementsPerGlassPane && i < nB {
        params = GlobalData.getParameters(for: .glass)
    } else {
        params = GlobalData.getParameters(for: .argon)
    }

    if(i == 0) {
        let t_ambient = (globalData?.t_ambient_l)!
        params["t_ambient_l"] = t_ambient
        params["alpha"] = GlobalData.calculateAlpha(t_surf: (globalData?.t_start)!, t_ambient: t_ambient)
    }
    else if(i == nB-1) {
        let t_ambient = (globalData?.t_ambient_r)!
        params["t_ambient_r"] = t_ambient
        params["alpha"] = GlobalData.calculateAlpha(t_surf: (globalData?.t_start)!, t_ambient: t_ambient,
                                                    phi: ovenConvectionType.rawValue)
    }
    
    return params
}


private func boundryCondition(i:Int, j:Int, nB:Int, nH:Int) -> Bool {
    return  i == 0 || i == nB-1 ? true : false
}



let start = Date()
run()
print("Program executed in \(Date().timeIntervalSince(start)) seconds.")
