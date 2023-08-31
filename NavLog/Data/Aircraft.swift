//
//  Aircraft.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation

/// This object persists from flight to flight. It defines the features of the aircraft needed when planning a flight.
struct Aircraft {
    /// This is Vso, stall speed in clean configuration
    var stallSpeed: Int
    /// This is how many gallons the aircraft can hold in all of its tanks
    var fuelCapacity: Int
    /// Typical Vy climb rate at gross weight
    var standardClimbRate: Int
    /// How fast you typically want to descend to pattern altitude from cruise altitude
    var standardDescentRate: Int
    /// This is the estimated fuel burn rate in gallons per hour of the aircraft while cruising at mission altitude
    var cruiseFuelBurnRate: Float
    /// This is the estimated fuel burn rate in gallons per hour while the aircraft is climbing to cruise altitude
    var climbToAltitudeFuelBurnRate: Float
    /// This is the estimateed fuel burn rate in gallons per hour while the airplane is desceding from cruist altitude to pattern altitude
    var descendingFuelBurnRate: Float
    /// This is Vy speed
    var climbSpeed: Int
    /// This is Indicated Airspeed at cruise altitude
    var cruiseSpeed: Int
    /// How the airplane measures distances.
    var distanceMode: DistanceMode = .nautical
}
