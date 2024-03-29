//
//  AircraftPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import SwiftUI
import Combine
import CoreLocation

struct AircraftPerformanceView: View {
    @State private var shouldShowAlert: Bool = false
    @State private var missionPerformance = PerformanceResults()
    @State private var temperatureInDegreesC: Bool = true
    @State private var currentLocation: CLLocation?
    @State private var nearbyAirports: [AirportData] = [AirportData]()
    @Bindable private var aircraftManager = Core.services.acManager
    @StateObject private var viewModel = AircraftPerformanceViewModel()
    @State private var theWeather: AirportWeather? {
        didSet {
            guard let weather = theWeather else {
                resetAirfieldValues()
                return }
            setAirfieldValues(weather)
        }
    }
    
    private let textWidth: CGFloat = 170.0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        NavigationView( content: {
            Form( content: {
                
                Section(header: Text("Airport")) {
                    Button {
                        hideKeyboard()
                        findAirportData()
                        
                    } label: {
                        Text("1. Get Airport and Weather")
                    }
                    
                    if nearbyAirports.count > 0 {
                        Picker("Nearby Airports", selection: $viewModel.airportParser.chosenAirport) {
                            ForEach(viewModel.airportParser.airports.sorted(by: { a1, a2 in
                                a1.name! < a2.name!
                            }), id: \.self) {
                                Text($0.name!).tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldStringView(captionText: "Airport", textWidth: textWidth, promptText: "Airport", textValue: $viewModel.weather.airportCode)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Elevation: (" + viewModel.metrics.altitudeMode.text + ")", textWidth: textWidth, promptText: "Elevation", textValue: $viewModel.weather.elevation)
                }
                
                Section(header: Text("Weather")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pressure", textWidth: textWidth, promptText: "Pressure", integerOnly: false, textValue: $viewModel.weather.pressure)
                    TextEntryFieldView(formatter: formatter, captionText: "Temperature - C", textWidth: textWidth, promptText: "Temperature", integerOnly: false, textValue: $viewModel.weather.temp)
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Direction", textWidth: textWidth, promptText: "Wind Direction", textValue: $viewModel.weather.windDirection)
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Speed: " + viewModel.metrics.speedMode.modeSymbol, textWidth: textWidth, promptText: "Wind Speed", textValue: $viewModel.weather.windSpeed)
                }
                
                Section(header: Text("Mission Load")) {
                    
                    Picker("2. Choose Aircraft", selection: $aircraftManager.chosenAircraft) {
                        ForEach(aircraftManager.availableAircraft.sorted(by: { r1, r2 in
                            r1.aircraft < r2.aircraft
                        }), id: \.self) {
                            Text("\($0.aircraft)").tag($0)
                        }
                    }
                    .tint(Color.accentColor)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Pilot", textWidth: textWidth, promptText: "Pilot", textValue: $viewModel.mission.pilotSeat)
                    TextEntryFieldView(formatter: formatter, captionText: "Co-Pilot", textWidth: textWidth, promptText: "Co-Pilot", textValue: $viewModel.mission.copilotSeat)
                    
                    // If there are more than four seats, we show the middle seats
                    if aircraftManager.chosenAircraft.seatCount > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: "Middle Seat", textWidth: textWidth, promptText: "Middle Seat", testValue: aircraftManager.chosenAircraft.maxMiddleWeight, textValue: $viewModel.mission.middleSeat)
                    }
                    // If there are more than two seats, we show the back seat
                    if aircraftManager.chosenAircraft.seatCount > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat", textWidth: textWidth, promptText: "Back Seat", testValue: aircraftManager.chosenAircraft.maxBackWeight, textValue: $viewModel.mission.backSeat)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo", textWidth: textWidth, promptText: "Cargo", testValue: aircraftManager.chosenAircraft.maxCargoWeight, textValue: $viewModel.mission.cargo)
                    
                    // We need a way to let the user know if they put more fuel than the tank can hold...
                    TextEntryFieldView(formatter: formatter, captionText: "Fuel in \(viewModel.metrics.fuelMode.text.capitalized)", textWidth: textWidth, promptText: "Fuel Wings", testValue: aircraftManager.chosenAircraft.maxFuelGallons, textValue: $viewModel.mission.fuel)
                    
                    if aircraftManager.chosenAircraft.auxMaxFuelGallons > 0 {
                        TextEntryFieldView(formatter: formatter, captionText: "Aux Fuel in Gallons", textWidth: textWidth, promptText: "Aux Fuel Tanks", testValue: aircraftManager.chosenAircraft.auxMaxFuelGallons, textValue: $viewModel.mission.auxFuel)
                    }
                }
                
                Section("Planning", content: {
                    Button {
                        hideKeyboard()
                        guard validateForm() else { return }
                        calculatePerformance()
                        
                    } label: { Text("3. Calculate Performance") }
                    
                    if viewModel.runwayChooser.runwayDirections.count > 0 {
                        Picker("Runway Direction", selection: $viewModel.runwayChooser.selectedRunway) {
                            ForEach(Array(viewModel.airportParser.runways.sorted(by: { r1, r2 in
                                r1.direction! < r2.direction!
                            })), id: \.self) {
                                Text("\(Int($0.direction!)) - \($0.dimension)").tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldView(formatter: formatter, captionText: "Runway Length", textWidth: textWidth, promptText: "Runway", textValue: $viewModel.weather.runwayLength)
                        TextEntryFieldView(formatter: formatter, captionText: "Runway Direction", textWidth: textWidth, promptText: "Direction", textValue: $viewModel.weather.runwayDirection)
                    }
                })
                
                Section("Results", content: {
                    TakeOffPerformanceView(performance: missionPerformance, environment: viewModel.weather)
                        .onAppear(perform: {
                            temperatureInDegreesC = viewModel.weather.inCelsiusMode
                        })
                })
            })
            .alert(isPresented: $shouldShowAlert) {
                // Put alert here
                Alert(title: Text("You can't load more than \(Int(aircraftManager.chosenAircraft.maxFuelGallons)) gallons."))
            }
            .navigationTitle("Weight & Balance")
            .onAppear(perform:{
                viewModel.weather.inCelsiusMode = temperatureInDegreesC
            })
        })
    }
    
    private func findAirportData() {
        if let chosenName = viewModel.airportParser.chosenAirport.name,
           chosenName.count > 2,
           chosenName != viewModel.weather.airportCode {
            viewModel.weather.airportCode = chosenName
        }
        
        guard (viewModel.weather.airportCode.count > 2 || viewModel.airportParser.chosenAirport.name!.count > 1),
              self.currentLocation == nil
        else {
            //  Here we could look for airports around us...
            if let _ = currentLocation {
                getLocalAirports()
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
                    currentLocation = Core.services.gpsEngine.currentLocation
                    Core.services.gpsEngine.stopTrackingLocation()
                    getLocalAirports()
                })
            }
            return
        }
        // Load the results into the view controls
        Task {
            _ = try! await viewModel.complexParser.fetchWeatherData(for: [viewModel.weather.airportCode])
            theWeather = viewModel.complexParser.weather.first
            
            _ = try! await viewModel.airportParser.fetchAirportData(for: viewModel.weather.airportCode)
            let runways = viewModel.airportParser.runways
            if runways.count > 1 {
                let bestAlignment = viewModel.runwayChooser.chooseFrom(the: runways, wind: viewModel.weather.windDirection)
                if let direction = bestAlignment.1,
                   let aRunway = bestAlignment.0 {
                    viewModel.weather.runwayDirection = direction
                    viewModel.weather.runwayLength = Double(aRunway.runwayLength)
                    viewModel.runwayChooser.selectedRunway = aRunway
                }
            }
            viewModel.weather.save()
        }
    }
    
    private func calculatePerformance() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if viewModel.runwayChooser.selectedRunway.id != "" {
            viewModel.weather.runwayDirection = Double(viewModel.runwayChooser.selectedRunway.direction ?? 0)
            viewModel.weather.runwayLength = Double(viewModel.runwayChooser.selectedRunway.runwayLength)
        }
        viewModel.weather.save()
        // I want all this done in the missionPerformance object, but it works for now.
        missionPerformance.cgIsInLimits = viewModel.computeCGLimits(using: aircraftManager.chosenAircraft)
        missionPerformance.isUnderGross = viewModel.isInWeightLimits(using: aircraftManager.chosenAircraft)
        missionPerformance.overWeightAmount = (viewModel.computeTotalWeight(with: aircraftManager.chosenAircraft) - aircraftManager.chosenAircraft.maxWeight)
        
        let runwayCalculations = viewModel.calculateRequiredRunwayLength(tempIsFarenheit: !temperatureInDegreesC, using: aircraftManager.chosenAircraft)
        missionPerformance.computedTakeOffRoll = runwayCalculations.0
        missionPerformance.computedOver50Roll = runwayCalculations.1
        
        let landingCalculations = viewModel.calculateRequiredLandingLength()
        missionPerformance.computedLandingRoll = landingCalculations.0
        missionPerformance.computedLandingOver50Roll = landingCalculations.1
        viewModel.mission.save()
    }
    
    private func getLocalAirports() {
        guard let aLocation = Core.services.gpsEngine.currentLocation else { return }
        Task {
            _ = try! await viewModel.airportParser.fetchNearbyAirports(for: aLocation, closeIn: true)
            if viewModel.airportParser.airports.count > 0,
               viewModel.airportParser.airports.count < 2 {
                viewModel.weather.airportCode = viewModel.airportParser.airports.first!.name ?? "No name"
                currentLocation = nil
                findAirportData()
            } else if viewModel.airportParser.airports.count > 1 {
                nearbyAirports = viewModel.airportParser.airports
                viewModel.weather.airportCode = viewModel.airportParser.airports.first!.name ?? "No name"
                currentLocation = nil
                findAirportData()
            }
        }
    }
    
    private func validateForm() -> Bool {
        let retValue: Bool = (viewModel.mission.fuel <= aircraftManager.chosenAircraft.maxFuelGallons)
        shouldShowAlert = !retValue
        return retValue
    }
    
    private func setAirfieldValues(_ weather: AirportWeather) {
        viewModel.weather.airportCode = weather.icaoId
        if let aTemp = weather.temp {
            temperatureInDegreesC = true
            viewModel.weather.temp = aTemp
        }
        if let _ = weather.altim {
            viewModel.weather.pressure = weather.altimeterSetting
        }
        
        if let _ = weather.elev {
            viewModel.weather.elevation = round(weather.elevation!)
        }
        if let speed = weather.windSpeed {
            viewModel.weather.windSpeed = (speed as NSString).doubleValue
        } else {
            viewModel.weather.windSpeed = 0
        }
        if let direction = weather.windDirection {
            viewModel.weather.windDirection = (direction as NSString).doubleValue
        } else {
            viewModel.weather.windDirection = 0
        }
    }
    
    private func resetAirfieldValues() {
        viewModel.weather.temp = 0
        viewModel.weather.pressure = 0
        viewModel.weather.elevation = 0
        viewModel.weather.windSpeed = 0
        viewModel.weather.windDirection = 0
        viewModel.weather.runwayDirection = 0
        viewModel.weather.runwayLength = 0
    }
}

#Preview {
    AircraftPerformanceView()
}
