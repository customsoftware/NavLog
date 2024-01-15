//
//  AirportData.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import Foundation


// https://aviationweather.gov/api/data/airport?ids=KPUC&format=json

struct Runway: Hashable, Codable {
    var id: String
    var dimension: String
    var surface: String
    var alignment: String
    var direction: Int? = 0
    
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


struct AirportData: Hashable, Codable {
    var name: String?
    var iata: String
    var runways: [Runway]
    
    enum CodingKeys: String, CodingKey {
        case name = "id"
        case iata
        case runways
    }
    
    mutating func setRunways() {
        guard runways.count > 0 else { return }
        var runwayHolder: [Runway] = []
        runways.forEach { runway in
            guard runway.id.contains("/") else { return }
            let directions = runway.id.components(separatedBy: "/")
            guard directions.count == 2 else { return }
            let firstDirection = directions.first!
            let lastDirection = directions.last!
            guard lastDirection != firstDirection else { return }
            
            runwayHolder.append(Runway(id: runway.id, dimension: runway.dimension, surface: runway.surface, alignment: runway.alignment, direction: NSString(string: firstDirection).integerValue))
            runwayHolder.append(Runway(id: runway.id, dimension: runway.dimension, surface: runway.surface, alignment: runway.alignment, direction: NSString(string: lastDirection).integerValue))
        }
        runways = runwayHolder
    }
}
