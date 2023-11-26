//
//  AircraftOrientationManager.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/25/23.
//

import Foundation
import Combine
import CoreMotion
import CoreLocation
import MessageUI

struct MotionCapture: Codable {
    private let metersToFeetMultiple = 3.28084
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
        return (altitude ?? 0) * metersToFeetMultiple
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

class AircraftOrientationManager: NSObject, ObservableObject {
    
    var tracker = CMMotionManager()
    
    override init() {
        super.init()
        tracker.deviceMotionUpdateInterval = 0.1
    }
    
    var motionTrace: [MotionCapture] = []
    
    func clearData() {
        motionTrace.removeAll()
    }
    
    func shipData() -> String {
        var retValue: String = "Hi. Let's take a breather and see what we have..."
        
        let preppedData = motionTrace.sorted { m1, m2 in
            m1.timeStamp < m2.timeStamp
        }
        
        // Email the data to me
        do {
            let encodedData = try JSONEncoder().encode(preppedData)
            if let stringData = String(data: encodedData, encoding: .utf8) {
                retValue = stringData
            }
        } catch let error {
            retValue = "\(error.localizedDescription)"
        }
        
        return retValue
    }
    
    func handleObservedMotion(with motion: CMDeviceMotion, and location: CLLocation?) {
        guard let theLocation = location else {
            motionTrace.append(MotionCapture(roll: motion.attitude.roll, pitch: motion.attitude.pitch, yaw: motion.attitude.yaw, timeStamp: Date().timeIntervalSince1970))
            return
        }
        motionTrace.append(MotionCapture(roll: motion.attitude.roll, pitch: motion.attitude.pitch, yaw: motion.attitude.yaw, altitude: theLocation.altitude, timeStamp: Date().timeIntervalSince1970))
    }
    
    func establishBaseline(with motion: CMDeviceMotion, and location: CLLocation?) -> MotionCapture? {
        print("Setting baseline")
        return MotionCapture(roll: motion.attitude.roll, pitch: motion.attitude.pitch, yaw: motion.attitude.yaw, altitude: location?.altitude, timeStamp: Date().timeIntervalSince1970)
    }
    
    func findCriticalAngle(_ flightData: [MotionCapture], baseLine: MotionCapture?) -> MotionCapture? {
        
        // Find maximum altitude
        let baseReference = baseLine ?? flightData.first
        var reference = flightData.first
        let _ = flightData.map { aMotion in
            if aMotion.altitudeFeet > reference?.altitudeFeet ?? 0 {
                reference = aMotion
            }
        }
        if let aReference = reference,
           let base = baseReference
        {
            reference = MotionCapture(roll: aReference.roll, pitch: abs(aReference.pitch - base.pitch), yaw: aReference.roll, timeStamp: aReference.timeStamp)
        }
        return reference
    }
}
