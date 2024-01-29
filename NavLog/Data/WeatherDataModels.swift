//
//  WeatherDataModels.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/18/23.
//

import Foundation

struct WeatherReport: Codable {
    var queryCost: Int
    var latitude: Double
    var longitude: Double
    var resolvedAddress: String
    var address: String
    var timezone: String
    var tzoffset: Int
    var description: String
//    var days: [WeatherDay]
//    var alerts: [String]?
//    var stations: [String: WeatherStationDetails]
    var currentConditions: ReportCondition
}

struct WeatherCondition: Codable {
    var datetime: String
    var datetimeEpoch: Double
    var temp: Double
    var feelslike: Double
    var humidity: Double
    var dew: Double
    var precip: Double
    var precipprob: Double
    var snow: Double
    var snowdepth: Double
    var preciptype: Double?
    var windgust: Double
    var windspeed: Double
    var winddir: Double
    var pressure: Double
    var visibility: Double
    var cloudcover: Double
    var solarradiation: Double
    var solarenergy: Double
    var uvindex: Double
    var severerisk: Double
    var conditions: String
    var icon: String
    var stations: [String]?
    var source: String
}

struct ReportCondition: Codable {
//    var datetime: String
//    var datetimeEpoch: Double
    var temp: Double
//    var feelslike: Double
//    var humidity: Double
//    var dew: Double
//    var precip: Double
//    var precipprob: Double
//    var snow: Double
//    var snowdepth: Double
//    var preciptype: Double?
    var windgust: Double
    var windspeed: Double
    var winddir: Double
    var pressure: Double
//    var visibility: Double
//    var cloudcover: Double
//    var solarradiation: Double
//    var solarenergy: Double
//    var uvindex: Double
//    var conditions: String
//    var icon: String
//    var stations: [String]?
//    var source: String
//    var sunrise: String
//    var sunriseEpoch: Double
//    var sunset: String
//    var sunsetEpoch: Double
//    var moonphase: Double
}

struct WeatherStationDetails: Codable {
    var distance: Int
    var latitude: Double
    var longitude: Double
    var useCount: Int
    var id: String
    var name: String
    var quality: Int
    var contribution: Int
}

struct WeatherDay: Codable {
    var datetime: String
    var datetimeEpoch: Double
    var tempmax: Double
    var tempmin: Double
    var temp: Double
    var feelslikemax: Double
    var feelslikemin: Double
    var dew: Double
    var humidity: Double
    var precip: Double
    var precipprob: Double
    var precipcover: Double
    var preciptype: Double?
    var snow: Double
    var snowdepth: Double
    var windgust: Double
    var windspeed: Double
    var winddir: Double
    var pressure: Double
    var cloudcover: Double
    var visibility: Double
    var solarradiation: Double
    var solarenergy: Double
    var uvindex: Double
    var severerisk: Double
    var sunrise: String
    var sunriseEpoch: Double
    var sunset: String
    var sunsetEpoch: Double
    var moonphase: Double
    var conditions: String
    var description: String
    var icon: String
    var stations: [String]?
    var source: String
    var hours: [WeatherCondition]
}

struct LimitedCondition : Codable {
    var stations: [String: WeatherStationDetails]
}


/// A property wrapper for properties of a type that should be "skipped" when the type is encoded or decoded.
@propertyWrapper
public struct NotCoded<Value> : Codable {
  private var value: Value?
  public init(wrappedValue: Value?) {
    self.value = wrappedValue
  }
  public var wrappedValue: Value? {
    get { value }
    set { self.value = newValue }
  }
}

extension NotCoded {
  public func encode(to encoder: Encoder) throws {
    // Skip encoding the wrapped value.
  }
  public init(from decoder: Decoder) throws {
    // The wrapped value is simply initialised to nil when decoded.
    self.value = nil
  }
}
