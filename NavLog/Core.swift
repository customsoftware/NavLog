//
//  Core.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/1/23.
//

import Foundation
import SwiftUI
import CoreLocation

class Core: ObservableObject {
    static let services = Core()
    @Published var gpsEngine = GPSObserver()
    let navEngine = NavigationEngine()
    
    
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
