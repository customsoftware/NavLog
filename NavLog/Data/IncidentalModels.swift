//
//  IncidentalModels.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation


/// This represents wind speeds which affect the aircraft in flight
struct Wind {
    /// This is how fast the wind is blowing measured in nautical miles per hour
    var speed: Double
    /// This is the direction the wind is blowing. This is the direction you must face to have it blowing directly into your face.
    var directionFrom: Double
}


// Whether values are displayed in standard miles per hour or knots, nautical miles per hour
enum DistanceMode: String, CaseIterable {
    case standard = "Standard"
    case nautical = "Knots"
    case metric = "Metric"
    
    var modeSymbol: String {
        let retValue: String
        switch self {
        case .standard:
            retValue = "SM"
        case .nautical:
            retValue = "NM"
        case .metric:
            retValue = "KM"
        }
        return retValue
    }
    
    // This method works on the assumption that the GPS system in IOS works in meters only
    //  So this is the value to convert a meter into the desired scale: mile, nautical mile or kilometer
    var modeModifier: Double {
        let retValue: Double
        switch self {
        case .standard:
            retValue = 2.23694
        case .nautical:
            retValue = 1.94384
        case .metric:
            retValue = 1
        }
        return retValue
    }
}

enum DisplayMode: String, CaseIterable {
    /// This means this is where we are
    case actualCentered
    /// This means this is where we should be
    case estimatedCentered
}


struct MetaFloat {
    var name: String
    var value: Float
}

struct MetaInt {
    var name: String
    var value: Int
}

struct MetaString {
    var name: String
    var value: String
}
