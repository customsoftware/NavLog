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
import NavTool

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
    /// This is the intended true course of the ground track to the next waypoint
    var courseFrom: Int
    /// This is the wind corrected headingthe plane must fly to follow the course. Currently not completed so it mirrors
    /// just the courseFrom property
    func headingFrom() -> Int {
        var retValue = Double(self.courseFrom)
        if retValue < 0 {
            retValue += 360
        }
        return Int(round(retValue))
    }
    /// This is the distance in meters to the next waypoint.
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
    /// Magnetic deviation - CLLocation.course is based upon true north, so magnetic north is NOT needed for planning
    /// purposes. It is stored just incase of some future need.
    var magneticDeviation: Double = 0
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
        if round(wind.speed) == 0 {
            retValue = "Calm"
        }
        return retValue
    }
    
    /// This computes travel time in seconds to next waypoint. The value is rounded to the nearest second and uses
    /// stored properties of this waypoint
    func computeTimeToWaypoint() -> Double {
        guard estimatedGroundSpeed > 0,
              estimatedDistanceToNextWaypoint > 0 else { return 0 }
        
        var workingSpeed = Double(estimatedGroundSpeed)
        
        // Speed is in mph or kph so divide by 3600 to get miles/second or kilometers/second
        // If speed is in mph and distance is kn NM, we need to convert one or the other so we're making the correct calculations
        if (AppMetricsSwift.settings.distanceMode == .nautical &&
            AppMetricsSwift.settings.speedMode == .nautical) ||
           (AppMetricsSwift.settings.distanceMode == .standard &&
            AppMetricsSwift.settings.speedMode == .standard) ||
           (AppMetricsSwift.settings.distanceMode == .metric &&
            AppMetricsSwift.settings.speedMode == .metric) {
        } else {
            // Convert speed to distance
            if AppMetricsSwift.settings.distanceMode == .metric {
                // Convert speed to kilometers per hour
                if AppMetricsSwift.settings.speedMode == .nautical {
                    // Convert kts/hour to kph
                    workingSpeed = workingSpeed * 1.852
                } else {
                    // Convert mph to kph
                    workingSpeed = workingSpeed * 1.60934
                }
            } else if AppMetricsSwift.settings.distanceMode == .standard {
                // Convert speed to mile per hour
                if AppMetricsSwift.settings.speedMode == .nautical {
                    // Convert kts/hour to mph
                    workingSpeed = workingSpeed * 1.15078
                } else {
                    // Convert kph to mph
                    workingSpeed = workingSpeed * 0.621371
                }
            } else {
                // Convert speed to nautical miles per hour
                if AppMetricsSwift.settings.speedMode == .metric {
                    // Convert kph to kts/hour
                    workingSpeed = workingSpeed * 0.539957
                } else {
                    // Convert mph to kts/hour
                    workingSpeed = workingSpeed * 0.868976
                }
            }
        }
        let retValue = (3600.0/workingSpeed) * estimatedDistanceToNextWaypoint
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
    
    
    /// This renders a string equivalent of the time in seconds to the next waypoint. It returns the data in an mm:ss 
    /// format. It assumes any leg to a waypoint will be less than one hour.
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
    
    
    /// This computes distance between two CLLocations. It uses built in Apple function.
    /// - Parameters:
    ///     - nextPoint: WayPoint - this is the next plotted waypoint in the trip after this particular waypoint.
    ///  - Returns:
    ///     - Distance in meters between the two locations rounded to the nearest hundredth of a meter.
    func computeDistanceToNextWayPoint(_ nextPoint: WayPoint) -> Double {
        let distanceInMeters = self.location.distance(from: nextPoint.location)
        return round((distanceInMeters * AppMetricsSwift.settings.distanceMode.coarseConversionValue) * 10) / 10
    }
    
    
    /// This computes the heading the plane should stear towards to fly the desisred course.
    /// - Parameters:
    ///     - nextPoint: WayPoint - this is the waypoint the plane flies to
    ///
    ///     This method has been verified against a Numbers spreadsheet. Note the explanation for the Atan2 
    ///     variable placement.
    ///     KTC: - Online resource for using atan2 in this process say it should be atan2(x, y) but testing shows for 
    ///     Swift 5.2 at least, it's reversed.
    mutating func computeCourseToWayPoint(_ nextPoint: WayPoint) -> (Int, Double) {
        let circle: Float = 360.0
        // This is location.distance is in meters
        let distance = computeDistanceToNextWayPoint(nextPoint)
        
        let deltaLong = nextPoint.longitude - longitude
        let y = sin(deltaLong) * cos(nextPoint.latitude)
        let x = cos(latitude) * sin(nextPoint.latitude) - sin(latitude) * cos(nextPoint.latitude) * cos(deltaLong)
        let radValue = atan2(y, x)
        let degreeValue = NavTool.shared.convertToDegrees(radians: radValue)
        let retValue = 360 - ((Float(degreeValue) + circle).truncatingRemainder(dividingBy: circle))
        
        return (Int(retValue), distance)
    }

}
