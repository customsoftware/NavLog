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
        
        // Oil
        defaults.setValue(oilMoment, forKey: "kOilMoment")
        defaults.setValue(oilWeight, forKey: "kOilWeight")
        
        // Front
        defaults.setValue(maxFrontWeight, forKey: "kMaxFrontWeight")
        defaults.setValue(frontMoment, forKey: "kFrontArm")
        
        // Middle
        defaults.setValue(maxMiddleWeight, forKey: "kMaxMiddleWeight")
        defaults.setValue(middleMoment, forKey: "kMiddleArm")
        
        // Back
        defaults.setValue(maxBackWeight, forKey: "kMaxBackWeight")
        defaults.setValue(backMoment, forKey: "kBackArm")
        
        // Fuel
        defaults.setValue(maxFuelGallons, forKey: "kMaxFuelGallons")
        defaults.setValue(fuelMoment, forKey: "kFuelArm")
        
        // Aux Fuel
        defaults.setValue(auxMaxFuelGallons, forKey: "kAuxMaxFuelGallons")
        defaults.setValue(auxFuelMoment, forKey: "kAuxFuelArm")
        
        // Cargo
        defaults.setValue(maxCargoWeight, forKey: "kMaxCargoWeight")
        defaults.setValue(cargoMoment, forKey: "kCargoArm")
        
        // Cleanup
        defaults.synchronize()
    }
    
    private mutating func read() {
        maxWeight = defaults.double(forKey: "kMaxWeight")
        emptyWeight = defaults.double(forKey: "kEmptyWeight")
        aircraftArm = defaults.double(forKey: "kAircraftMoment")
        
        // Oil
        oilMoment = defaults.double(forKey: "kOilMoment")
        oilWeight = defaults.double(forKey: "kOilWeight")
        
        // Front
        maxFrontWeight = defaults.double(forKey: "kMaxFrontWeight")
        frontMoment = defaults.double(forKey: "kFrontArm")
        
        // Middle
        maxMiddleWeight = defaults.double(forKey: "kMaxMiddleWeight")
        middleMoment = defaults.double(forKey: "kMiddleArm")
        
        // Back
        maxBackWeight = defaults.double(forKey: "kMaxBackWeight")
        backMoment = defaults.double(forKey: "kBackArm")
        
        // Fuel
        maxFuelGallons = defaults.double(forKey: "kMaxFuelGallons")
        fuelMoment = defaults.double(forKey: "kFuelArm")
        
        // Aux Fuel
        auxMaxFuelGallons = defaults.double(forKey: "kAuxMaxFuelGallons")
        auxFuelMoment = defaults.double(forKey: "kAuxFuelArm")
        
        // Cargo
        maxCargoWeight = defaults.double(forKey: "kMaxCargoWeight")
        cargoMoment = defaults.double(forKey: "kCargoArm")
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
