//
//  NavigationEngine.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/31/23.
//

import Foundation
import CoreLocation

class NavigationEngine {
    var activeLog: NavLogXML?
    var activeWayPoints: [WayPoint] = []
    let doGarmin = true
    let metersToFeetMultiple = 3.28084
    
    func runLog() {
        
    }
    
    func buildTestAircraft() -> Aircraft {
        var retValue : Aircraft = Aircraft(stallSpeed: 63, fuelCapacity: 48, standardClimbRate: 700, standardDescentRate: 500, cruiseFuelBurnRate: 8.6, climbToAltitudeFuelBurnRate: 12.9, descendingFuelBurnRate: 2.5, climbSpeed: 90, cruiseSpeed: 110)
        retValue.distanceMode = .standard
        return retValue
    }
    
    
    func buildTestNavLog() {
        let parser: ParserProtocol
        let xmlData: Data
        let fileName: String
        let fileID: String
        
        if doGarmin {
            parser = ParserFactory.getNavLogParser(.garmin) { aLog in
                self.activeLog = aLog
                var sequence = 0
                aLog.navPoints.forEach { navPoint in
                    self.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
             }
            fileName = "GarminPlan"
            fileID = "fpl"
        } else {
            
            parser = ParserFactory.getNavLogParser(.dynon, using: { aLog in
                self.activeLog = aLog
                var sequence = 0
                aLog.navPoints.forEach { navPoint in
                    self.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
                
            })
            fileName = "DynonPlan"
            fileID = "gpx"
         }
        guard let sourceFile = Bundle.main.path(forResource: fileName, ofType: fileID) else { return }
        if let xmlData = FileManager().contents(atPath: sourceFile) {
            parser.parseData(xmlData)
        }
    }
    
    
    fileprivate func loadIntoWayPoint(_ logEntry: NavigationPoint, _ index: Int) {
        let aLocation = CLLocation(latitude: logEntry.latitude, longitude: logEntry.longitude)
        let theAltitude = Int(logEntry.elevation * metersToFeetMultiple)
        
        var aWayPoint = WayPoint(name: logEntry.name, location: aLocation, altitude: theAltitude, wind: Wind(speed: 0, directionFrom: 0), courseFrom: 0, headingFrom: 0, estimatedDistanceToNextWaypoint: 0, estimatedGroundSpeed: 0, estimatedTimeReached: 0, computedFuelBurnToNextWayPoint: 0)
        aWayPoint.sequence = index
        activeWayPoints.append(aWayPoint)
    }
    
    func loadWayPoints() -> [WayPoint] {
        // We need the app to wait for this to finish
        
//        buildTestNavLog()
        
        return activeWayPoints
    }
    
}
