//
//  TakeOffCalculator.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import Foundation


class TakeOffCalculator {
    var performanceModel: PerformanceProfile?
    
    func calculateTakeOffWith(tempIsFarenheit: Bool, acftWeight: Double, environment: Environment) -> Double {
        
        let airportElevation = environment.elevation
        
        var workingTemp = environment.temp
        if !tempIsFarenheit {
            workingTemp = StandardTempCalculator.convertCtoF(environment.temp)
        }
        
        
        // Find the takeoff value which is closest to but less than the aircraft weight
        let toWeight: TakeOffWeight? = returnClosestTakeOff(with: acftWeight)
        
        // Find the modifier to determine runway length at elevation closest to but below airport elevation
        let multiple: [Multiple]? = returnClosestElevation(to: airportElevation)
        
        // Confirm we have something to work with
        guard let takeOffWeight = toWeight,
              let multipliers = multiple,
              let lastMultiple = multipliers.last else { return 0 }
        
        // First set the base runway length
        var newRunwayLength = adjustRunwayLength(originalLength: takeOffWeight.roll, multipliers: multipliers)
        
        // Adjust for altitude
        newRunwayLength = adjustRunwayLengthToAltitude(newRunwayLength, originalRoll: takeOffWeight.roll, baseElevation: lastMultiple.elevation, airportElevation: airportElevation)
        
        // Adjust for weight
        if airportElevation > lastMultiple.elevation {
            newRunwayLength = round(newRunwayLength * lastMultiple.multiple)
        }
        // Adjust for temperature
        newRunwayLength = adjustRunwayLengthToTemperature(newRunwayLength, airportElevation: airportElevation, currentTemperatureF: workingTemp)
        
        // Adjust for wind
        newRunwayLength = adjustRunwayLengthForWind(environment: environment, aircraftWeight: acftWeight, calculatedRunway: newRunwayLength)
        
        return newRunwayLength
    }
    
    func calculateTakeOffOver50With(environment: Environment, aircraftWeight: Double, calculatedRunwayLength: Double) -> Double {
        var newRunwayLength = calculatedRunwayLength
        let multiple = returnClosest50Elevation(to: environment.elevation)
        
        guard let lastMultiple = multiple.last else { return 0 }
        newRunwayLength = newRunwayLength * lastMultiple.multiple
        
        newRunwayLength = adjustRunwayLengthOver50ForWind(environment: environment, aircraftWeight: aircraftWeight, calculatedRunway: newRunwayLength)
        
        return round(newRunwayLength)
    }
    
    func loadProfile() {
        // This will change as the app evolves, right now it hard codes to a file
        guard let perfProfilePath = Bundle.main.path(forResource: "CardinalTakeOff", ofType: "json")
        else { return }
        do {
            let perfJSON = try String(contentsOfFile: perfProfilePath).data(using: .utf8)
            let performanceProfile = try JSONDecoder().decode(PerformanceProfile.self, from: perfJSON!)
            performanceModel = performanceProfile
        } catch {
            print("Reading the file didn't work. Error: \(error.localizedDescription)")
        }
    }
    
}

