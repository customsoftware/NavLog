//
//  UOMConversionTests.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 2/7/24.
//

import XCTest
import CoreLocation
@testable import NavLog

final class UOMConversionTests: XCTestCase {

    func testConvertCLLocationSpeed() throws {
        // CLLocation.speed is in meters per second. The app thinks in KPH, MPH and Knots. So this tests those conversions from a known standard value
        let startingSpeed = 20.0 // 20 meters per second. This is pretty fast
        
        let metricSpeedMode = SpeedMode.metric
        var newSpeed = round((startingSpeed * metricSpeedMode.modeModifier) * 100)/100
        XCTAssertTrue(newSpeed == 72.0, "It should be 72 KPH. It was \(newSpeed)")
        
        let standardSpeedMode = SpeedMode.standard
        newSpeed = round((startingSpeed * standardSpeedMode.modeModifier) * 100)/100
        XCTAssertTrue(newSpeed == 44.74, "It should be 44.7387 MPH. It was \(newSpeed)")
        
        
        let knotsSpeedMode = SpeedMode.nautical
        newSpeed = round((startingSpeed * knotsSpeedMode.modeModifier) * 100)/100
        XCTAssertTrue(newSpeed == 38.88, "It should be 38.8769 Knots. It was \(newSpeed)")
    }
    
    
    func testConvertCLLocationDistanceFine() throws {
        // CLLocation distance formula measures distance in meters. This converts to kilometers, standard and nautical miles
        let startingDistance = 10.0 // 100 Meters
        
        let metricDistanceMode = DistanceMode.metric
        var newDistance = round((startingDistance * metricDistanceMode.fineConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 10.0, "It should be 10 kilometers. It was \(newDistance)")
        
        let standardDistanceMode = DistanceMode.standard
        newDistance = round((startingDistance * standardDistanceMode.fineConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 32.81, "It should be 32.81 feet. It was \(newDistance)")
        
        
        let knotsDistanceMode = DistanceMode.nautical
        newDistance = round((startingDistance * knotsDistanceMode.fineConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 32.81, "It should be 32.81 feet. It was \(newDistance)")
    }
    
    func testConvertCLLocationDistanceCoarse() throws {
        // CLLocation distance formula measures distance in meters. This converts to kilometers, standard and nautical miles
        let startingDistance = 10000.0 // 100 Meters
        
        let metricDistanceMode = DistanceMode.metric
        var newDistance = round((startingDistance * metricDistanceMode.coarseConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 10.0, "It should be 10 kilometers. It was \(newDistance)")
        
        let standardDistanceMode = DistanceMode.standard
        newDistance = round((startingDistance * standardDistanceMode.coarseConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 6.21, "It should be 6.21 miles. It was \(newDistance)")
        
        
        let knotsDistanceMode = DistanceMode.nautical
        newDistance = round((startingDistance * knotsDistanceMode.coarseConversionValue) * 100)/100
        XCTAssertTrue(newDistance == 5.4, "It should be 5.4 nautical miles. It was \(newDistance)")
    }
}


// 2.23694 to standard MPH
// 1.94384 to knots
// 3.6 to clicks/hour
