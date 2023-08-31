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
    var speed: Int
    /// This is the direction the wind is blowing. This is the direction you must face to have it blowing directly into your face.
    var directionFrom: Int
}


// Whether values are displayed in standard miles per hour or knots, nautical miles per hour
enum DistanceMode: String, CaseIterable {
    case standard = "Standard"
    case nautical = "Knots"
    case metric = "Metric"
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
