//
//  MotionCapture.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/25/23.
//

import Foundation

struct MotionCapture: Codable {
    private static let metersToFeetMultiple = 3.28084
    var roll: Double
    var pitch: Double
    var yaw: Double
    var altitude: Double? = 0
    var timeStamp: Double
    
    
    var rollDegrees: Double {
        return degrees(radians: roll).rounded()
    }
    
    var pitchDegrees: Double {
        return degrees(radians: pitch).rounded()
    }
    
    var yawDegrees: Double {
        return degrees(radians: yaw).rounded()
    }
    
    var altitudeFeet: Double {
        return (altitude ?? 0) * MotionCapture.metersToFeetMultiple
    }

    var altitudeKilometers: Double {
        return (altitude ?? 0) / 1000
    }

    private func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
}

struct GroupResults: Codable {
    var theArray : [MotionCapture]
}
