//
//  StandardTempCalculator.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/15/23.
//

import Foundation


class StandardTempCalculator {
    private static let standardTemperature: Double = 15.0
    private static let feetToMeters: Double = 0.3048
    private static let metricLapsPer100Meters: Double = 0.65
    
    static func computeStandardTempForAltitude(_ physicalElevation: Double) -> Double {
        let metricElevation: Double = physicalElevation * feetToMeters
        let hundredsDelta = metricElevation/100
        let centigradeDelta = hundredsDelta * metricLapsPer100Meters
        return standardTemperature - centigradeDelta
    }
    
    static func convertFtoC(_ tempF: Double) -> Double {
        // (32°F − 32) × 5/9 = 0°C
        let step1 = tempF - 32.0
        let step2 = step1 * 0.55555556
        return step2
    }
    
    static func convertCtoF(_ tempC: Double) -> Double {
        // (32°C × 9/5) + 32 = 89.6°F
        let step1 = tempC * 1.8
        let step2 = step1 + 32.0
        return step2
    }
}
