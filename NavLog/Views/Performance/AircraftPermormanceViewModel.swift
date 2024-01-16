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
    private var toCalc: TakeOffCalculator?
    private var landingCalc: LandingCalculator?
    private let standardBaroPressure: Double = 29.92
    
    func isInWeightLimits(using momentData: MomentDatum) -> Bool {
        // Add up the weight
        var isInLimits = momentData.maxWeight >= computeTotalWeight(with: momentData)
        if isInLimits {
            isInLimits = mission.cargo <= momentData.maxCargoWeight
        }
        
        return isInLimits
    }
    
    func computeCGLimits(using momentData: MomentDatum) -> Bool {
        let fuelMoment: Double = momentData.fuelArm() * (mission.fuel * momentData.fuelWeight)
        let auxFuelMoment: Double = momentData.auxFuelArm() * (mission.auxFuel * momentData.fuelWeight)
        let frontMoment: Double = momentData.frontArm() * (mission.copilotSeat + mission.pilotSeat)
        let middleMoment: Double = momentData.backArm() * mission.middleSeat
        let backMoment: Double = momentData.backArm() * mission.backSeat
        let cargoMoment: Double = momentData.cargoArm() * mission.cargo
        let oilMoment: Double = momentData.oilArm() * momentData.oilWeight
        let acftMoment: Double = momentData.aircraftArm * momentData.emptyWeight
        
        let totalMoment: Double = (fuelMoment + frontMoment + middleMoment + backMoment + cargoMoment + acftMoment + oilMoment)
      
        // Compute moment of weight using min arm
        let weightLimitArm = momentData.aircraftArm * computeTotalWeight(with: momentData)
        
        // Compare value to totalMoment... if less than, we're good
        return weightLimitArm >= totalMoment
    }
    
    func computeTotalWeight(with momentData: MomentDatum) -> Double {
        var retValue = 0.0
        if momentData.seatCount < 3 {
            // Compute pilot and copilot
            retValue = momentData.emptyWeight + mission.cargo + mission.copilotSeat + mission.pilotSeat + momentData.oilWeight
        } else if momentData.seatCount < 5 {
            // Compute front and back seat
            retValue = momentData.emptyWeight + mission.cargo + mission.copilotSeat + mission.pilotSeat + mission.backSeat + momentData.oilWeight
        } else {
            // Compute all seats
            retValue = momentData.emptyWeight + mission.cargo + mission.copilotSeat + mission.pilotSeat + mission.middleSeat + mission.backSeat + momentData.oilWeight
        }
     
        retValue = retValue + (mission.fuel * momentData.fuelWeight)
 
        if momentData.auxMaxFuelGallons > 0 {
            retValue = retValue + (mission.auxFuel * momentData.fuelWeight)
        }
        
        return retValue
    }
    
    func calculateRequiredRunwayLength(tempIsFarenheit: Bool, using momentData: MomentDatum) -> (Double, Double) {
        
        if toCalc == nil {
            toCalc = TakeOffCalculator()
            toCalc?.loadProfile()
        }
        
        // Get the standard take off length first
        guard let toCalc = self.toCalc else { return (0,0) }
            
        let toLength = toCalc.calculateTakeOffWith(tempIsFarenheit: tempIsFarenheit, acftWeight: self.computeTotalWeight(with: momentData), environment: weather)
        
        // This formula needs the preceding 'toLength' parameter to work
        let to50Length = toCalc.calculateTakeOffOver50With(environment: weather, aircraftWeight: self.computeTotalWeight(with: momentData), calculatedRunwayLength: toLength)
        
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
