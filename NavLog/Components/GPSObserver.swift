//
//  GPSObserver.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation
import SwiftUI
import CoreLocation

/// This class does the heavy lifting for determing aircraft performance.
/// It uses GPS signals to determine location and speed.
class GPSObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let metersToKnots: Double = 1.94384
    static let metersToStandardMiles: Double = 2.23694
    static let metersToFeet: Double = 3.28084
    
    var locationManger = CLLocationManager()
    var canBeUsed: Bool = false
    var isRunning: Bool = false
    private var started: Bool = false
    private (set) var currentLocation: CLLocation? {
        didSet {
            guard let aLocation = currentLocation else { return }
            speed = aLocation.speed
            altitude = aLocation.ellipsoidalAltitude
            course = aLocation.course < 0 ? abs(aLocation.course) : aLocation.course
            latitude = aLocation.coordinate.latitude
            longitude = aLocation.coordinate.longitude
        }
    }
    @Published var speed: Double = 0
    @Published var altitude: Double = 0
    @Published var course: Double = 0
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    
    override init() {
        super.init()
        locationManger.delegate = self
    }
    
    
    func configure() {
        checkPermissions()
    }
    
    
    func startTrackingLocation() {
        locationManger.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManger.startUpdatingLocation()
        started = true
    }
    
    func stopTrackingLocation() {
        locationManger.stopUpdatingLocation()
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
            retValue = reportedSpeed * GPSObserver.metersToStandardMiles
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
        currentLocation = locations.last
//        print("LAT: \(currentLocation?.coordinate.latitude ?? 0) - LONG: \(currentLocation?.coordinate.longitude ?? 0) - ALT: \(currentLocation?.altitude ?? 0) - HDG: \(currentLocation?.course ?? 0)")
//        print("ALT: \(currentLocation?.altitude ?? 0) - SPD: \(currentLocation?.speed ?? 0)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("There was a location error: \(error.localizedDescription)")
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
