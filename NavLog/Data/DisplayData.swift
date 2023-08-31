//
//  DisplayData.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/30/23.
//

import Foundation
import CoreLocation

struct DisplayData {
    /// This is read from app setting screen (UserDefaults)
    var mode: DisplayMode = .estimatedCentered
    /// This is read from app setting screen (UserDefaults)
    var velocityMode: DistanceMode = .nautical
    /// This is computed from GPS reciever
    var groundSpeedActual: Double
    /// We get this from WayPoint.estimatedGroundSpeed
    var groundSpeedEstimated: Double
    /// This is computed from GPS reciever
    var headingActual: Double
    /// We get this from WayPoint.headingFrom
    var headingEstimated: Double
    /// This is computed from GPS reciever
    var altitudeActual: Int
    /// We get this from WayPoint.altitude
    var altitudeEstimated: Int
    /// This is from a calibration entry. User taps calibrate button on display
    var altitudeOffset: Double
    /// This takes fuel load - estimated fuel burn - (estimated descent burn + estimated cruise remaining burn)
    var fuelRemaining: Int
    /// This takes distance to next waypoint / actual ground speed
    /// Distance to next waypoint is calculated by taking current position (from GPS) and
    ///  waypoint.location and calculating great arc distance using CoreLocation
    var timeToNext: Int
}


/// Now, do we have the display data object do some of the calculations?
/// No. We use individual components so we can unit test them
struct TimeToLocationCalculator {
    static func calculateTimeToNextLocation(_ currentLocation: CLLocation, destination: CLLocation, velocity: Int) throws -> Int {
        var retValue: Int = 0
        
        do {
            let distance : Double = try calculateDistanceToNextWaypoint(currentLocation, destination: destination)
            
            let timeToDistance = distance / Double(velocity)
            retValue = Int(timeToDistance * 3600)
            
        } catch {
            print("Error: \(error.localizedDescription)")
            
        }
        
        return retValue
    }
    
    static func calculateDistanceToNextWaypoint(_ currentLocation: CLLocation, destination: CLLocation) throws -> Double {
        let distanceInMeters = destination.distance(from: currentLocation)
        guard let modeString = UserDefaults().value(forKey: Constants.velocityMode) as? String else {
            throw DistanceCalculatorError.invalidMode
        }
        let realMode: DistanceMode
        if let aMode = DistanceMode(rawValue: modeString) {
            realMode = aMode
        } else {
            realMode = DistanceMode.nautical // This is the default
        }
        
        let distance : Double
        switch realMode {
        case .standard:
            distance = distanceInMeters * 0.000621371
        case .nautical:
            distance = distanceInMeters * 0.00053995663640604751
        case .metric:
            distance = distanceInMeters / 1000
        }
        
        return round(distance * 10)/10
    }
}


enum DistanceCalculatorError: Error {
    case invalidMode
}
