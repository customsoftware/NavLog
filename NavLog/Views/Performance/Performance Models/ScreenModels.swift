//
//  ScreenModels.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import Foundation

struct Environment {
    var elevation: Double = 1
    var pressure: Double = 29.92
    var temp: Double = 59
    var runwayLength: Double = 0
    var runwayDirection: Double = 0
    var windDirection: Double = 0
    var windSpeed: Double = 0
    var inCelsiusMode: Bool = false
    
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults()
        var keyValue = testIfKeyValueNotPresent("kElevation")
        elevation = keyValue.0 ? 1 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kPresure")
        pressure = keyValue.0 ? 29.92 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kTemp")
        temp = keyValue.0 ? 59 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kRunwayLength")
        runwayLength = keyValue.0 ? 0 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kRunwayDirection")
        runwayDirection = keyValue.0 ? 0 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kWindDirection")
        windDirection = keyValue.0 ? 0 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kWindSpeed")
        windSpeed = keyValue.0 ? 0 : keyValue.1
        inCelsiusMode = defaults.bool(forKey: "kCelsiusMode")
   }
    
    func save() {
        defaults.setValue(elevation, forKey: "kElevation")
        defaults.setValue(pressure, forKey: "kPresure")
        defaults.setValue(temp, forKey: "kTemp")
        defaults.setValue(runwayLength, forKey: "kRunwayLength")
        defaults.setValue(runwayDirection, forKey: "kRunwayDirection")
        defaults.setValue(windDirection, forKey: "kWindDirection")
        defaults.setValue(windSpeed, forKey: "kWindSpeed")
        defaults.setValue(inCelsiusMode, forKey: "kCelsiusMode")
  }
    
    
    private func testIfKeyValueNotPresent(_ keyName: String) -> (Bool, Double) {
        var isNotStored: Bool = true
        let keyValue = defaults.double(forKey: keyName)
        if keyValue > 0 {
            isNotStored = false
        }
        return (isNotStored, keyValue)
    }
}


struct MissionData {
    var pilotSeat: Double = 0
    var copilotSeat: Double = 0
    var middleSeat: Double = 0
    var backSeat: Double = 0
    var cargo: Double = 0
    var fuel: Double = 0
}