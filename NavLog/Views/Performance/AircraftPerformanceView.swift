//
//  AircraftPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import SwiftUI
import Combine

struct AircraftPerformanceView: View {
    @State private var shouldShowAlert: Bool = false
    @State var viewModel = AircraftPerformanceViewModel()
    @State var missionPerformance = PerformanceResults()
    @State var temperatureInDegreesC: Bool = false
    @State var buttonText: String = "Change to C"
    @StateObject private var complexParser = ComplexMetarParser()
    @StateObject private var airportParser = AirportParser()
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
                    TextEntryFieldStringView(captionText: "Airport", textWidth: textWidth, promptText: "Airport", textValue: $viewModel.environment.airportCode)
                    TextEntryFieldView(formatter: formatter, captionText: "Elevation", textWidth: textWidth, promptText: "Elevation", textValue: $viewModel.environment.elevation)
                    TextEntryFieldView(formatter: formatter, captionText: "Runway Length", textWidth: textWidth, promptText: "Runway", textValue: $viewModel.environment.runwayLength)
                    TextEntryFieldView(formatter: formatter, captionText: "Runway Direction", textWidth: textWidth, promptText: "Direction", textValue: $viewModel.environment.runwayDirection)
                }
                
                Section(header: Text("Weather")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pressure", textWidth: textWidth, promptText: "Pressure", textValue: $viewModel.environment.pressure)
                    if temperatureInDegreesC {
                        TextEntryFieldView(formatter: formatter, captionText: "Temperature - C", textWidth: textWidth, promptText: "Temperature", textValue: $viewModel.environment.temp)
                    } else {
                        TextEntryFieldView(formatter: formatter, captionText: "Temperature - F", textWidth: textWidth, promptText: "Temperature", textValue: $viewModel.environment.temp)
                    }
                    Button(buttonText) {
                        temperatureInDegreesC = !temperatureInDegreesC
                        if temperatureInDegreesC {
                            // Convert to celsius
                            viewModel.environment.temp = StandardTempCalculator.convertFtoC(viewModel.environment.temp)
                            buttonText = "Change to F"
                        } else {
                            // Convert to farenheit
                            buttonText = "Change to C"
                            viewModel.environment.temp = StandardTempCalculator.convertCtoF(viewModel.environment.temp)
                        }
                        viewModel.environment.inCelsiusMode = temperatureInDegreesC
                    }
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Direction", textWidth: textWidth, promptText: "Wind Direction", textValue: $viewModel.environment.windDirection)
                    TextEntryFieldView(formatter: formatter, captionText: "Wind Speed", textWidth: textWidth, promptText: "Wind Speed", textValue: $viewModel.environment.windSpeed)
                }
                
                Section(header: Text("Mission Load")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pilot", textWidth: textWidth, promptText: "Pilot", textValue: $viewModel.mission.pilotSeat)
                    TextEntryFieldView(formatter: formatter, captionText: "Co-Pilot", textWidth: textWidth, promptText: "Co-Pilot", textValue: $viewModel.mission.copilotSeat)
                    
                    // We need a way to let the user know if they put more fuel than the tank can hold...
                    TextEntryFieldView(formatter: formatter, captionText: "Fuel in Gallons", textWidth: textWidth, promptText: "Fuel Wings", testValue: 48.0, textValue: $viewModel.mission.fuel)
                        
                    // If there are more than four seats, we show the middle seats
                    if viewModel.momentModel.seatCount > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: "Middle Seat", textWidth: textWidth, promptText: "Middle Seat", textValue: $viewModel.mission.middleSeat)
                    }
                    // If there are more than two seats, we show the back seat
                    if viewModel.momentModel.seatCount > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat", textWidth: textWidth, promptText: "Back Seat", textValue: $viewModel.mission.backSeat)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo", textWidth: textWidth, promptText: "Cargo", textValue: $viewModel.mission.cargo)
                }
                
                Section("Results", content: {
                    TakeOffPerformanceView(performance: missionPerformance, environment: viewModel.environment)
                        .onAppear(perform: {
                            temperatureInDegreesC = viewModel.environment.inCelsiusMode
                        })
                })
            })
            .toolbar(content: {
                HStack {
                    Button {
                        guard viewModel.environment.airportCode.count > 2
                        else { return }
                        // Load the results into the view controls
                        Task {
                            _ = try! await complexParser.fetchWeatherData(for: [viewModel.environment.airportCode])
                            theWeather = complexParser.weather.first
                            
                            _ = try! await airportParser.fetchAirportData(for: viewModel.environment.airportCode)
                            let runways = airportParser.runways
                            if runways.count > 1 {
                                let bestAlignment = RunwayChooser.chooseFrom(the: runways, wind: viewModel.environment.windDirection)
                                
                                viewModel.environment.runwayDirection = bestAlignment.1
                                viewModel.environment.runwayLength = Double(bestAlignment.0.runwayLength)
                                
                            } else if runways.count == 1 {
                                let theRunway = runways.first!
                                viewModel.environment.runwayLength = Double(theRunway.runwayLength)
                                let axis = theRunway.getRunwayAxis()
                                viewModel.environment.runwayDirection = RunwayChooser.chooseTheRunway(axis.0, axis.1, wind: viewModel.environment.windDirection)
                            } else {
                                print("There's nothing to choose")
                            }
                        }
                    } label: {
                        Text("Update WX")
                    }
                    Spacer()
                    Button {
                        guard validateForm() else { return }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.environment.save()
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
    
    private func validateForm() -> Bool {
        var retValue: Bool = (viewModel.mission.fuel <= viewModel.momentModel.maxFuelGallons)
        shouldShowAlert = !retValue
        return retValue
    }
    
    private func setAirfieldValues(_ weather: AirportWeather) {
        viewModel.environment.airportCode = weather.icaoId
        if let aTemp = weather.temp {
            temperatureInDegreesC = true
            viewModel.environment.temp = aTemp
        }
        if let _ = weather.altim {
            viewModel.environment.pressure = weather.altimeterSetting
        }
        
        if let _ = weather.elev {
            viewModel.environment.elevation = round(weather.elevation!)
        }
        if let speed = weather.windSpeed {
            viewModel.environment.windSpeed = (speed as NSString).doubleValue
        } else {
            viewModel.environment.windSpeed = 0
        }
        if let direction = weather.windDirection {
            viewModel.environment.windDirection = (direction as NSString).doubleValue
        } else {
            viewModel.environment.windDirection = 0
        }
    }
    
    private func resetAirfieldValues() {
        viewModel.environment.temp = 0
        viewModel.environment.pressure = 0
        viewModel.environment.elevation = 0
        viewModel.environment.windSpeed = 0
        viewModel.environment.windDirection = 0
        viewModel.environment.runwayDirection = 0
        viewModel.environment.runwayLength = 0
    }
}

#Preview {
    AircraftPerformanceView()
}
