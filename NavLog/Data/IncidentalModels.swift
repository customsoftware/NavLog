//
//  IncidentalModels.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import Foundation


/// This represents wind speeds which affect the aircraft in flight
struct Wind: Codable {
    /// This is how fast the wind is blowing measured in nautical miles per hour
    var speed: Double
    /// This is the direction the wind is blowing. This is the direction you must face to have it blowing directly into your face.
    var directionFrom: Double
}


enum CapacityMode: CaseIterable {
    case gallon
    case liter
    
    var text: String {
        let retValue: String
        
        switch self {
        case .gallon:
            retValue = "gallons"
        case .liter:
            retValue = "liters"
        }
        return retValue
    }
    
    var flow: String {
        let retValue: String
        switch self {
        case .gallon:
            retValue = "gph"
        case .liter:
            retValue = "lph"
        }
        return retValue
    }
    
    var shortText: String {
        let retValue: String
        switch self {
        case .gallon:
            retValue = "gal"
        case .liter:
            retValue = "ltr"
        }
        return retValue
    }
}


enum AltitudeMode: CaseIterable {
    case feet
    case meters
    
    var text: String {
        let retValue: String
        
        switch self {
        case .feet:
            retValue = "feet"
        case .meters:
            retValue = "meters"
        }
        
        return retValue
    }
}


// Whether values are displayed in standard miles per hour or knots, nautical miles per hour
enum SpeedMode: String, CaseIterable {
    case standard = "Mile/Hour"
    case nautical = "Knots/Hour"
    case metric = "Kilometers/Hour"
    
    var modeSymbol: String {
        let retValue: String
        switch self {
        case .standard:
            retValue = "MPH"
        case .nautical:
            retValue = "KTS"
        case .metric:
            retValue = "KPH"
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


// Whether values are displayed in standard miles per hour or knots, nautical miles per hour
enum DistanceMode: String, CaseIterable, Codable {
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
    var findConversionValue: Double {
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
    
    var fineDetail: String {
        let retValue: String
        switch self {
        case .standard:
            retValue = "feet"
        case .nautical:
            retValue = "feet"
        case .metric:
            retValue = "meters"
        }
        return retValue
    }
    
    var coarseDetail: String {
        let retValue: String
        switch self {
        case .standard:
            retValue = "miles"
        case .nautical:
            retValue = "miles"
        case .metric:
            retValue = "clicks"
        }
        return retValue
    }
    
   var conversionValue: Double {
        let retValue: Double
        switch self {
        case .standard:
            retValue = 0.000621371
        case .nautical:
            retValue = 0.000539957
        case .metric:
            retValue = 0.001
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


enum NavigationMode: CaseIterable {
    case matchHeading
    case steerToWayPoint
    
    var text: String {
        let retValue: String
        switch self {
        case .matchHeading:
            retValue = "Match HDG"
            // This displays the aircraft heading in the offset bar and the desired heading in the fixed center bar.
        case .steerToWayPoint:
            retValue = "Steer TO"
            // This displays the heading to the waypoint in the center bar and the aircraft heading in the offset bar.
        }
        
        return retValue
    }
}

enum OperationMode: Int, CaseIterable, Codable {
    case climb
    case cruise
    case descend
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
