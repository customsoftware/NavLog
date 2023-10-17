//
//  FlightPlan.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/13/23.
//

import Foundation

// This is the Garmin structure

struct FlightPlan {
    var created: Date
    var waypointTable: [WayPoint]
    var route: Route
}


struct Way_Point: Codable {
    var identifier: String
    var type: String
    var countryCode: String
    var lat: Double
    var lon: Double
    var comment: String
}


struct Route {
    var routeName: String
    var flightPlanIndex: Int
    /// In the actual XML there is no array, it's a flat file
    var routePoint: [RoutePoint]
}


struct RoutePoint {
    var wayPointIdentifier: String
    var wayPointType: String
    var wayPointCountryCode: String
}


// This is the Dynon structure
struct Rte {
    var name: String
    var routePoints: [RtEpt]
}


struct RtEpt {
    
    var name: String
    var overfly: Bool
}
