//
//  METARData.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/5/24.
//

import Foundation


// -- Model Code
struct AirportWeather {
    private let hectoToInches: Double = 0.02953
    private let metersToFeet: Double = 3.28084
    var icaoId: String
    var temp: Double?
    var altim: Double?
    // Elevation in meters
    var elev: Int?
    // Elevation in feet
    var elevation: Double? {
        guard let elevationM = elev else { return nil }
        return Double(elevationM) * metersToFeet
    }
    var windSpeed: String?
    var windDirection: String?
    var lat: Double?
    var lon: Double?
    // Gives pressure in inches of mercury
    var altimeterSetting: Double {
        guard let alt = altim else { return 29.92 }
        return alt * hectoToInches
    }
    var wind: String {
        return "\(windDirection ?? "")@\(windSpeed ?? "")"
    }
}

struct InterimAirportWeather: Codable {
    // The plan here is to get the "simple" data:
    //  Airport symbol
    //  Temp
    //  Baro pressure
    //  elevation
    //  altimeter setting
    //  lat
    //  long
    var metar_id: Int
    var icaoId: String
    var temp: Double?
    var altim: Double?
    var elev: Int?
    var lat: Double?
    var lon: Double?
    
    func buildAirportWeather(withSpeed windFlex: VariableWindSpeed?, andDirection directionFlex: VariableWindDirection?) -> AirportWeather {
        
        let retValue = AirportWeather(icaoId: self.icaoId, temp: self.temp, altim: self.altim, elev: self.elev, windSpeed: windFlex?.windSpeed, windDirection: directionFlex?.windDirection, lat: self.lat, lon: self.lon)
        return retValue
    }
}

enum FlexibleValue {
    case stringValue(String)
    case intValue(Int)
}


// -- Speed
protocol VariableWindSpeed {
    var windSpeed: String { get }
}

struct AiportWindSpeedString: Codable, VariableWindSpeed {
    var icaoId: String
    var metar_id: Int
    var wspd: String?
    var windSpeed: String {
        get {
            return wspd ?? ""
        }
    }
}

struct AiportWindSpeedInt: Codable, VariableWindSpeed {
    var icaoId: String
    var metar_id: Int
    var wspd: Int?
    var windSpeed: String {
        get {
            return "\(wspd ?? 0)"
        }
    }
}

// -- Direction
protocol VariableWindDirection {
    var windDirection: String { get }
}

struct AiportWindDirectionString: Codable, VariableWindDirection {
    var icaoId: String
    var metar_id: Int
    var wdir: String?
    var windDirection: String {
        get {
            return wdir ?? ""
        }
    }
}

struct AiportWindDirectionInt: Codable, VariableWindDirection {
    var icaoId: String
    var metar_id: Int
    var wdir: Int?
    var windDirection: String {
        get {
            return "\(wdir ?? 0)"
        }
    }
}

enum HTTPError: Error {
    case badURL
    case structure
    case multiWithSingle
    case singleWithMulti
}
