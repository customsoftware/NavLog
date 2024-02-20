//
//  MotionCapture.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/25/23.
//

import Foundation
import NavTool

struct MotionCapture: Codable {
    private static let metersToFeetMultiple = 3.28084
    var roll: Double
    var pitch: Double
    var yaw: Double
    var altitude: Double? = 0
    var timeStamp: Double
    
    
    var rollDegrees: Double {
        return NavTool.shared.convertToDegrees(radians: roll).rounded()
    }
    
    var pitchDegrees: Double {
        return NavTool.shared.convertToDegrees(radians: pitch).rounded()
    }
    
    var yawDegrees: Double {
        return NavTool.shared.convertToDegrees(radians: yaw).rounded()
    }
    
    var altitudeFeet: Double {
        return (altitude ?? 0) * MotionCapture.metersToFeetMultiple
    }

    var altitudeKilometers: Double {
        return (altitude ?? 0) / 1000
    }
}

struct GroupResults: Codable {
    var theArray : [MotionCapture]
}
