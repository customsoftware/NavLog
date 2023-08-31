//
//  NavLog.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation



struct NavLog {
    /// This represents in gallons how much fuel is onboard at the start of the flight
    var startingFuel: Float
    /// This is when the flight starts for planning purposes
    var estimatedStartingTime: Double
    /// This is when the flight ends for planning purposes
    var estimatedEndingTime: Double
    /// This is the array of waypoints which comprise the actual navigation log
    var log: [WayPoint] = []
    
    /// This is the time the flight begins. It is determined by when the plane begins
    /// accelerating along the runway heading and exceeds aircraft stall speed.
    /// The time is started when the plane begins accelerating, but is recorded
    /// when  stall speed is exceeded and direction of flight is along the runway.
    var actualStartingTime: Double = 0
    /// This is when the plane actually lands and is determined by when the airplane 
    /// velocity drops below Vso along runway heading.
    var actualEndingTime: Int = 0
    /// This is the distance to the next waypoint from the current location
    var distanceToNextWaypoint: Int?
    /// This is the computed time to the next waypoint based upon location, distance to next waypoint and computed speed flying to the previous waypoint
    var timeToNext: Double?
    
    
    
    /// This subtracts the computed fuel burned on the flight from the starting fuel.
    func fuelRemaining() -> Float {
        // Get the starting fuel
        // Add up the estimated fuel burns for the completed waypoints
        var fuelUsed: Float = Float(0)
        // Subract that value from the starting fuel
        log.filter { aWayPoint in
            aWayPoint.isCompleted
        }.forEach { aWayPoint in
            fuelUsed = aWayPoint.computedFuelBurnToNextWayPoint
        }
        return startingFuel - fuelUsed
    }
    
    
    
    /// This is how much time remains to when the plane runs out of gas.
    /// - parameters
    ///  - aircraft: This is the aircraft used by the app
    /// - returns: The time to fuel exhaustion in hours
    /// This computes the value by dividing fuel remaining by the cruise fuel burn rate
    func timeToFuelExhaustion(aircraft: Aircraft) -> Double {
        let remainingFuel = fuelRemaining()
        let timeToExhaustion = remainingFuel/aircraft.cruiseFuelBurnRate
        return Double(timeToExhaustion)
    }
    
    
    
    /// This is function returns the active waypoint which is defined as: the first waypoint which is NOT completed
    func activeWayPoint() -> WayPoint? {
        return log.sorted { waypoint1, wayPoint2 in
            waypoint1.sequence < wayPoint2.sequence
        }
        .first { wayPoint in
            wayPoint.isCompleted == false
        }
    }
    
    
    
    /// This function return the previous waypoint in the flight which is defined as the last completed waypoint.
    /// - returns:
    func previousWayPoint() -> WayPoint? {
        return log.sorted { waypoint1, wayPoint2 in
            waypoint1.sequence < wayPoint2.sequence
        }
        .first { wayPoint in
            wayPoint.isCompleted == true
        }
    }
}
