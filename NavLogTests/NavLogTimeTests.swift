//
//  NavLogTimeTests.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 8/23/23.
//

import XCTest
import CoreLocation
@testable import NavLog

final class NavLogTimeTests: XCTestCase {

    var defaluts: UserDefaults = UserDefaults()
    var locations: [CLLocation] = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        locations = getTestLocations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStandardTimeToDistance() throws {
        defaluts.setValue("Standard", forKey: Constants.velocityMode)
        XCTAssertNotNil(defaluts.value(forKey: Constants.velocityMode), "There should be a valid mode")
        
        let timeToNext = try TimeToLocationCalculator.calculateTimeToNextLocation(locations[0], destination: locations[1], velocity: 100)
        print("Time to next at 100 mph: \(timeToNext)")
        XCTAssertEqual(timeToNext, 133, "They should be the same time in seconds")
    }
    
    func testMetricTimeToDistance() throws {
        
        defaluts.setValue("Metric", forKey: Constants.velocityMode)
        XCTAssertNotNil(defaluts.value(forKey: Constants.velocityMode), "There should be a valid mode")
        
        let timeToNext = try TimeToLocationCalculator.calculateTimeToNextLocation(locations[0], destination: locations[1], velocity: 100)
        print("Time to next at 100 kph: \(timeToNext)")
        XCTAssertEqual(timeToNext, 212, "They should be the same time in seconds")
        
    }
    
    func testKnotsTimeToDistance() throws {
        
        defaluts.setValue("Knots", forKey: Constants.velocityMode)
        XCTAssertNotNil(defaluts.value(forKey: Constants.velocityMode), "There should be a valid mode")
        
        let timeToNext = try TimeToLocationCalculator.calculateTimeToNextLocation(locations[0], destination: locations[1], velocity: 100)
        print("Time to next at 100 knots/hour: \(timeToNext)")
        XCTAssertEqual(timeToNext, 115, "They should be the same time in seconds")
        
    }
    
    func getTestLocations() -> [CLLocation] {
        let location1 = CLLocation(latitude: 111.566, longitude: 40.355)
        let location2 = CLLocation(latitude: 111.600, longitude: 40.466)
        return [location1, location2]
    }
}
