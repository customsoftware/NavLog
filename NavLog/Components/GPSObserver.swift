//
//  GPSObserver.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation
import CoreLocation

/// This class does the heavy lifting for determing aircraft performance.
/// It uses GPS signals to determine location and speed.
class GPSObserver: NSObject, CLLocationManagerDelegate {
    private static let metersToKnots: Double = 1.94384
    private static let metersToStandard: Double = 2.23694
    
    let locationManger = CLLocationManager()
    var canBeUsed: Bool = false
    private var started: Bool = false
    private var currentLocation: CLLocation?
    
    func configure() {
        locationManger.delegate = self
        checkPermissions()
        
        startTrackingLocation()
    }
    
    
    func startTrackingLocation() {
        locationManger.startUpdatingLocation()
        started = true
    }
    
    func stopTrackingLocation() {
        started = false
    }
    
    
    /// Need to convert these values, which are measured in meters/second to nautical miles per hour
    func aircraftSpeed(aircraft: Aircraft) throws -> Double {
        guard canBeUsed else {
            throw GPSErrors.notAuthorized
        }
        guard let aLocation = locationManger.location else {
            throw GPSErrors.noCurrentLocation
        }
        
        /// aLocation.speed is in meters per second
        let reportedSpeed: Double = aLocation.speed
        
        // Get CLLocation
        var retValue: Double = 0
        switch aircraft.distanceMode {
        case .standard:
            retValue = reportedSpeed * GPSObserver.metersToStandard
        case .nautical:
            retValue = reportedSpeed * GPSObserver.metersToKnots
        case .metric:
            retValue = reportedSpeed / 1000
        }
        /// Value is in units per second. This division converts to units per hour
        return retValue / 3600
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        resolvePermissions(manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("We're here .... ")
    }
    
    enum GPSErrors: Error {
        case notAuthorized
        case noCurrentLocation
    }
}

fileprivate extension GPSObserver {
    func checkPermissions() {
        resolvePermissions(locationManger)
    }
    
    func configureTracking(isFine: Bool = false) {
        /// There are two modes of operation for the plane.
        /// 1. On the ground and taxiing to or from the runway.
        /// 2. Flying
        /// We care about the second one far more than the first. So how do we filter out the first, but not the second?
    }
    
    
    func resolvePermissions(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Location authorization not determineed")
            manager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            print("Location authorization not restricted or denied")
            canBeUsed = false
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("Location authorization granted to some level")
            canBeUsed = true
        @unknown default:
            fatalError("You have a new authorization status for the GPS location system")
        }
    }
}
