//
//  WayPoint.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//
// https://www.visualcrossing.com/resources/documentation/weather-api/timeline-weather-api/

import Foundation
import CoreLocation
import Combine

struct WayPoint: Equatable, Identifiable, Observable, Codable {

    static func == (lhs: WayPoint, rhs: WayPoint) -> Bool {
        lhs.sequence == rhs.sequence
    }

    var id: UUID = UUID()
    
    /// This is the name you give the waypoint
    var name: String
    /// This is the location of the starting point measured in degrees latitude and longitude
    var location: CLLocation {
        let aLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return aLocation
    }
    var latitude: Double = 0.0
    
    var longitude: Double = 0.0
    
    /// This is altitude in feet above mean sea level and represents what the aircraft altimeter shows.
    var altitude: Int
    /// These are the forecast winds at this altitude and this location
    var wind: Wind
    /// This is the intended magnetic course of the ground track to the next waypoint
    var courseFrom: Int
    /// This is the intended magnetic heading the plane must fly to follow the course
    func headingFrom() -> Int {
        var retValue = self.courseFrom + Int(self.magneticDeviation)
        if retValue < 0 {
            retValue += 360
        }
        return retValue
    }
    /// This is the distance in nautical miles to the next waypoint
    var estimatedDistanceToNextWaypoint: Double
    /// This is the estimated ground speed the plane will be flying at towards the next waypoint
    var estimatedGroundSpeed: Int
    /// This is the estimated elapse time to the next waypoint, measured in seconds.
    var estimatedTimeReached: Double
    /// This is how much fuel is expected to be burned flying to that waypoint. It is computed by
    /// multiplying aircraft fuel burn rate by elapse time.
    var computedFuelBurnToNextWayPoint: Double
    /// This is the ordinal value of the waypoint in the array of waypoints that make up the navLog.
    /// Once the flight begins, this can not be changed.
    var sequence: Int = 0
    /// Distance to next location
    var distanceToNextWaypoint: Double = 0
    /// Magnetic deviation
    var magneticDeviation: Double = -10.5
    /// This indicates the waypoint as been passed (true) or not (false) it is determined when
    /// the distance to the next waypoint stops decreasing and begins to increase.
    var isCompleted: Bool = false
    /// This is actual time used to get to this waypoint from the previous waypoint
    var actualTimeReached: Double?
    /// This is the actual aircraft location when it crosses the next waypoint. In this case "crosses"
    /// means the point of closes approach to the next waypoint location. Or when the distance to
    /// the next waypoint begins to increas.
    var actualLongitude: Double?
    
    var actualLatitude: Double?
    
    var actualLocation: CLLocation? {
        guard let aLat = actualLatitude,
              let aLong = actualLongitude else { return nil }
        
        return CLLocation(latitude: aLat, longitude: aLong)
    }
    /// This will be computed at the moment isCompleted changes from false to true and will be
    /// determined by the elapse time from crossing the previous waypoint to crossing this waypoint.
    /// It can then do simple math to determine speed to cross the distance in the recorded time.
    var actualGroundSpeed: Int?
    
    var operationMode: OperationMode = .cruise

    var distanceMode: DistanceMode = .standard
    
    func windPrintable(formatter: NumberFormatter) -> String {
        formatter.minimumIntegerDigits = 0
        var retValue = "\(formatter.string(from: wind.directionFrom as NSNumber) ?? "") @ \(formatter.string(from: wind.speed as NSNumber) ?? "")"
        if retValue == "0 @ 0" {
            retValue = "Calm"
        }
        return retValue
    }
    
    /// This computes travel time in seconds to next waypoint
    func computeTimeToWaypoint() -> Double {
        guard estimatedGroundSpeed > 0,
              estimatedDistanceToNextWaypoint > 0 else { return 0 }
        // Speed is in mph or kph so divide by 3600 to get miles/second or kilometers/second
        let retValue = (3600.0/Double(estimatedGroundSpeed)) * estimatedDistanceToNextWaypoint
        return round(retValue)
    }
    
    
    /// This returns gallons per hour rounded to the nearest tenth of a gallon
    func estimatedFuelBurn(acData: AircraftPerformance) -> Double {
        let secondsToHoursRatio: Double = 3600
        let duration = computeTimeToWaypoint()
        let retValue: Double
        switch operationMode {
        case .climb:
            retValue = acData.aircraft.climbToAltitudeFuelBurnRate * (duration/secondsToHoursRatio)
        case .cruise:
            retValue = acData.aircraft.cruiseFuelBurnRate * (duration/secondsToHoursRatio)
        case .descend:
            retValue = acData.aircraft.descendingFuelBurnRate * (duration/secondsToHoursRatio)
        }
        return round(retValue * 100)/100
    }
    
    
    /// This renders a string equivalent of the time in seconds to the next waypoint. It returns the data in an mm:ss format. It assumes any leg to a waypoint will be less than one hour.
    func estimateTime() -> String {
        var retValue: String = ""
        let timeToWaypoint = computeTimeToWaypoint()
        retValue = "\(Int(timeToWaypoint)/60):"
        let seconds = Int(timeToWaypoint.truncatingRemainder(dividingBy: 60))
        if seconds < 10 {
            retValue = retValue + "0\(seconds)"
        } else {
            retValue = retValue + "\(seconds)"
        }
        return retValue
    }
    
    
    /// This computes the heading the plane should stear towards to fly the desisred course.
    /// - Parameters:
    ///     - nextPoint: WayPoint - this is the waypoint the plane flies to
    ///
    ///     This method has been verified against a Numbers spreadsheet. Note the explanation for the Atan2 variable placement.
    mutating func computeCourseToWayPoint(_ nextPoint: WayPoint) -> (Int, Double) {
        let circle: Float = 360.0
        // This is location.distanct is in meters. Need to convert to nautical miles
        let distance: Double = round((self.location.distance(from: nextPoint.location) * distanceMode.conversionValue) / 10) / 100
        
        let deltaLong = nextPoint.longitude - longitude
        let y = sin(deltaLong) * cos(nextPoint.latitude)
        let x = cos(latitude) * sin(nextPoint.latitude) - sin(latitude) * cos(nextPoint.latitude) * cos(deltaLong)
        // KTC: - Online resource for using atan2 in this process say it should be
        //  atan2(x, y) but testing shows for Swift 5.2 at least, it's reversed.
        let radValue = atan2(y, x)
        let degreeValue = radToDegrees(radValue)
        let retValue = 360 - ((Float(degreeValue) + circle).truncatingRemainder(dividingBy: circle))
        
        return (Int(retValue), distance)
    }
    
    func radToDegrees(_ radians: Double) -> Double {
        return (radians  * 180) / .pi
    }
}
