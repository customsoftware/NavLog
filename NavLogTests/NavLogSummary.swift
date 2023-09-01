//
//  NavLogSummary.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 8/31/23.
//

import XCTest
@testable import NavLog


final class NavLogSummary: XCTestCase {

    let navEngine = NavigationEngine()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSummaryFuel() throws {
        guard var testLog = navEngine.buildTestNavLog() else {
            XCTFail("Test Log didn't build")
            return
        }
        
        var sumFuel = testLog.fuelRemaining()
        XCTAssertEqual(sumFuel, 32.3, "Should be the same: 32.3")
 
        testLog.log[0].isCompleted = true
        testLog.log[1].isCompleted = true
        testLog.log[2].isCompleted = true
        testLog.log[3].isCompleted = true
        testLog.log[4].isCompleted = true
        testLog.log[5].isCompleted = true

        sumFuel = testLog.fuelRemaining()
        XCTAssertEqual(sumFuel, 27.0, "Should be the same: 27.0")
    }
    
    func testFuelExhaustion() throws {
        guard var testLog = navEngine.buildTestNavLog() else {
            XCTFail("Test Log didn't build")
            return
        }
        
        testLog.log[0].isCompleted = true
        testLog.log[1].isCompleted = true
        testLog.log[2].isCompleted = true
        testLog.log[3].isCompleted = true
        
        let testAircraft = navEngine.buildTestAircraft()
        
        let timeToExhaustion = testLog.timeToFuelExhaustion(aircraft: testAircraft)
        
        XCTAssertEqual(timeToExhaustion, 3.17, "Should be 3.17 hours")
    }
    
    func testWayPointDetermination() throws {
        guard var testLog = navEngine.buildTestNavLog() else {
            XCTFail("Test Log didn't build")
            return
        }
        
        testLog.log[0].isCompleted = true
        testLog.log[1].isCompleted = true
        testLog.log[2].isCompleted = true
        testLog.log[3].isCompleted = true

        XCTAssertNotNil(testLog.activeWayPoint()?.name, "There is an active waypoint")
        
        if let activeName = testLog.activeWayPoint()?.name {
            XCTAssertEqual(activeName, "VPWBR-US", "It should be VPWBR-US")
        }
        
        XCTAssertNotNil(testLog.previousWayPoint()?.name, "There is a previous waypoint")
        
        if let previousName = testLog.previousWayPoint()?.name {
            XCTAssertEqual(previousName, "VPPTM-US", "It should be VPPTM-US")
        }
    }
    
    func testWayPointAtStart() throws {
        guard let testLog = navEngine.buildTestNavLog() else {
            XCTFail("Test Log didn't build")
            return
        }
        
        XCTAssertNotNil(testLog.activeWayPoint()?.name, "There is an active waypoint")
        
        if let activeName = testLog.activeWayPoint()?.name {
            XCTAssertEqual(activeName, "KPVU", "It should be KPVU")
        }
        
        XCTAssertNil(testLog.previousWayPoint()?.name, "There should be no previous waypoint")
    }
    
    func testWayPointAtEnd() throws {
        guard var testLog = navEngine.buildTestNavLog() else {
            XCTFail("Test Log didn't build")
            return
        }
        
        testLog.log[0].isCompleted = true
        testLog.log[1].isCompleted = true
        testLog.log[2].isCompleted = true
        testLog.log[3].isCompleted = true
        testLog.log[4].isCompleted = true
        testLog.log[5].isCompleted = true
        
        XCTAssertNil(testLog.activeWayPoint()?.name, "There is no active waypoint")
        
        if let activeName = testLog.activeWayPoint()?.name {
            XCTAssertEqual(activeName, "KOGD", "It should be KOGD")
        }
        
        XCTAssertNotNil(testLog.previousWayPoint()?.name, "There should be no previous waypoint")
        
        if let previousWayPoint = testLog.activeWayPoint()?.name {
            XCTAssertEqual(previousWayPoint, "KOGD", "It should be KOGD")
        }
    }
}
