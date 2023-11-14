//
//  DataFetchEngine.swift
//  CombineWeather
//
//  Created by Kenneth Cluff on 11/6/23.
//

import Foundation
import Combine

public enum DeclinationError: Error, LocalizedError, CustomStringConvertible {
    case badURL(description: String)
    case networkError(description: String)
    case parsingError(description: String)

    public var errorDescription: String? {
        let retValue: String
        switch self {
        case .badURL(description: let errorString):
            retValue = NSLocalizedString("Bad URL - \(errorString)", comment: "")
            
        case .networkError(description: let errorString):
            retValue = NSLocalizedString("Network - \(errorString)", comment: "")
            
        case .parsingError(description: let errorString):
            retValue = NSLocalizedString("Parsing - \(errorString)", comment: "")
        }
        return retValue
    }

    public var description: String {
        let retValue: String
        switch self {
        case .badURL(description: let error):
            retValue = "Bad URL - \(error)"
            
        case .networkError(description: let error):
            retValue = "Network - \(error)"
            
        case .parsingError(description: let error):
            retValue = "Parsing - \(error)"
        }
        return retValue
    }
}
