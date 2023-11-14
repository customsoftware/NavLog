//
//  ScreenModels.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import Foundation

struct Environment {
    var elevation: Double = 1000
    var pressure: Double = 29.92
    var temp: Double = 51
    var runwayLength: Double = 5000
    
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults()
        var keyValue = testIfKeyValueNotPresent("kElevation")
        elevation = keyValue.0 ? 1000 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kPresure")
        pressure = keyValue.0 ? 29.92 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kTemp")
        temp = keyValue.0 ? 51 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kRunwayLength")
        runwayLength = keyValue.0 ? 5000 : keyValue.1
        
    }
    
    func save() {
        defaults.setValue(elevation, forKey: "kElevation")
        defaults.setValue(pressure, forKey: "kPresure")
        defaults.setValue(temp, forKey: "kTemp")
        defaults.setValue(runwayLength, forKey: "kRunwayLength")
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


struct MomentDatum {
    var maxWeight: Double = 2350.0
    var emptyWeight: Double = 1480.0
    var maxFrontWeight: Double = 400.0
    var frontMoment: Double = 37.5
    var maxBackWeight: Double = 400.0
    var backMoment: Double = 54.0
    var maxCargoWeight: Double = 120.0
    var cargoMoment: Double = 19.5
    var maxFuelGallons: Double = 48.0
    var fuelMoment: Double = 32.7
    var minWeight: Double = 1200
    var minArm: Double = 137.0
    var maxArm: Double = 269.0
    let fuelWeight: Double = 6
    
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults()
        var keyValue = testIfKeyValueNotPresent("kMaxWeight")
        maxWeight = keyValue.0 ? 2350 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kEmptyWeight")
        emptyWeight = keyValue.0 ? 1480 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMinWeight")
        minWeight = keyValue.0 ? 1200 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxFrontWeight")
        maxFrontWeight = keyValue.0 ? 400 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kFrontArm")
        frontMoment = keyValue.0 ? 37.5 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxBackWeight")
        maxBackWeight = keyValue.0 ? 400 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kBackArm")
        backMoment = keyValue.0 ? 54.0 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxFuelGallons")
        maxFuelGallons = keyValue.0 ? 48 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kFuelArm")
        fuelMoment = keyValue.0 ? 32.7 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxCargoWeight")
        maxCargoWeight = keyValue.0 ? 120 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kCargoArm")
        cargoMoment = keyValue.0 ? 19.5 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxArm")
        maxArm = keyValue.0 ? 269.0 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMinArm")
        minArm = keyValue.0 ? 137 : keyValue.1
    }
    
    func save() {
        defaults.setValue(maxWeight, forKey: "kMaxWeight")
        defaults.setValue(emptyWeight, forKey: "kEmptyWeight")
        defaults.setValue(minWeight, forKey: "kMinWeight")
        defaults.setValue(maxFrontWeight, forKey: "kMaxFrontWeight")
        defaults.setValue(frontMoment, forKey: "kFrontArm")
        defaults.setValue(maxBackWeight, forKey: "kMaxBackWeight")
        defaults.setValue(backMoment, forKey: "kBackArm")
        defaults.setValue(maxFuelGallons, forKey: "kMaxFuelGallons")
        defaults.setValue(fuelMoment, forKey: "kFuelArm")
        defaults.setValue(maxCargoWeight, forKey: "kMaxCargoWeight")
        defaults.setValue(cargoMoment, forKey: "kCargoArm")
        defaults.setValue(maxArm, forKey: "kMaxArm")
        defaults.setValue(minArm, forKey: "kMinArm")
        defaults.synchronize()
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


struct MomentWeight {
    var maxWeight: Double
    var moment: Double
   
    func computeMomentArm() -> Double {
        return maxWeight / moment
    }
    
    func computeMoment(_ weight: Double, momentArm: Double) -> Double {
        return weight * momentArm
    }
}
