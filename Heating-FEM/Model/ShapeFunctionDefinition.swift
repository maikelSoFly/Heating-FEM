//
//  ShapeFunctionDefinition.swift
//  FEM
//
//  Created by Mikołaj Stępniewski on 06.12.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import Foundation

/// Static class, which defines shape functions and their derivatives.
class ShapeFunctionDefinition {
    
    private init() {}
    
    enum ShapeFunctions:Int {
        case first = 0
        case second = 1
        case third = 2
        case fourth = 3
    }
    
    enum LocalCoordinates {
        case Ksi
        case Eta
    }
    
    enum GlobalCoordinates {
        case x
        case y
    }
    
    
    static func value(ofShapeFunction fun:ShapeFunctions, ksi:Double, eta:Double) -> Double {
        switch fun {
        case .first:
            return (0.25)*(1-ksi)*(1-eta)
        case .second:
            return (0.25)*(1+ksi)*(1-eta)
        case .third:
            return (0.25)*(1+ksi)*(1+eta)
        case .fourth:
            return (0.25)*(1-ksi)*(1+eta)
        }
    }
    
    static func derrValue(ofShapeFunction fun:ShapeFunctions, withRespectTo lclCoord:LocalCoordinates, x:Double) -> Double {
        switch fun {
        case .first:
            return lclCoord == .Ksi ? (-0.25)*(1-x) : (-0.25)*(1-x)
        case .second:
            return lclCoord == .Ksi ? (0.25)*(1-x) : (-0.25)*(1+x)
        case .third:
            return lclCoord == .Ksi ? (0.25)*(1+x) : (0.25)*(1+x)
        case .fourth:
            return lclCoord == .Ksi ? (-0.25)*(1+x) : (0.25)*(1-x)
        }
    }
}
