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
    
    private let locationManger = CLLocationManager()
    private var canBeUsed: Bool = false
    private var started: Bool = false
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManger.delegate = self
    }
    
    
    func startTrackingLocation() {
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
        switch manager.authorizationStatus {
        case .notDetermined:
            fatalError("You need to request authorization to use GPS location system")
        case .restricted, .denied:
            canBeUsed = false
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            canBeUsed = true
        @unknown default:
            fatalError("You have a new authorization status for the GPS location system")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
    }
    
    enum GPSErrors: Error {
        case notAuthorized
        case noCurrentLocation
    }
}
