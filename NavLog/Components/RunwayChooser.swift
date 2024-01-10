//
//  RunwayChooser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/9/24.
//

import Foundation

class RunwayChooser: ObservableObject {
    @Published var runwayDirections: [Double: Runway] = [:]
    
    /// Where there are multiple runways to choose from, use this method.
    /// - Parameters:
    ///    - runways - This is an array of runways available at the airport
    ///    - wind - This is the direction the wind is coming from in degrees.
    /// - Returns:
    ///     - A Tuple, containing the selected runway and the direction of that runway which should be used.
    ///  This method relies solely upon wind speed to make the determination.
    func chooseFrom(the runways: [Runway], wind: Double) -> (Runway, Double) {
        runwayDirections.removeAll()
        _ = runways.map { aRunway in
            if aRunway.id.contains("/") {
                let axise = aRunway.getRunwayAxis()
                runwayDirections[Double(axise.0)] = aRunway
                runwayDirections[Double(axise.1)] = aRunway
            }
        }
        
        var candidates: [Double: Runway] = [:]
       
        // This gets rid of the runways which have a tailwind component
        runwayDirections.keys.forEach({ aDirection in
            let runwayDirection = (aDirection * 10)
            if runwayDirection - wind < 90 {
                candidates[aDirection] = runwayDirections[aDirection]!
            }
        })
        
        // Get the best match of the remaining runways
        var matchDirection = candidates.first!.key * 10
        var matchRunway = candidates.first!.value
        
        candidates.keys.forEach { aDirection in
            let runwayDirection = (aDirection * 10)
            let aCandidate = candidates[aDirection]
            if abs(matchDirection - wind) > abs(runwayDirection - wind) {
                matchDirection = runwayDirection
                matchRunway = aCandidate!
            }
        }
        
        return (matchRunway, (matchDirection/10))
    }
    
    /// Where there is just one published runway at an airport, this takes each direction of the runway and return the runway direction most favorable to the wind.
    /// - Parameters:
    ///     - runwayOne - Int
    ///     - runwayTwo Int
    ///     - wind double
    /// - Returns:
    ///     - A double indicating the runway direction to use
    /// This uses relative wind only to determine the best runway to use.
    static func chooseTheRunway(_ runwayOne: Int, _ runwayTwo: Int, wind: Double) -> Double {
        var retValue: Double = 0
        let runway1 = runwayOne * 10
        let runway2 = runwayTwo * 10
        
        let runDelta1 = Double(runway1) - wind
        let runDelta2 = Double(runway2) - wind
        
        if runDelta1 < runDelta2 {
            retValue = Double(runwayOne)
        } else {
            retValue = Double(runwayTwo)
        }
        
        return retValue
    }
    
    
}
