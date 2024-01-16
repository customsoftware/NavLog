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
    @State private var temperatureInDegreesC: Bool = false
    @State private var buttonText: String = "Change to C"
    @State private var selectedRunway: Runway = Runway(id: "", dimension: "", surface: "", alignment: "", direction: 0)
    @State private var currentLocation: CLLocation?
    @State private var nearbyAirports: [AirportData] = [AirportData]()
    @State private var chosenAirport: AirportData = AirportData(name: "", iata: "", runways: [])
    @StateObject private var viewModel = AircraftPerformanceViewModel()
    @StateObject private var complexParser = ComplexMetarParser()
    @StateObject private var airportParser = AirportParser()
    @StateObject private var runwayChooser = RunwayChooser()
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
                    if nearbyAirports.count > 0 {
                        Picker("Nearby Airports", selection: $chosenAirport) {
                            ForEach(airportParser.airports.sorted(by: { a1, a2 in
                                a1.name! < a2.name!
                            }), id: \.self) {
                                Text($0.name!).tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldStringView(captionText: "Airport", textWidth: textWidth, promptText: "Airport", textValue: $viewModel.weather.airportCode)
                    }
                    TextEntryFieldView(formatter: formatter, captionText: "Elevation", textWidth: textWidth, promptText: "Elevation", textValue: $viewModel.weather.elevation)
                    
                    if runwayChooser.runwayDirections.count > 0 {
                        Picker("Runway Direction", selection: $selectedRunway) {
                            ForEach(Array(airportParser.runways.sorted(by: { r1, r2 in
                                r1.direction! < r2.direction!
                            })), id: \.self) {
                                Text("\(Int($0.direction!)) - \($0.dimension)").tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldView(formatter: formatter, captionText: "Runway Length", textWidth: textWidth, promptText: "Runway", textValue: $viewModel.weather.runwayLength)
                        TextEntryFieldView(formatter: formatter, captionText: "Runway Direction", textWidth: textWidth, promptText: "Direction", textValue: $viewModel.weather.runwayDirection)
                    }
                }
                
                Section(header: Text("Weather")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pressure", textWidth: textWidth, promptText: "Pressure", integerOnly: false, textValue: $viewModel.weather.pressure)
                    if temperatureInDegreesC {
                        TextEntryFieldView(formatter: formatter, captionText: "Temperature - C", textWidth: textWidth, promptText: "Temperature", integerOnly: false, textValue: $viewModel.weather.temp)
                    } else {
                        TextEntryFieldView(formatter: formatter, captionText: "Temperature - F", textWidth: textWidth, promptText: "Temperature", textValue: $viewModel.weather.temp)
                    }
                    Button(buttonText) {
                        temperatureInDegreesC = !temperatureInDegreesC
                        if temperatureInDegreesC {
                            // Convert to celsius
                            viewModel.weather.temp = StandardTempCalculator.convertFtoC(viewModel.weather.temp)
                            buttonText = "Change to F"
                        } else {
                            // Convert to farenheit
                            buttonText = "Change to C"
                            viewModel.weather.temp = StandardTempCalculator.convertCtoF(viewModel.weather.temp)
                        }
                        viewModel.weather.inCelsiusMode = temperatureInDegreesC
                    }
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Direction", textWidth: textWidth, promptText: "Wind Direction", textValue: $viewModel.weather.windDirection)
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Speed", textWidth: textWidth, promptText: "Wind Speed", textValue: $viewModel.weather.windSpeed)
                }
                
                Section(header: Text("Mission Load")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pilot", textWidth: textWidth, promptText: "Pilot", textValue: $viewModel.mission.pilotSeat)
                    TextEntryFieldView(formatter: formatter, captionText: "Co-Pilot", textWidth: textWidth, promptText: "Co-Pilot", textValue: $viewModel.mission.copilotSeat)
                    
                    // We need a way to let the user know if they put more fuel than the tank can hold...
                    TextEntryFieldView(formatter: formatter, captionText: "Fuel in Gallons", textWidth: textWidth, promptText: "Fuel Wings", testValue: viewModel.momentModel.maxFuelGallons, textValue: $viewModel.mission.fuel)
                        
                    // If there are more than four seats, we show the middle seats
                    if viewModel.momentModel.seatCount > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: "Middle Seat", textWidth: textWidth, promptText: "Middle Seat", testValue: viewModel.momentModel.maxMiddleWeight, textValue: $viewModel.mission.middleSeat)
                    }
                    // If there are more than two seats, we show the back seat
                    if viewModel.momentModel.seatCount > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat", textWidth: textWidth, promptText: "Back Seat", testValue: viewModel.momentModel.maxBackWeight, textValue: $viewModel.mission.backSeat)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo", textWidth: textWidth, promptText: "Cargo", testValue: viewModel.momentModel.maxCargoWeight, textValue: $viewModel.mission.cargo)
                }
                
                Section("Results", content: {
                    TakeOffPerformanceView(performance: missionPerformance, environment: viewModel.weather)
                        .onAppear(perform: {
                            temperatureInDegreesC = viewModel.weather.inCelsiusMode
                        })
                })
            })
            .toolbar(content: {
                HStack {
                    Button {
                        hideKeyboard()
                        findAirportData()
                        
                    } label: {
                        Text("Update WX")
                    }
                    Spacer()
                    Button {
                        hideKeyboard()
                        guard validateForm() else { return }
                        calculatePerformance()
                        
                    } label: { Text("Calculate") }
                }
            })
            .alert(isPresented: $shouldShowAlert) {
                // Put alert here
                Alert(title: Text("You can't load more than \(Int(viewModel.momentData.maxFuelGallons)) gallons."))
                
            }
            .navigationTitle("Weight & Balance")
        })
    }
    
    private func findAirportData() {
        if let chosenName = chosenAirport.name,
           chosenName.count > 2,
           chosenName != viewModel.weather.airportCode {
            viewModel.weather.airportCode = chosenName
        }
        
        print("The airport: \(viewModel.weather.airportCode)")
        print("\(chosenAirport.name ?? "None selected")")
        print("\(currentLocation != nil ? "There is a location" : "No location set")")
        guard (viewModel.weather.airportCode.count > 2 || chosenAirport.name!.count > 1),
              self.currentLocation == nil
        else {
        //  Here we could look for airports around us...
            if let aLocation = currentLocation {
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
               _ = try! await complexParser.fetchWeatherData(for: [viewModel.weather.airportCode])
            theWeather = complexParser.weather.first
            
            _ = try! await airportParser.fetchAirportData(for: viewModel.weather.airportCode)
            let runways = airportParser.runways
            if runways.count > 1 {
                let bestAlignment = runwayChooser.chooseFrom(the: runways, wind: viewModel.weather.windDirection)
                if let direction = bestAlignment.1,
                   let aRunway = bestAlignment.0 {
                    viewModel.weather.runwayDirection = direction
                    viewModel.weather.runwayLength = Double(aRunway.runwayLength)
                    selectedRunway = aRunway
                }
            } else {
                print("There's nothing to choose")
            }
            viewModel.weather.save()
        }
    }
    
    private func calculatePerformance() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if selectedRunway.id != "" {
            viewModel.weather.runwayDirection = Double(selectedRunway.direction ?? 0)
            viewModel.weather.runwayLength = Double(selectedRunway.runwayLength)
        }
        viewModel.weather.save()
        // I want all this done in the missionPerformance object, but it works for now.
        missionPerformance.cgIsInLimits = viewModel.computeCGLimits()
        missionPerformance.isUnderGross = viewModel.isInWeightLimits()
        missionPerformance.overWeightAmount = (viewModel.computeTotalWeight() - viewModel.momentModel.maxWeight)
        
        let runwayCalculations = viewModel.calculateRequiredRunwayLength(tempIsFarenheit: !temperatureInDegreesC)
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
            _ = try! await airportParser.fetchNearbyAirports(for: aLocation, closeIn: true)
            if airportParser.airports.count > 0,
               airportParser.airports.count < 2 {
                viewModel.weather.airportCode = airportParser.airports.first!.name ?? "No name"
                currentLocation = nil
                findAirportData()
            } else if airportParser.airports.count > 1 {
                nearbyAirports = airportParser.airports
                viewModel.weather.airportCode = airportParser.airports.first!.name ?? "No name"
                currentLocation = nil
                findAirportData()
            }
        }
    }
    
    private func validateForm() -> Bool {
        let retValue: Bool = (viewModel.mission.fuel <= viewModel.momentModel.maxFuelGallons)
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
