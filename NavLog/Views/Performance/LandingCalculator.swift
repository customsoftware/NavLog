//
//  LandingCalculator.swift
//  NavLog
//
//  Created by Kenneth Cluff on 12/1/23.
//

import Foundation

class LandingCalculator {
    
    var landingProfile: Landing?
    
    func configureWith(landingProfile: Landing) {
        self.landingProfile = landingProfile
    }
    
    func calculatedRequiredLandingRoll(_ densityAlt: Int, _ environment: Environment) -> (Int, Int)  {
        
        guard let landingProfile = self.landingProfile else { return (0, 0) }
        
        var toLength = Int(landingProfile.baseRunwayRoll)
        var to50Length = Int(Double(toLength) * landingProfile.over50Ratio)
        
        var underAdd: Double = 0
        var overAdd: Double = 0
        
        if densityAlt <= landingProfile.divider {
            underAdd = Double(densityAlt) * landingProfile.loRatio
        } else {
            underAdd = Double(landingProfile.divider) * landingProfile.loRatio
            overAdd = Double(densityAlt - landingProfile.divider) * landingProfile.hiRatio
        }
        
        let baseLength = landingProfile.baseRunwayRoll + (underAdd + overAdd)
        let _50Length = baseLength * landingProfile.over50Ratio
        
        // Compensate for wind:
        // Find head wind component
        // Subtract the runway heading from the wind. Since we want absolute, we can do abs() to the value
        let relativeWindDirection = abs((environment.runwayDirection * 10) - environment.windDirection)
        // Then it's triginometry to get the headwind (a negative value means you have a tail wind)
        // Convert the relativeWindDirection to radian
        let radWind = TrigTool.deg2rad(relativeWindDirection)
        let cosOfWind = cos(radWind)
        // I need the cos of the wind speed over the relativeWindDirection
        var parallelWind = cosOfWind * environment.windSpeed
        parallelWind = round(parallelWind * 100)/100
        let windModifier = (parallelWind / landingProfile.windIndex) * landingProfile.windRate
        
        toLength = Int(baseLength - (baseLength * windModifier))
        to50Length = Int(_50Length - (baseLength * windModifier))
        return (toLength, to50Length)
    }
}