fileprivate extension TakeOffCalculator {
    
    func returnClosestTakeOff(with acftWeight: Double) -> TakeOffWeight? {
        
        guard let profile = performanceModel else { return nil }
        
        var retValue: TakeOffWeight?
        var weightDelta: Double = acftWeight
        let array : [TakeOffWeight] = profile.takeoff
        _ = array.map({ aTOWeight in
            let newDelta = abs(aTOWeight.weight - acftWeight)
            if newDelta < weightDelta {
                retValue = aTOWeight
                weightDelta = newDelta
            }
        })
        
        return retValue
    }
    
    func getNextTakeOffWeight(_ toWeight: TakeOffWeight) -> TakeOffWeight {
        let retValue = toWeight
        guard let performanceModel = self.performanceModel else { return retValue }
        
        let array : [TakeOffWeight] = performanceModel.takeoff
        let foundValue = array.first(where: { aMap in
            aMap.weight > toWeight.weight
        })
        guard let found = foundValue else { return retValue }
        return found
    }
    
    func returnClosestElevation(to airportElevation: Double) -> [Multiple] {
        var retValue: [Multiple] = []
        
        guard let performanceModel = self.performanceModel else { return retValue }
        
        var elevationDelta: Double = airportElevation
        
        let multipliers: [Multiple] = performanceModel.multipliers
        _ = multipliers.map({ aMultiple in
            let newDelta = abs(aMultiple.elevation - airportElevation)
            if newDelta < elevationDelta {
                elevationDelta = newDelta
                retValue.append(aMultiple)
            }
        })
        
        return retValue
    }
    
    func returnClosest50Elevation(to airportElevation: Double) -> [Multiple] {
        var retValue: [Multiple] = []
        guard let performanceModel = self.performanceModel else { return retValue }
        
        var elevationDelta: Double = airportElevation
        
        let multipliers: [Multiple] = performanceModel.multipliers50
        _ = multipliers.map({ aMultiple in
            let newDelta = abs(aMultiple.elevation - airportElevation)
            if newDelta <= elevationDelta {
                elevationDelta = newDelta
                retValue.append(aMultiple)
            }
        })
        
        return retValue
    }
    
    func adjustRunwayLength(originalLength: Double, multipliers: [Multiple]) -> Double {
        var newLength = originalLength
        
        multipliers.forEach { aMultiple in
            newLength = aMultiple.multiple * newLength
        }
        return round(newLength)
    }
    
    func adjustRunwayLengthToAltitude(_ newRunwayLength: Double, originalRoll: Double, baseElevation: Double, airportElevation: Double) -> Double {
        let deltaLength = newRunwayLength - originalRoll
        let deltaElevation = (airportElevation - baseElevation)
        
        let adjustmentToBaseElevation: Double
        if deltaLength != 0 {
            let deltaPerFootElevation = deltaLength/baseElevation
            adjustmentToBaseElevation = deltaElevation * deltaPerFootElevation
        } else {
            adjustmentToBaseElevation = 0
        }
        return round(adjustmentToBaseElevation + newRunwayLength)
    }
    
    func adjustRunwayLengthToTemperature(_ runwayLength: Double, airportElevation: Double, currentTemperatureF: Double) -> Double {
        var newRunwayLength = runwayLength
        guard let performanceModel = self.performanceModel else { return newRunwayLength }
        
        // Get standard temperature for absolute elevation
        let standardTempC = StandardTempCalculator.computeStandardTempForAltitude(airportElevation)
        // Convert it to farenheit
        let standardTempF = round(StandardTempCalculator.convertCtoF(standardTempC))
        
        // Get delta from standard temp to current temp
        let deltaTemp = currentTemperatureF - standardTempF
        
        // Get multiplier fraction
        let deltaFraction = deltaTemp/performanceModel.temperatureBand
        // Get change rate
        let deltaRate = 1 + (deltaFraction * performanceModel.temperatureDeltaRate)
        // Adjust runwayLength
        newRunwayLength = newRunwayLength * deltaRate
        
        return round(newRunwayLength)
    }
    
    func adjustRunwayLengthForWind(environment: Environment, aircraftWeight: Double, calculatedRunway: Double) -> Double {
        var newRunwayLength = calculatedRunway
        
        // Compute the relative wind
        guard environment.runwayDirection > 0,
              environment.windSpeed > 5,
              environment.windDirection > 0 else { return newRunwayLength }
        
        // Get the runway heading and multiply is by 10
        let runwayHeading = environment.runwayDirection * 10
        
        // Subtract the runway heading from the wind. Since we want absolute, we can do abs() to the value
        let relativeWindDirection = abs(runwayHeading - environment.windDirection)
        
        var isHeadWind: Bool = true
        if relativeWindDirection > 90 {
            isHeadWind = false
        }
        
        // Then it's triginometry to get the headwind (a negative value means you have a tail wind)
        // Convert the relativeWindDirection to radian
        let radWind = TrigTool.deg2rad(relativeWindDirection)
        
        let cosOfWind = cos(radWind)
        
        // I need the cos of the wind speed over the relativeWindDirection
        var parallelWind = cosOfWind * environment.windSpeed
        
        parallelWind = round(parallelWind * 100)/100
        
        guard let matchingWindMultiple = getBestMatchingWind(for: parallelWind, aircraftWeight: aircraftWeight, over50: false) else { return newRunwayLength }
        
        let windModifierPartOne = parallelWind / matchingWindMultiple.wind
        let maxReducedLength = newRunwayLength * matchingWindMultiple.multiple
        let deltaLength = (calculatedRunway - maxReducedLength) * windModifierPartOne
        newRunwayLength = round(newRunwayLength - deltaLength)
        
        return newRunwayLength
    }
    
    func adjustRunwayLengthOver50ForWind(environment: Environment, aircraftWeight: Double, calculatedRunway: Double) -> Double {
        var newRunwayLength = calculatedRunway
        
        // Compute the relative wind
        guard environment.runwayDirection > 0,
              environment.windSpeed > 5,
              environment.windDirection > 0 else { return newRunwayLength }
        
        // Get the runway heading and multiply is by 10
        let runwayHeading = environment.runwayDirection * 10
        
        // Subtract the runway heading from the wind. Since we want absolute, we can do abs() to the value
        let relativeWindDirection = abs(runwayHeading - environment.windDirection)
        
        var isHeadWind: Bool = true
        if relativeWindDirection > 90 {
            isHeadWind = false
        }
        
        // Then it's triginometry to get the headwind (a negative value means you have a tail wind)
        // Convert the relativeWindDirection to radian
        let radWind = TrigTool.deg2rad(relativeWindDirection)
        
        let cosOfWind = cos(radWind)
        
        // I need the cos of the wind speed over the relativeWindDirection
        var parallelWind = cosOfWind * environment.windSpeed
        
        parallelWind = round(parallelWind * 100)/100
        
        guard let matchingWindMultiple = getBestMatchingWind(for: parallelWind, aircraftWeight: aircraftWeight, over50: true) else { return calculatedRunway }
        
        let windModifierPartOne = parallelWind / matchingWindMultiple.wind
        let maxReducedLength = newRunwayLength * matchingWindMultiple.multiple
        let deltaLength = (calculatedRunway - maxReducedLength) * windModifierPartOne
        newRunwayLength = round(newRunwayLength - deltaLength)
        
        return newRunwayLength
    }

    
    func getBestMatchingWind(for windSpeed: Double, aircraftWeight: Double, over50: Bool) -> WindMultiples? {
        var retValue: WindMultiples?
        var windDelta: Double = 100
        var weightDelta: Double = 2000
        
        guard let performanceModel = self.performanceModel else { return retValue }
        
        var matches: [WindMultiples] = []
        // Find the best wind delta
        var foundWindMatch: WindMultiples?
        performanceModel.windrates.forEach({ windMultiple in
            if windMultiple.wind <= windDelta {
                windDelta = abs(windSpeed - windMultiple.wind)
                foundWindMatch = windMultiple
            }
        })
        
        // Get the rest of the matches
        if let aMatch = foundWindMatch {
            performanceModel.windrates.forEach({ windMultiple in
                if aMatch.wind == windMultiple.wind {
                    matches.append(windMultiple)
                }
            })
        }
        
        // Find the best weight delta
        var foundWeightMatch: WindMultiples?
        matches.forEach({ weightMultiple in
            if weightMultiple.weight <= weightDelta,
               weightMultiple.for50 == over50 {
                weightDelta = abs(aircraftWeight - weightMultiple.weight)
                foundWeightMatch = weightMultiple
            }
        })
        
        // Get the rest of the matches
        if let aMatch = foundWeightMatch {
            matches.forEach({ weightMultiple in
                if aMatch.weight == weightMultiple.weight,
                   weightMultiple.for50 == over50 {
                    retValue = weightMultiple
                }
            })
        }
        
        return retValue
    }
}

struct TrigTool {
    
    static func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    static func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
}
