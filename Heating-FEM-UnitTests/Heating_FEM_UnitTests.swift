//
//  Heating_FEM_UnitTests.swift
//  Heating-FEM-UnitTests
//
//  Created by Mikołaj Stępniewski on 23/01/2018.
//  Copyright © 2018 Mikołaj Stępniewski. All rights reserved.
//

import XCTest

class Heating_FEM_UnitTests: XCTestCase {
    private var defaultGlobalData:GlobalData!
    private var ovenGlobalData:GlobalData!
   
    
    override func setUp() {
        super.setUp()
        
        if let dict = FileParser.getDictionary(fromJsonFile: "default_conf") {
            self.defaultGlobalData = GlobalData(dict: dict)
        }
        
        if let dict = FileParser.getDictionary(fromJsonFile: "oven_conf") {
            self.ovenGlobalData = GlobalData(dict: dict)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
