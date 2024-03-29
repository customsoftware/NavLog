//
//  MomentDatum.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import Foundation

struct MomentDatum: Codable, Hashable {
    let id: UUID = UUID()
    var aircraft: String = ""
    var aircraftEngine: String = ""
    var seatCount: Double = 0
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
    
    func oilArm() -> Double {
        var retValue = 0.0
        if oilWeight > 0 {
            retValue = oilMoment/oilWeight
        }
        return retValue
    }
    
    func frontArm() -> Double {
        return frontMoment/maxFrontWeight
    }
    
    func backArm() -> Double {
        return backMoment/maxBackWeight
    }
    
    func cargoArm() -> Double {
        return cargoMoment/maxCargoWeight
    }
    
    func fuelArm() -> Double {
        return fuelMoment/(maxFuelGallons * fuelWeight)
    }
    
    func auxFuelArm() -> Double {
        return auxFuelMoment/(auxMaxFuelGallons * fuelWeight)
    }
    
    func isValid() -> Bool {
        let retValue = aircraft.count >= 5 && seatCount > 0 && maxWeight > 0 && emptyWeight > 0 && (emptyWeight < maxWeight)
        return retValue
    }
    
    let fuelWeight: Double = 6.01
    
    // We can inject user defaults for testing purposes
    init(_ usedDefaults: UserDefaults = UserDefaults(), from fileName: String) {
        // Read from files first. If those don't work, read test files. If those don't work add a blank one.
        do {
            try loadFromJSON(fileName)
        } catch let error {
//            if !usedDefaults.bool(forKey: "kMomentDataLoaded") {
//                read(using: usedDefaults)
//            } else {
//                print("There was an error loading the moment data: \(error.localizedDescription)")
//            }
        }
    }
    
    init() {
        // This is so we can create a blank one on the fly
    }
    
    private mutating func loadFromJSON(_ fileName: String) throws {
        // This will change as the app evolves, right now it hard codes to a file
        guard let momentPath = Bundle.main.path(forResource: fileName, ofType: "json")
        else { return }
        do {
            let momentJSONdata = (try String(contentsOfFile: momentPath).data(using: .utf8))
            
            guard let momentJSON = momentJSONdata else {
                throw MomentErrors.missingData
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
            let aircraftMoment = try decoder.decode(MomentDatum.self, from: momentJSON)
            
            // Here we transfer to the model
            aircraft = aircraftMoment.aircraft
            aircraftEngine = aircraftMoment.aircraftEngine
            seatCount = aircraftMoment.seatCount
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
            backMoment = aircraftMoment.backMoment
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
    
//    enum CodingKeys: String, CodingKey {
//        case aircraft
//        case aircraftEngine = "aircraft_engine"
//        case maxWeight = "max_weight"
//        case emptyWeight = "empty_weight"
//        case aircraftArm = "aircraft_arm"
//        case oilMoment = "oil_moment"
//        case oilWeight = "oil_weight"
//        case frontMoment = "front_moment"
//        case maxMiddleWeight = "max_middle_weight"
//        case middleMoment = "middle_moment"
//        case maxBackWeight = "max_back_weight"
//        case backMoment = "back_moment"
//        case maxCargoWeight = "max_cargo_weight"
//        case cargoMoment = "cargo_moment"
//        case maxFuelGallons = "max_fuel_gallons"
//        case fuelMoment = "fuel_moment"
//        case auxMaxFuelGallons = "aux_max_fuel_gallons"
//        case auxFuelMoment = "aux_fuel_moment"
//        case seatCount = "seat_count"
//    }
}


enum MomentErrors: Error, LocalizedError, CustomStringConvertible {
    case missingData
    case parseError(String)
    
    public var errorDescription: String? {
        let retValue: String
        switch self {
        case .missingData:
            retValue = NSLocalizedString("Missing file - The source file doesn't exist where the app expects it.", comment: "")
            
        case .parseError(let errorString):
            retValue = NSLocalizedString("There was a parsing error - \(errorString)", comment: "")
            
        }
        return retValue
    }

    public var description: String {
        let retValue: String
        switch self {
        case .missingData:
            retValue = "The source file is missing"
            
        case .parseError(let error):
            retValue = "There was a parsing error - \(error)"
        }
        return retValue
    }
}
