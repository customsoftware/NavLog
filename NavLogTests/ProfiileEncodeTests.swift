//
//  ProfiileEncodeTests.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 11/15/23.
//

import XCTest
@testable import NavLog

final class ProfiileEncodeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() throws {
        let t1 = TakeOffWeight(weight: 2350, roll: 738)
        let t2 = TakeOffWeight(weight: 2200, roll: 640)
        let t3 = TakeOffWeight(weight: 1900, roll: 458)

        let m1 = Multiple(elevation: 0, multiple: 1)
        let m2 = Multiple(elevation: 2500, multiple: 1.118)
        let m3 = Multiple(elevation: 5000, multiple: 1.118)
        let m4 = Multiple(elevation: 7500, multiple: 1.118)
        
        let w1 = WindMultiples(wind: 10, weight: 1900, multiple: 0.4444, for50: false)
        let w2 = WindMultiples(wind: 10, weight: 1900, multiple: 0.4444, for50: false)
        
        let performance = PerformanceProfile(takeoff: [t3, t2, t1], 
                                             multipliers: [m1, m2, m3, m4],
                                             multipliers50: [m1, m2, m3, m4],
                                             temperatureBand: 20,
                                             temperatureDeltaRate: 0.1,
                                             windrates: [w1, w2], seatCount: 4
        )

        let encoder = JSONEncoder()
        do {
            let theJSON = try encoder.encode(performance)
            print("Done")
        } catch let error {
            XCTFail("An error occured: \(error.localizedDescription)")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
