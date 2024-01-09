//
//  AirportData.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import Foundation


// https://aviationweather.gov/api/data/airport?ids=KPUC&format=json

struct Runway: Codable {
    var id: String
    var dimension: String
    var surface: String
    var alignment: String
    
    var runwayLength: Int {
        let runwayComponents = dimension.components(separatedBy: "x")
        let retValue = (runwayComponents[0] as NSString).intValue
        return Int(retValue)
    }
    
    func getRunwayAxis() -> (Int, Int) {
        let axisComponents = id.components(separatedBy: "/")
        let axis1 = (axisComponents[0] as NSString).integerValue
        let axis2 = (axisComponents[1] as NSString).integerValue
        return (axis1, axis2)
    }
}


struct AirportData: Codable {
    var name: String?
    var iata: String
    var runways: [Runway]
    
    enum CodingKeys: String, CodingKey {
        case name = "id"
        case iata
        case runways
    }
}
