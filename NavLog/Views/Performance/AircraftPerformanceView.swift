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
    @State private var temperatureInDegreesC: Bool = true
    @StateObject private var viewModel = AircraftPerformanceViewModel()
    
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
                        viewModel.findAirportData()
                        
                    } label: {
                        Text("1. Get Airport and Weather")
                    }
                    
                    if viewModel.nearbyAirports.count > 0 {
                        Picker("Nearby Airports", selection: $viewModel.weather.airportCode) {
                            ForEach(viewModel.airportParser.airports.sorted(by: { a1, a2 in
                                a1.faaId < a2.faaId
                            }), id: \.self) {
                                Text($0.icaoId ?? $0.faaId).tag($0)
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
                    
                    Picker("2. Choose Aircraft", selection: $viewModel.aircraftManager.chosenAircraft) {
                        ForEach(viewModel.aircraftManager.availableAircraft.sorted(by: { r1, r2 in
                            r1.aircraft < r2.aircraft
                        }), id: \.self) {
                            Text("\($0.aircraft)").tag($0)
                        }
                    }
                    .tint(Color.accentColor)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Pilot", textWidth: textWidth, promptText: "Pilot", textValue: $viewModel.mission.pilotSeat)
                    TextEntryFieldView(formatter: formatter, captionText: "Co-Pilot", textWidth: textWidth, promptText: "Co-Pilot", textValue: $viewModel.mission.copilotSeat)
                    
                    // If there are more than four seats, we show the middle seats
                    if viewModel.aircraftManager.chosenAircraft.seatCount > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: "Middle Seat", textWidth: textWidth, promptText: "Middle Seat", testValue: viewModel.aircraftManager.chosenAircraft.maxMiddleWeight, textValue: $viewModel.mission.middleSeat)
                    }
                    // If there are more than two seats, we show the back seat
                    if viewModel.aircraftManager.chosenAircraft.seatCount > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat", textWidth: textWidth, promptText: "Back Seat", testValue: viewModel.aircraftManager.chosenAircraft.maxBackWeight, textValue: $viewModel.mission.backSeat)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo", textWidth: textWidth, promptText: "Cargo", testValue: viewModel.aircraftManager.chosenAircraft.maxCargoWeight, textValue: $viewModel.mission.cargo)
                    
                    // We need a way to let the user know if they put more fuel than the tank can hold...
                    TextEntryFieldView(formatter: formatter, captionText: "Fuel in \(viewModel.metrics.fuelMode.text.capitalized)", textWidth: textWidth, promptText: "Fuel Wings", testValue: viewModel.aircraftManager.chosenAircraft.maxFuelGallons, textValue: $viewModel.mission.fuel)
                    
                    if viewModel.aircraftManager.chosenAircraft.auxMaxFuelGallons > 0 {
                        TextEntryFieldView(formatter: formatter, captionText: "Aux Fuel in Gallons", textWidth: textWidth, promptText: "Aux Fuel Tanks", testValue: viewModel.aircraftManager.chosenAircraft.auxMaxFuelGallons, textValue: $viewModel.mission.auxFuel)
                    }
                }
                
                Section("Planning", content: {
                    Button {
                        hideKeyboard()
                        guard validateForm() else { return }
                        viewModel.calculatePerformance(temperatureInDegreesC: temperatureInDegreesC)
                        
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
                    TakeOffPerformanceView(performance: viewModel.missionPerformance, environment: viewModel.weather)
                        .onAppear(perform: {
                            temperatureInDegreesC = viewModel.weather.inCelsiusMode
                        })
                })
            })
            .alert(isPresented: $shouldShowAlert) {
                // Put alert here
                Alert(title: Text("You can't load more than \(Int(viewModel.aircraftManager.chosenAircraft.maxFuelGallons)) gallons."))
            }
            .navigationTitle("Weight & Balance")
            .onAppear(perform:{
                viewModel.weather.inCelsiusMode = temperatureInDegreesC
            })
        })
    }
    
    private func validateForm() -> Bool {
        let retValue: Bool = (viewModel.mission.fuel <= viewModel.aircraftManager.chosenAircraft.maxFuelGallons)
        shouldShowAlert = !retValue
        return retValue
    }
}

#Preview {
    AircraftPerformanceView()
}
