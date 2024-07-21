//
//  PerformanceConstants.swift
//  NavLog
//
//  Created by Kenneth Cluff on 7/20/24.
//

import Foundation

struct PerformanceConstants {
    struct Sections {
        static let titleAirport = "Airport".localizedCapitalized
        static let titleWeather = "Weather".localizedCapitalized
        static let titleMissionLoad = "Mission Load".localizedCapitalized
        static let titlePlanning = "Planning".localizedCapitalized
        static let titleResults = "Results".localizedCapitalized
    }
    
    struct Steps {
        static let one = "1. Get Airport and Weather".localizedCapitalized
        static let two = "2. Choose Aircraft".localizedCapitalized
        static let three = "3. Calculate Performance".localizedCapitalized
    }
    
    struct String {
        static let nearbyAirports = "Nearby Airports".localizedCapitalized
        static let airport = "Airport".localizedCapitalized
        static let elevation = "Elevation".localizedCapitalized
        static let pressure = "Pressure".localizedCapitalized
        static let temperature = "Temperature".localizedCapitalized
        static let tempCelsius = "Temperature - C".localizedCapitalized
        static let windDirection = "Wind Direction".localizedCapitalized
        static let windSpeed = "Wind Speed".localizedCapitalized
        static let pilot = "Pilot".localizedCapitalized
        static let coPilot = "Co-Pilot".localizedCapitalized
        static let middleSeat = "Middle Seat".localizedCapitalized
        static let backSeat = "Back Seat".localizedCapitalized
        static let cargo = "Cargo".localizedCapitalized
        static let fuelWings = "Fuel Wings".localizedCapitalized
        static let fuelIn = "Fuel in".localizedCapitalized
        static let fuelWarning = "You can't load more than".localizedCapitalized
        static let auxFuelGallons = "Aux Fuel in Gallons".localizedCapitalized
        static let auxFuelTank = "Aux Fuel Tanks".localizedCapitalized
        static let runwayDirection = "Runway Direction".localizedCapitalized
        static let runwayLength = "Runway Length".localizedCapitalized
        static let runway = "Runway".localizedCapitalized
        static let direction = "Direction".localizedCapitalized
        static let navigationTitle = "Weight & Balance".localizedCapitalized
        static let gallons = "gallons"
        static let liters = "liters"
 }
}
