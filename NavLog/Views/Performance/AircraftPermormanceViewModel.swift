//
//  AircraftPermormanceswift
//  NavLog
//
//  Created by Kenneth Cluff on 11/15/23.
//

import Foundation
import Combine
import CoreLocation

class AircraftPerformanceViewModel: ObservableObject {
    @Published var weather: WeatherEnvironment = WeatherEnvironment()
    @Published var mission: MissionData = MissionData()
    @Published var complexParser = ComplexMetarParser()
    @Published var airportParser = AirportParser()
    @Published var runwayChooser = RunwayChooser()
    @Published var metrics = AppMetricsSwift.settings
    @Published var nearbyAirports: [AirportData] = [AirportData]()
    @Published var aircraftManager = Core.services.acManager
    private var theWeather: AirportWeather? {
        didSet {
            guard let weather = theWeather else {
                resetAirfieldValues()
                return }
            setAirfieldValues(weather)
        }
    }
    
    var currentLocation: CLLocation?
    private var toCalc: TakeOffCalculator?
    private var landingCalc: LandingCalculator?
    private let standardBaroPressure: Double = 29.92
    var missionPerformance = PerformanceResults()
    
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
    
    func calculatePerformance(temperatureInDegreesC: Bool) {
        if runwayChooser.selectedRunway.id != "" {
            weather.runwayDirection = Double(runwayChooser.selectedRunway.direction ?? 0)
            weather.runwayLength = Double(runwayChooser.selectedRunway.runwayLength)
        }
        weather.save()
        // I want all this done in the missionPerformance object, but it works for now.
        missionPerformance.cgIsInLimits = computeCGLimits(using: aircraftManager.chosenAircraft)
        missionPerformance.isUnderGross = isInWeightLimits(using: aircraftManager.chosenAircraft)
        missionPerformance.overWeightAmount = (computeTotalWeight(with: aircraftManager.chosenAircraft) - aircraftManager.chosenAircraft.maxWeight)
        
        let runwayCalculations = calculateRequiredRunwayLength(tempIsFarenheit: !temperatureInDegreesC, using: aircraftManager.chosenAircraft)
        missionPerformance.computedTakeOffRoll = runwayCalculations.0
        missionPerformance.computedOver50Roll = runwayCalculations.1
        
        let landingCalculations = calculateRequiredLandingLength()
        missionPerformance.computedLandingRoll = landingCalculations.0
        missionPerformance.computedLandingOver50Roll = landingCalculations.1
        mission.save()
    }
    
    func findAirportData() {
        guard let chosenName = airportParser.chosenAirport.icaoId else { return }
        if chosenName.count > 2,
           chosenName != weather.airportCode {
            weather.airportCode = chosenName
        }
        
        guard (weather.airportCode.count > 2 || airportParser.chosenAirport.name.count > 1),
              self.currentLocation == nil
        else {
            //  Here we could look for airports around us...
            if let _ = self.currentLocation {
                self.getLocalAirports()
            } else {
                DispatchQueue.global().async(execute: {
                    Core.services.gpsEngine.startTrackingLocation()
                    var x = 0
                    let now = Date()
                    // Wait till we get a location
                    while Core.services.gpsEngine.currentLocation == nil,
                          Date().timeIntervalSince(now) < 5  {
                        x += 1
                    }
                    self.currentLocation = Core.services.gpsEngine.currentLocation
                    Core.services.gpsEngine.stopTrackingLocation()
                    self.getLocalAirports()
                })
            }
            return
        }
        
        // Load the results into the view controls
        Task {
            _ = try! await complexParser.fetchWeatherData(for: [weather.airportCode])
            theWeather = complexParser.weather.first
            
            _ = try! await airportParser.fetchAirportData(for: weather.airportCode)
            let runways = airportParser.runways
            if runways.count > 1 {
                let bestAlignment = runwayChooser.chooseFrom(the: runways, wind: weather.windDirection)
                if let direction = bestAlignment.1,
                   let aRunway = bestAlignment.0 {
                    self.setRunwayData(with: direction, and: Double(aRunway.runwayLength))
                    runwayChooser.selectedRunway = aRunway
                }
            }
            self.saveWeather()
        }
    }
}
 
fileprivate extension AircraftPerformanceViewModel {
    func setRunwayData(with direction: Double, and length: Double) {
        DispatchQueue.main.sync {
            weather.runwayDirection = direction
            weather.runwayLength = length
        }
    }
    
    func saveWeather() {
        DispatchQueue.main.sync {
            weather.save()
        }
    }
    
    func getLocalAirports() {
        guard let aLocation = Core.services.gpsEngine.currentLocation else { return }
        Task {
            _ = try! await airportParser.fetchNearbyAirports(for: aLocation, closeIn: true)
            DispatchQueue.main.sync {
                if airportParser.airports.count > 0,
                   airportParser.airports.count < 2 {
                    weather.airportCode = airportParser.airports.first!.faaId
                    currentLocation = nil
                    findAirportData()
                } else if airportParser.airports.count > 1 {
                    nearbyAirports = airportParser.airports
                    weather.airportCode = airportParser.airports.first!.faaId
                    currentLocation = nil
                    findAirportData()
                }
            }
        }
    }
    
    func setAirfieldValues(_ newWeather: AirportWeather) {
        DispatchQueue.main.sync {
            weather.airportCode = newWeather.icaoId
            if let aTemp = newWeather.temp {
                weather.temp = aTemp
            }
            if let _ = newWeather.altim {
                weather.pressure = newWeather.altimeterSetting
            }
            
            if let _ = newWeather.elev {
                weather.elevation = round(newWeather.elevation!)
            }
            if let speed = newWeather.windSpeed {
                weather.windSpeed = (speed as NSString).doubleValue
            } else {
                weather.windSpeed = 0
            }
            if let direction = newWeather.windDirection {
                weather.windDirection = (direction as NSString).doubleValue
            } else {
                weather.windDirection = 0
            }
        }

    }
    
    func resetAirfieldValues() {
        weather.temp = 0
        weather.pressure = 0
        weather.elevation = 0
        weather.windSpeed = 0
        weather.windDirection = 0
        weather.runwayDirection = 0
        weather.runwayLength = 0
    }
}
