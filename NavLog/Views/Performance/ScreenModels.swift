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
    var runwayDirection: Double = 13
    var windDirection: Double = 140
    var windSpeed: Double = 4
    
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
        keyValue = testIfKeyValueNotPresent("kRunwayDirection")
        runwayDirection = keyValue.0 ? 13 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kWindDirection")
        windDirection = keyValue.0 ? 140 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kWindSpeed")
        windSpeed = keyValue.0 ? 4 : keyValue.1
    }
    
    func save() {
        defaults.setValue(elevation, forKey: "kElevation")
        defaults.setValue(pressure, forKey: "kPresure")
        defaults.setValue(temp, forKey: "kTemp")
        defaults.setValue(runwayLength, forKey: "kRunwayLength")
        defaults.setValue(runwayDirection, forKey: "kRunwayDirection")
        defaults.setValue(windDirection, forKey: "kWindDirection")
        defaults.setValue(windSpeed, forKey: "kWindSpeed")
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
    var aircraftArm: Double = 0.11464
    var oilMoment: Double = 0.7
    var oilWeight: Double = 15.0
    var frontMoment: Double = 37.5
    var maxBackWeight: Double = 400.0
    var backMoment: Double = 54.0
    var maxCargoWeight: Double = 120.0
    var cargoMoment: Double = 19.5
    var maxFuelGallons: Double = 48.0
    var fuelMoment: Double = 32.7
    var minWeight: Double = 1200
    
    lazy var oilArm: Double = {
        return oilMoment/oilWeight
    }()
    
    lazy var frontArm: Double = {
        return frontMoment/maxFrontWeight
    }()
    
    lazy var backArm: Double = {
        return backMoment/maxBackWeight
    }()
    
    lazy var cargoArm: Double = {
        return cargoMoment/maxCargoWeight
    }()
    
    lazy var fuelArm: Double = {
        return fuelMoment/(maxFuelGallons * fuelWeight)
    }()
    
    let fuelWeight: Double = 6
    
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults()
        var keyValue = testIfKeyValueNotPresent("kMaxWeight")
        maxWeight = keyValue.0 ? 2350 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kEmptyWeight")
        emptyWeight = keyValue.0 ? 1483 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kAircraftMoment")
        aircraftArm = keyValue.0 ? 0.11464 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMinWeight")
        minWeight = keyValue.0 ? 1200 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kOilMoment")
        oilMoment = keyValue.0 ? 0.7 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kOilWeight")
        oilWeight = keyValue.0 ? 15 : keyValue.1
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
    }
    
    func save() {
        defaults.setValue(maxWeight, forKey: "kMaxWeight")
        defaults.setValue(emptyWeight, forKey: "kEmptyWeight")
        defaults.setValue(minWeight, forKey: "kMinWeight")
        defaults.setValue(aircraftArm, forKey: "kAircraftMoment")
        defaults.setValue(oilMoment, forKey: "kOilMoment")
        defaults.setValue(oilWeight, forKey: "kOilWeight")
        defaults.setValue(maxFrontWeight, forKey: "kMaxFrontWeight")
        defaults.setValue(frontMoment, forKey: "kFrontArm")
        defaults.setValue(maxBackWeight, forKey: "kMaxBackWeight")
        defaults.setValue(backMoment, forKey: "kBackArm")
        defaults.setValue(maxFuelGallons, forKey: "kMaxFuelGallons")
        defaults.setValue(fuelMoment, forKey: "kFuelArm")
        defaults.setValue(maxCargoWeight, forKey: "kMaxCargoWeight")
        defaults.setValue(cargoMoment, forKey: "kCargoArm")
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


struct PerformanceResults {
    var isUnderGross: Bool = false
    var cgIsInLimits: Bool = false
    var overWeightAmount: Double = 0
    var pressureAltitude: Double = 0
    var densityAltitude: Double = 0
    var computedTakeOffRoll: Double = 1400
    var computedOver50Roll: Double = 2100
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

struct PerformanceProfile: Codable {
    var takeoff: [TakeOffWeight]
    var multipliers: [Multiple]
    var multipliers50: [Multiple]
    var temperatureBand: Double
    var temperatureDeltaRate: Double
    var windrates: [WindMultiples]
}
