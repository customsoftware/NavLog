//
//  NavLogDistanceTests.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 8/23/23.
//

import XCTest
import CoreLocation
@testable import NavLog

final class NavLogDistanceTests: XCTestCase {

    var defaluts: UserDefaults = UserDefaults()
    var locations: [CLLocation] = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        locations = getTestLocations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStandardDistance() throws {
        defaluts.setValue("Standard", forKey: Constants.velocityMode)
        XCTAssertNotNil(defaluts.value(forKey: Constants.velocityMode), "There should be a valid mode")
        
        let distance = try TimeToLocationCalculator.calculateDistanceToNextWaypoint(locations[0], destination: locations[1])
        let mode = DistanceMode(rawValue: defaluts.value(forKey: Constants.velocityMode) as! String)
        XCTAssertEqual(distance, 3.7, "They should be the same distance in \(mode?.rawValue ?? "Not set")")
    }
    
    func testMetricDistance() throws {
        
        defaluts.setValue("Metric", forKey: Constants.velocityMode)
        let distance = try TimeToLocationCalculator.calculateDistanceToNextWaypoint(locations[0], destination: locations[1])
        let mode = DistanceMode(rawValue: defaluts.value(forKey: Constants.velocityMode) as! String)
        XCTAssertEqual(distance, 5.9, "They should be the same distance in \(mode?.rawValue ?? "Not set")")
        
    }
    
    func testNauticalDistance() throws {
        defaluts.setValue("Knots", forKey: Constants.velocityMode)
        XCTAssertNotNil(defaluts.value(forKey: Constants.velocityMode), "There should be a valid mode")
        
        let distance = try TimeToLocationCalculator.calculateDistanceToNextWaypoint(locations[0], destination: locations[1])
        let mode = DistanceMode(rawValue: defaluts.value(forKey: Constants.velocityMode) as! String)
        XCTAssertEqual(distance, 3.2, "They should be the same distance in \(mode?.rawValue ?? "Not set")")
    }
    
    func getTestLocations() -> [CLLocation] {
        let location1 = CLLocation(latitude: 111.566, longitude: 40.355)
        let location2 = CLLocation(latitude: 111.600, longitude: 40.466)
        return [location1, location2]
    }
}
