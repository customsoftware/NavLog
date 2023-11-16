//
//  PerformanceProfile.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import Foundation



// This is the parent of the other structs
struct PerformanceProfile: Codable {
    var takeoff: [TakeOffWeight]
    var multipliers: [Multiple]
    var multipliers50: [Multiple]
    var temperatureBand: Double
    var temperatureDeltaRate: Double
    var windrates: [WindMultiples]
    var seatCount: Double
}


struct MomentWeight {
    var maxWeight: Double
    var moment: Double
}


struct TakeOffWeight: Codable {
    var weight: Double
    var roll: Double
}


struct WindMultiples: Codable {
    var wind: Double
    var weight: Double
    var multiple: Double
    var for50: Bool
}


struct Multiple: Codable {
    var elevation: Double
    var multiple: Double
}
