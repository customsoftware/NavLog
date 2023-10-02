//
//  WayPoint.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation
import CoreLocation

struct WayPoint: Identifiable {
    /// This is how it is identifieable
    var id: UUID = UUID()
    
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
    var headingFrom: Int
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
    
    func windPrintable() -> String {
        return "\(wind.directionFrom) @ \(wind.speed)"
    }
    
    func estimateTime() -> String {
        var retValue: String = ""
        retValue = "\(Int(estimatedTimeReached)):"
        let seconds = Int(estimatedTimeReached.truncatingRemainder(dividingBy: 1) * 60)
        retValue = retValue + "\(seconds)"
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
}
