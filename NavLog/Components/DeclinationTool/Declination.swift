//
//  Declination.swift
//  CombineWeather
//
//  Created by Kenneth Cluff on 11/6/23.
//

/// The plan here is to build an app that displays a map. You touch it and it will give you the magnetic declination for that geographich coordinate.


import Foundation

public struct DecData : Codable {
//    var date: Double
//    var elevation: Int
    public var declination: Double
//    var latitude: Int
//    var declnation_sv: Double
//    var declination_uncertainty: Double
//    var longitude: Double
}

//struct DecUnits: Codable {
//    var elevation: String
//    var declination: String
//    var declination_sv: String
//    var latitude: String
//    var declination_uncertainty: String
//    var longitude: String
//}

public struct DeclinationResults : Codable {
    public var result : [DecData]
//    var model: String
//    var units: DecUnits
//    var version: String
}

