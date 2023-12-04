//
//  MomentDatum.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import Foundation

struct MomentDatum {
    var maxWeight: Double = 0
    var emptyWeight: Double = 0
    var aircraftArm: Double = 0
    var oilMoment: Double = 0
    var oilWeight: Double = 0
    // Front seat
    var maxFrontWeight: Double = 0
    var frontMoment: Double = 0
    // Middle seat
    var maxMiddleWeight: Double = 0.0
    var middleMoment: Double = 0.0
    // Back seat
    var maxBackWeight: Double = 0
    var backMoment: Double = 0
    // Cargo
    var maxCargoWeight: Double = 0
    var cargoMoment: Double = 0
    // Fuel
    var maxFuelGallons: Double = 0
    var fuelMoment: Double = 0
    // Aux Fuel
    var auxMaxFuelGallons: Double = 0
    var auxFuelMoment: Double = 0
    
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
    
    private (set) var defaults: UserDefaults
    
    // We can inject user defaults for testing purposes
    init(_ usedDefaults: UserDefaults = UserDefaults()) {
        defaults = usedDefaults
        if !defaults.bool(forKey: "kMomentDataLoaded") {
            do {
                try loadFromJSON()
            } catch let error {
                print("There was an error loading the moment data: \(error.localizedDescription)")
            }
        } else {
            read()
        }
    }
    
    
    /// This saves the entered data into user defaults
    /// - Parameters:
    /// - None
    ///
    func save() {
        defaults.setValue(true, forKey: "kMomentDataLoaded")
        defaults.setValue(maxWeight, forKey: "kMaxWeight")
        defaults.setValue(emptyWeight, forKey: "kEmptyWeight")
        defaults.setValue(aircraftArm, forKey: "kAircraftMoment")
        
        defaults.setValue(oilMoment, forKey: "kOilMoment")
        defaults.setValue(oilWeight, forKey: "kOilWeight")
        
        defaults.setValue(maxFrontWeight, forKey: "kMaxFrontWeight")
        defaults.setValue(frontMoment, forKey: "kFrontArm")
        
        defaults.setValue(maxMiddleWeight, forKey: "kMaxMiddleWeight")
        defaults.setValue(middleMoment, forKey: "kMiddleArm")
        
        defaults.setValue(maxBackWeight, forKey: "kMaxBackWeight")
        defaults.setValue(backMoment, forKey: "kBackArm")
        
        defaults.setValue(maxFuelGallons, forKey: "kMaxFuelGallons")
        defaults.setValue(fuelMoment, forKey: "kFuelArm")
        
        defaults.setValue(maxCargoWeight, forKey: "kMaxCargoWeight")
        defaults.setValue(cargoMoment, forKey: "kCargoArm")
        defaults.synchronize()
    }
    
    private mutating func read() {
        var keyValue = testIfKeyValueNotPresent("kMaxWeight")
        maxWeight = keyValue.0 ? 2350 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kEmptyWeight")
        emptyWeight = keyValue.0 ? 1483 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kAircraftMoment")
        aircraftArm = keyValue.0 ? 0.11464 : keyValue.1
        
        keyValue = testIfKeyValueNotPresent("kOilMoment")
        oilMoment = keyValue.0 ? 0.7 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kOilWeight")
        oilWeight = keyValue.0 ? 15 : keyValue.1
        
        keyValue = testIfKeyValueNotPresent("kMaxFrontWeight")
        maxFrontWeight = keyValue.0 ? 400 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kFrontArm")
        frontMoment = keyValue.0 ? 37.5 : keyValue.1
        
        maxMiddleWeight = keyValue.0 ? 400 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMaxMiddleWeight")
        middleMoment = keyValue.0 ? 400 : keyValue.1
        keyValue = testIfKeyValueNotPresent("kMiddleArm")
        
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
    
    private func testIfKeyValueNotPresent(_ keyName: String) -> (Bool, Double) {
        var isNotStored: Bool = true
        let keyValue = defaults.double(forKey: keyName)
        if keyValue > 0 {
            isNotStored = false
        }
        return (isNotStored, keyValue)
    }
    
    private mutating func loadFromJSON() throws {
        // This will change as the app evolves, right now it hard codes to a file
        guard let momentPath = Bundle.main.path(forResource: "CardinalMoment", ofType: "json")
        else { return }
        do {
            let momentJSONdata = (try String(contentsOfFile: momentPath).data(using: .utf8))
            
            guard let momentJSON = momentJSONdata else {
                throw MomentErrors.missingData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            let aircraftMoment = try decoder.decode(MomentModel.self, from: momentJSON)
            
            // Here we transfer to the model
            maxWeight = aircraftMoment.maxWeight
            emptyWeight = aircraftMoment.emptyWeight
            aircraftArm = aircraftMoment.aircraftArm
            oilMoment = aircraftMoment.oilMoment
            oilWeight = aircraftMoment.oilWeight
            maxFrontWeight = aircraftMoment.maxFrontWeight
            frontMoment = aircraftMoment.frontMoment
            maxMiddleWeight = aircraftMoment.maxMiddleWeight
            middleMoment = aircraftMoment.middleMoment
            maxBackWeight = aircraftMoment.maxBackWeight
            maxCargoWeight = aircraftMoment.maxCargoWeight
            cargoMoment = aircraftMoment.cargoMoment
            maxFuelGallons = aircraftMoment.maxFuelGallons
            fuelMoment = aircraftMoment.fuelMoment
            auxMaxFuelGallons = aircraftMoment.auxMaxFuelGallons
            auxFuelMoment = aircraftMoment.auxFuelMoment
        } catch {
            let parseError = MomentErrors.parseError(error.localizedDescription)
            throw parseError
        }
    }
}
