//
//  Aircraft.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation

/// This object persists from flight to flight. It defines the features of the aircraft needed when planning a flight.
struct Aircraft: Codable {
    /// This is the N-number for the aircraft. It's how we identify the plane
    var registration: String
    /// Typical Vy climb rate at gross weight
    var standardClimbRate: Int
    /// How fast you typically want to descend to pattern altitude from cruise altitude
    var standardDescentRate: Int
    /// This is the estimated fuel burn rate in gallons per hour of the aircraft while cruising at mission altitude
    var cruiseFuelBurnRate: Double
    /// This is the estimated fuel burn rate in gallons per hour while the aircraft is climbing to cruise altitude
    var climbToAltitudeFuelBurnRate: Double
    /// This is the estimateed fuel burn rate in gallons per hour while the airplane is desceding from cruist altitude to pattern altitude
    var descendingFuelBurnRate: Double
    /// This is Vso, stall speed in clean configuration
    var stallSpeed: Int
     /// This is Vy speed
    var climbSpeed: Int
    /// This is Indicated Airspeed at cruise altitude
    var cruiseSpeed: Int
    /// This is Indicated Airspeed while descending
    var descentSpeed: Int
}
