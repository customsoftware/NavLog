//
//  AircraftPermormanceViewModel.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/15/23.
//

import Foundation
import Combine


class AircraftPerformanceViewModel: ObservableObject {
    @Published var weather: WeatherEnvironment = WeatherEnvironment()
    @Published var mission: MissionData = MissionData()
    @Published var momentData: MomentDatum = MomentDatum()
    private var toCalc: TakeOffCalculator?
    private var landingCalc: LandingCalculator?
    
    private let standardBaroPressure: Double = 29.92
    private(set) var momentModel: MomentDatum = MomentDatum()
    
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
        return momentModel.emptyWeight + mission.cargo + (mission.fuel * momentModel.fuelWeight) + mission.copilotSeat + mission.pilotSeat + mission.backSeat + momentModel.oilWeight
    }
    
    func calculateRequiredRunwayLength(tempIsFarenheit: Bool) -> (Double, Double) {
        
        if toCalc == nil {
            toCalc = TakeOffCalculator()
            toCalc?.loadProfile()
        }
        
        // Get the standard take off length first
        guard let toCalc = self.toCalc else { return (0,0) }
            
        let toLength = toCalc.calculateTakeOffWith(tempIsFarenheit: tempIsFarenheit, acftWeight: self.computeTotalWeight(), environment: weather)
        
        // This formula needs the preceding 'toLength' parameter to work
        let to50Length = toCalc.calculateTakeOffOver50With(environment: weather, aircraftWeight: self.computeTotalWeight(), calculatedRunwayLength: toLength)
        
        return (toLength, to50Length)
    }
    
    func calculateRequiredLandingLength() -> (Int, Int) {
        
        if landingCalc == nil {
            landingCalc = LandingCalculator()
            landingCalc?.landingProfile = toCalc?.performanceModel?.landingProfile
        }
        
        guard let landingCalc = landingCalc,
              let _ = landingCalc.landingProfile else { return (0,0) }
        
        let landingRoll = landingCalc.calculatedRequiredLandingRoll(weather)
        return (Int(landingRoll.0), Int(landingRoll.1))
    }
}
