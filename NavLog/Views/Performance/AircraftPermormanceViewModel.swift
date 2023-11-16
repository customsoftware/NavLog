//
//  AircraftPermormanceViewModel.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/15/23.
//

import Foundation
import Combine


class AircraftPerformanceViewModel: ObservableObject {
    @Published var environment: Environment = Environment()
    @Published var mission: MissionData = MissionData()
    let calc = TakeOffCalculator()
    
    private let standardBaroPressure: Double = 29.92
    
    var momentModel: MomentDatum = MomentDatum()
    
    func computePerformance() {
        environment.save()
    }
    
    func isInWeightLimits() -> Bool {
        // Add up the weight
        var isInLimits = momentModel.maxWeight >= computeTotalWeight()
        if isInLimits {
            isInLimits = mission.cargo <= momentModel.maxCargoWeight
        }
        
        return isInLimits
    }
    
    func computeCGLimits() -> Bool {
        let fuelMoment: Double = momentModel.fuelArm * (mission.fuel * momentModel.fuelWeight)
        let frontMoment: Double = momentModel.frontArm * (mission.copilotSeat + mission.pilotSeat)
        let middleMoment: Double = momentModel.backArm * mission.middleSeat
        let backMoment: Double = momentModel.backArm * mission.backSeat
        let cargoMoment: Double = momentModel.cargoArm * mission.cargo
        let oilMoment: Double = momentModel.oilArm * momentModel.oilWeight
        let acftMoment: Double = momentModel.aircraftArm * momentModel.emptyWeight
        
        let totalMoment: Double = (fuelMoment + frontMoment + middleMoment + backMoment + cargoMoment + acftMoment + oilMoment)
      
        // Compute moment of weight using min arm
        let weightLimitArm = momentModel.aircraftArm * computeTotalWeight()
        
        // Compare value to totalMoment... if less than, we're good
        return weightLimitArm >= totalMoment
    }
    
    func computeTotalWeight() -> Double {
        return momentModel.emptyWeight + mission.cargo + mission.fuel * momentModel.fuelWeight + mission.copilotSeat + mission.pilotSeat + mission.backSeat + momentModel.oilWeight
    }
    
    func computePressureAltitude() -> Double {
        let pressureDelta = (standardBaroPressure - environment.pressure) * 1000
        return environment.elevation + pressureDelta
    }
    
    func computeDensityAltitude(for pressureAlt: Double, tempIsCelsius: Bool) -> Double {
        // PA + (120 x (OAT – ISA))
        var workingTemp = environment.temp
        if !tempIsCelsius {
            workingTemp = StandardTempCalculator.convertFtoC(environment.temp)
        }
        
        let densityDelta = (workingTemp - StandardTempCalculator.computeStandardTempForAltitude(environment.elevation))
        let densityAltitude = pressureAlt + (120 * densityDelta)
        return densityAltitude
    }
    
    func loadProfile(with name: String) {
        calc.loadProfile()
    }
    
    func calculateRequiredRunwayLength(tempIsFarenheit: Bool) -> (Double, Double) {
        
        // Get the standard take off length first
        let toLength = calc.calculateTakeOffWith(tempIsFarenheit: tempIsFarenheit, acftWeight: self.computeTotalWeight(), environment: environment)
        
        // This formula needs the preceding 'toLength' parameter to work
        let to50Length = calc.calculateTakeOffOver50With(environment: environment, aircraftWeight: self.computeTotalWeight(), calculatedRunwayLength: toLength)
        return (toLength, to50Length)
    }
}
