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

struct WayPoint: Equatable, Identifiable, Observable {
    
    var id: UUID = UUID()
    
    private let clicksToNauticalMile: Double = 0.539957
    
    static func == (lhs: WayPoint, rhs: WayPoint) -> Bool {
        lhs.sequence == rhs.sequence
    }
    
    /// This is the name you give the waypoint
    var name: String
    /// This is the location of the starting point measured in degrees latitude and longitude
    var location: CLLocation
    /// This is altitude in feet above mean sea level and represents what the aircraft altimeter shows.
    var altitude: Int
    /// These are the forecast winds at this altitude and this location
    var wind: Wind
    /// This is the intended magnetic course of the ground track to the next waypoint
    var courseFrom: Int
    /// This is the intended magnetic heading the plane must fly to follow the course
    func headingFrom() -> Int {
        return self.courseFrom + Int(self.magneticDeviation)
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
    var magneticDeviation: Double = 0.0

    /// This indicates the waypoint as been passed (true) or not (false) it is determined when
    /// the distance to the next waypoint stops decreasing and begins to increase.
    var isCompleted: Bool = false
    /// This is actual time used to get to this waypoint from the previous waypoint
    var actualTimeReached: Double?
    /// This is the actual aircraft location when it crosses the next waypoint. In this case "crosses"
    /// means the point of closes approach to the next waypoint location. Or when the distance to
    /// the next waypoint begins to increas.
    var actualLocation: CLLocation?
    /// This will be computed at the moment isCompleted changes from false to true and will be
    /// determined by the elapse time from crossing the previous waypoint to crossing this waypoint.
    /// It can then do simple math to determine speed to cross the distance in the recorded time.
    var actualGroundSpeed: Int?
    
    var distanceMode: DistanceMode = .nautical
    
    private(set) var formatter = NumberFormatter()
    private(set) var cancellable = Set<AnyCancellable>()
    
    func windPrintable() -> String {
        formatter.minimumIntegerDigits = 0
        var retValue = "\(formatter.string(from: wind.directionFrom as NSNumber) ?? "") @ \(formatter.string(from: wind.speed as NSNumber) ?? "")"
        if retValue == "0 @ 0" {
            retValue = "Calm"
        }
        return retValue
    }
    
    func estimateTime() -> String {
        var retValue: String = ""
        retValue = "\(Int(estimatedTimeReached/60)):"
        let seconds = Int(estimatedTimeReached.truncatingRemainder(dividingBy: 60))
        if seconds < 10 {
            retValue = retValue + "0\(seconds)"
        } else {
            retValue = retValue + "\(seconds)"
        }
        return retValue
    }
    
    func shortDistanceMode() -> String {
        let retValue : String
        switch distanceMode {
        case .standard:
            retValue = "SM"
        case .nautical:
            retValue = "NM"
        case .metric:
            retValue = "KM"
        }
        
        return retValue
    }
    
    mutating func computeCourseToWayPoint(_ nextPoint: WayPoint) -> (Int, Double) {
        let circle: Float = 360.0
        // This is location.distanct is in meters. Need to conver to nautical miles
        let distance: Double = round((self.location.distance(from: nextPoint.location) * clicksToNauticalMile) / 10) / 100
        let courseY = sin(self.location.coordinate.latitude - nextPoint.location.coordinate.latitude )
        let courseXpart1 = cos(self.location.coordinate.longitude) * sin(nextPoint.location.coordinate.longitude)
        let courseXpart2 = sin(self.location.coordinate.longitude) * cos(nextPoint.location.coordinate.longitude) * cos(nextPoint.location.coordinate.latitude - self.location.coordinate.latitude)
        let courseX = courseXpart1 - courseXpart2
        let courseRadian = atan2(courseY, courseX)
        let fRetValue = fmodf(circle + -Float(courseRadian) * (180.0 / Float.pi), circle)
        return (Int(fRetValue), distance)
    }
    
    func computeHeadingToWayPoint(_ nextPoint: WayPoint) -> Double {
        var retValue = self.courseFrom
        // We need magnetic variation
        retValue = retValue + Int(self.magneticDeviation)
        
        // We need the effect of wind at altitude too
        return Double(retValue)
    }
}
