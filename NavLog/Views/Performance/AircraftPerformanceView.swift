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
    typealias sections = PerformanceConstants.Sections
    typealias steps = PerformanceConstants.Steps
    typealias strings = PerformanceConstants.String
    @State private var shouldShowAlert: Bool = false
    @State private var temperatureInDegreesC: Bool = true
    @StateObject private var viewModel: AircraftPerformanceViewModel
    
    private let textWidth: CGFloat = 170.0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    init(viewModel: AircraftPerformanceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView( content: {
            Form( content: {
                
                Section(header: Text(sections.titleAirport)) {
                    Button {
                        hideKeyboard()
                        viewModel.findAirportData()
                        
                    } label: {
                        Text(steps.one)
                    }
                    
                    if viewModel.nearbyAirports.count > 0 {
                        Picker(strings.nearbyAirports, selection: $viewModel.weather.airportCode) {
                            ForEach(viewModel.airportParser.airports.sorted(by: { a1, a2 in
                                a1.faaId < a2.faaId
                            }), id: \.self) {
                                Text($0.icaoId ?? $0.faaId).tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldStringView(captionText: strings.airport, textWidth: textWidth, promptText: strings.airport, textValue: $viewModel.weather.airportCode)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: viewModel.elevationCaption(), textWidth: textWidth, promptText: strings.elevation, textValue: $viewModel.weather.elevation)
                }
                
                Section(header: Text(sections.titleWeather)) {
                    TextEntryFieldView(formatter: formatter, captionText: strings.pressure, textWidth: textWidth, promptText: strings.pressure, integerOnly: false, textValue: $viewModel.weather.pressure)
                    TextEntryFieldView(formatter: formatter, captionText: strings.tempCelsius, textWidth: textWidth, promptText: strings.temperature, integerOnly: false, textValue: $viewModel.weather.temp)
                    TextEntryFieldView(formatter: formatter, captionText: strings.windDirection, textWidth: textWidth, promptText: strings.windDirection, textValue: $viewModel.weather.windDirection)
                    TextEntryFieldView(formatter: formatter, captionText: viewModel.windSpeedCaption(), textWidth: textWidth, promptText: strings.windSpeed, textValue: $viewModel.weather.windSpeed)
                }
                
                Section(header: Text(sections.titleMissionLoad)) {
                    
                    Picker(steps.two, selection: $viewModel.aircraftManager.chosenAircraft) {
                        ForEach(viewModel.aircraftManager.availableAircraft.sorted(by: { r1, r2 in
                            r1.aircraft < r2.aircraft
                        }), id: \.self) {
                            Text("\($0.aircraft)").tag($0)
                        }
                    }
                    .tint(Color.accentColor)
                    
                    TextEntryFieldView(formatter: formatter, captionText: strings.pilot, textWidth: textWidth, promptText: strings.pilot, textValue: $viewModel.mission.pilotSeat)
                    TextEntryFieldView(formatter: formatter, captionText: strings.coPilot, textWidth: textWidth, promptText: strings.coPilot, textValue: $viewModel.mission.copilotSeat)
                    
                    // If there are more than four seats, we show the middle seats
                    if viewModel.aircraftManager.chosenAircraft.seatCount > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: strings.middleSeat, textWidth: textWidth, promptText: strings.middleSeat, testValue: viewModel.aircraftManager.chosenAircraft.maxMiddleWeight, textValue: $viewModel.mission.middleSeat)
                    }
                    // If there are more than two seats, we show the back seat
                    if viewModel.aircraftManager.chosenAircraft.seatCount > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: strings.backSeat, textWidth: textWidth, promptText: strings.backSeat, testValue: viewModel.aircraftManager.chosenAircraft.maxBackWeight, textValue: $viewModel.mission.backSeat)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: strings.cargo, textWidth: textWidth, promptText: strings.cargo, testValue: viewModel.aircraftManager.chosenAircraft.maxCargoWeight, textValue: $viewModel.mission.cargo)
                    
                    // We need a way to let the user know if they put more fuel than the tank can hold...
                    TextEntryFieldView(formatter: formatter, captionText: viewModel.fuelOnboardCaption(), textWidth: textWidth, promptText: strings.fuelWings, testValue: viewModel.aircraftManager.chosenAircraft.maxFuelGallons, textValue: $viewModel.mission.fuel)
                    
                    if viewModel.aircraftManager.chosenAircraft.auxMaxFuelGallons > 0 {
                        TextEntryFieldView(formatter: formatter, captionText: strings.auxFuelGallons, textWidth: textWidth, promptText: strings.auxFuelTank, testValue: viewModel.aircraftManager.chosenAircraft.auxMaxFuelGallons, textValue: $viewModel.mission.auxFuel)
                    }
                }
                
                Section(sections.titlePlanning, content: {
                    Button {
                        hideKeyboard()
                        guard validateForm() else { return }
                        viewModel.calculatePerformance(temperatureInDegreesC: temperatureInDegreesC)
                        
                    } label: { Text(steps.three) }
                    
                    if viewModel.runwayChooser.runwayDirections.count > 0 {
                        Picker(strings.runwayDirection, selection: $viewModel.runwayChooser.selectedRunway) {
                            ForEach(Array(viewModel.airportParser.runways.sorted(by: { r1, r2 in
                                r1.direction! < r2.direction!
                            })), id: \.self) {
                                Text("\(Int($0.direction!)) - \($0.dimension)").tag($0)
                            }
                        }
                    } else {
                        TextEntryFieldView(formatter: formatter, captionText: strings.runwayLength, textWidth: textWidth, promptText: strings.runway, textValue: $viewModel.weather.runwayLength)
                        TextEntryFieldView(formatter: formatter, captionText: strings.runwayDirection, textWidth: textWidth, promptText: strings.direction, textValue: $viewModel.weather.runwayDirection)
                    }
                })
                
                Section(sections.titleResults, content: {
                    TakeOffPerformanceView(performance: viewModel.missionPerformance, environment: viewModel.weather)
                        .onAppear(perform: {
                            temperatureInDegreesC = viewModel.weather.inCelsiusMode
                        })
                })
            })
            .alert(isPresented: $shouldShowAlert) {
                // Put alert here
                Alert(title: Text(viewModel.fuelCapacityWarning()))
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(strings.navigationTitle).font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
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
    AircraftPerformanceView(viewModel: AircraftPerformanceViewModel())
}
