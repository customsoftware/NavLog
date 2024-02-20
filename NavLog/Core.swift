//
//  Core.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/1/23.
//

import Foundation
import SwiftUI
import CoreLocation
import OSLog

@Observable
class Core {
    static let services = Core()
    
    var gpsEngine = GPSObserver()
    let navEngine = NavigationEngine()
    let acManager = AircraftManager()
//    let takeOffCalc = TakeOffCalculator()
//    let landingCalc = LandingCalculator()
    let orientation = AircraftOrientationManager()
    var canComputeTakeoff: Bool = false
    var canComputeLanding: Bool = false
    
    init() {
//        takeOffCalc.loadProfile()
//        if let performanceModel = takeOffCalc.performanceModel {
//            landingCalc.configureWith(landingProfile: performanceModel.landingProfile)
//            canComputeLanding = true
//            canComputeTakeoff = true
//       }
        
        acManager.retrieveChosenAircraft()
    }
    
    static func currentDisplayValues(currentLocation: CLLocation?, currentWayPoint: WayPoint?) -> CourseState {
         
        let currentHdg = currentLocation?.course ?? 0
        let plannedHdg = currentWayPoint?.headingFrom()
        let groundSpeed = currentLocation?.speed ?? 0
        let plannedSpeed = currentWayPoint?.estimatedGroundSpeed ?? 0
        let distance = currentWayPoint?.estimatedDistanceToNextWaypoint ?? 0
        let plannedTime = currentWayPoint?.estimatedTimeReached ?? 0
        
        let plannedAltitude = currentWayPoint?.altitude ?? 0
        let actualAltitude = currentLocation?.altitude ?? 0
        
        return CourseState(currentHeading: Int(currentHdg),
                           plannedHeading: plannedHdg ?? 0,
                           plannedAltitude: Double(plannedAltitude),
                           currentAltitude: actualAltitude,
                           observedGroundSpeed: groundSpeed,
                           plannedGroundSpeed: Double(plannedSpeed),
                           plannedTimeToNextWaypoint: plannedTime,
                           distanceToWayPoint: distance)
    }
}

extension Logger {
    // Use this to uniquely ID log events
    private static var subsystems = Bundle.main.bundleIdentifier!
    
    static let viewCycle = Logger(subsystem: subsystems, category: "viewCycle")
    
    static let api = Logger(subsystem: subsystems, category: "API")

    static let gps = Logger(subsystem: subsystems, category: "GPS")
}
