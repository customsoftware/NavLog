//
//  MomentModel.swift
//  NavLog
//
//  Created by Kenneth Cluff on 12/4/23.
//

import Foundation

struct MomentModel: Codable {
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
    // AuxFuel
    var auxMaxFuelGallons: Double = 0
    var auxFuelMoment: Double = 0
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
