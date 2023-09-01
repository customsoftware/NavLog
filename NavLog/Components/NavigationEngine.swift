//
//  NavigationEngine.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/31/23.
//

import Foundation
import CoreLocation

class NavigationEngine {
    var activeLog: NavLog?
    
    
    func loadLog(_ aLog: NavLog) {
        
    }
    
    func runLog() {
        
    }
    
    func buildTestAircraft() -> Aircraft {
        var retValue : Aircraft = Aircraft(stallSpeed: 63, fuelCapacity: 48, standardClimbRate: 700, standardDescentRate: 500, cruiseFuelBurnRate: 8.6, climbToAltitudeFuelBurnRate: 12.9, descendingFuelBurnRate: 2.5, climbSpeed: 90, cruiseSpeed: 110)
        retValue.distanceMode = .standard
        return retValue
    }
    
    func buildTestNavLog() -> NavLog? {
        let initialFuel: Float = 32.3
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        guard let startTime: Date = dateFormatter.date(from: "08/31/2023 20:10"),
              let stopTime: Date = dateFormatter.date(from: "08/31/2023 21:10") else {
            return nil
        }
        
        var newLog = NavLog(startingFuel: initialFuel, estimatedStartingTime: startTime.timeIntervalSince1970, estimatedEndingTime: stopTime.timeIntervalSince1970)
        
        newLog.log = loadWayPoints()
        
        return newLog
    }
    
    func loadWayPoints() -> [WayPoint] {
        var w1 = WayPoint(name: "KPVU", location: CLLocation(latitude: 40.21916, longitude: 111.7234), altitude: 4497, wind: Wind(speed: 6, directionFrom: 150), courseFrom: 145, headingFrom: 143, estimatedDistanceToNextWaypoint: 1.8, estimatedGroundSpeed: 90, estimatedTimeReached: 1.4, computedFuelBurnToNextWayPoint: 0.3)
        w1.distanceMode = .standard
        w1.sequence = 0
        
         var w2 = WayPoint(name: "WayPoint 1", location: CLLocation(latitude: 40.19671, longitude: 111.7031), altitude: 7000, wind: Wind(speed: 22, directionFrom: 211), courseFrom: 19, headingFrom: 6, estimatedDistanceToNextWaypoint: 4.1, estimatedGroundSpeed: 159, estimatedTimeReached: 2.1, computedFuelBurnToNextWayPoint: 0.4)
        w2.distanceMode = .standard
        w2.sequence = 1

        var w3 = WayPoint(name: "CITUV", location: CLLocation(latitude: 40.246361, longitude: 111.679694), altitude: 7000, wind: Wind(speed: 22, directionFrom: 211), courseFrom: 319, headingFrom: 296, estimatedDistanceToNextWaypoint: 18.7, estimatedGroundSpeed: 139, estimatedTimeReached: 8.1, computedFuelBurnToNextWayPoint: 1.3)
        w3.distanceMode = .standard
        w3.sequence = 2

        var w4 = WayPoint(name: "VPPTM-US", location: CLLocation(latitude: 40.45694, longitude: 111.9138), altitude: 7000, wind: Wind(speed: 24, directionFrom: 213), courseFrom: 0, headingFrom: 343, estimatedDistanceToNextWaypoint: 47, estimatedGroundSpeed: 159, estimatedTimeReached: 17.9, computedFuelBurnToNextWayPoint: 3.0)
        w4.distanceMode = .standard
        w4.sequence = 3

        var w5 = WayPoint(name: "VPWBR-US", location: CLLocation(latitude: 41.1361, longitude: 111.9138), altitude: 7000, wind: Wind(speed: 24, directionFrom: 213), courseFrom: 309, headingFrom: 286, estimatedDistanceToNextWaypoint: 3.3, estimatedGroundSpeed: 136, estimatedTimeReached: 1.5, computedFuelBurnToNextWayPoint: 0.2)
        w5.distanceMode = .standard
        w5.sequence = 4

        var w6 = WayPoint(name: "KOGD", location: CLLocation(latitude: 41.195, longitude: 112.01216), altitude: 5500, wind: Wind(speed: 20, directionFrom: 210), courseFrom: 310, headingFrom: 290, estimatedDistanceToNextWaypoint: 3.7, estimatedGroundSpeed: 137, estimatedTimeReached: 1.75, computedFuelBurnToNextWayPoint: 0.1)
        w6.distanceMode = .standard
        w6.sequence = 5

        return [w1, w2, w3, w4, w5, w6]
    }
}
