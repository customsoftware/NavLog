//
//  AircraftPerformanceSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/24/24.
//

import SwiftUI

struct AircraftPerformanceSwiftUIView: View {
    @StateObject private var vm: AircraftPerformance = AircraftPerformance.shared
    @State private var acNumber: String = ""
    private let width: CGFloat = 145
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    
    var body: some View {
        Form {
            TextEntryFieldStringView(captionText: "Registration", textWidth: width, promptText: "N-Number", isBold: true, textValue: $acNumber)
            
            Section("Fuel Burn", content: {
                TextEntryFieldView(formatter: formatter, captionText: "Climb Burn", textWidth: width, promptText: "Fuel burn while climbing", isBold: true, integerOnly: false, testValue: nil, textValue: $vm.aircraft.climbToAltitudeFuelBurnRate)
                TextEntryFieldView(formatter: formatter, captionText: "Cruise Burn", textWidth: width, promptText: "Fuel burn while cruising", isBold: true, integerOnly: false, testValue: nil, textValue: $vm.aircraft.cruiseFuelBurnRate)
                TextEntryFieldView(formatter: formatter, captionText: "Descending Burn", textWidth: width, promptText: "Fuel burn while descending", isBold: true, integerOnly: false, testValue: nil, textValue: $vm.aircraft.descendingFuelBurnRate)
            })
            Section("Performance", content: {
                TextEntryIntFieldView(formatter: formatter, captionText: "Rate of Climb", textWidth: width, promptText: "Standard climb rate", isBold: true, textValue: $vm.aircraft.standardClimbRate)
                TextEntryIntFieldView(formatter: formatter, captionText: "Rate of Descent", textWidth: width, promptText: "Standard descent rate", isBold: true, textValue: $vm.aircraft.standardDescentRate)
                
            })
            Section("Speeds", content: {
                TextEntryIntFieldView(formatter: formatter, captionText: "Stall Speed", textWidth: width, promptText: "VSo For aircraft", isBold: true, textValue: $vm.aircraft.stallSpeed)
                TextEntryIntFieldView(formatter: formatter, captionText: "Climb Speed", textWidth: width, promptText: "Climbing speed", isBold: true, textValue: $vm.aircraft.climbSpeed)
                TextEntryIntFieldView(formatter: formatter, captionText: "Cruise Speed", textWidth: width, promptText: "70% Power cruise", isBold: true, textValue: $vm.aircraft.cruiseSpeed)
                TextEntryIntFieldView(formatter: formatter, captionText: "Descent Speed", textWidth: width, promptText: "Descending speed", isBold: true, textValue: $vm.aircraft.descentSpeed)
            })
        }
        .onAppear(perform: {
            guard let acRegistration = UserDefaults.standard.string(forKey: AircraftPerformance.aircraftRegistrationArchiveKey),
                  acRegistration.count > 4 else {
                acNumber = vm.aircraft.registration
                return
            }
            acNumber = acRegistration
            vm.readAircraft(acRegistration)
        })
        .onDisappear(perform: {
            if acNumber.count > 4 {
                vm.saveAircraft(acNumber)
                UserDefaults.standard.setValue(acNumber, forKey: AircraftPerformance.aircraftRegistrationArchiveKey)
                UserDefaults.standard.synchronize()
            }
        })
        
        .toolbar(content: {
            Button("Retrieve") {
                if !acNumber.isEmpty {
                    vm.readAircraft(acNumber)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }          
            Button("Save") {
                if !acNumber.isEmpty {
                    vm.saveAircraft(acNumber)
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        })
    }
}

#Preview {
    AircraftPerformanceSwiftUIView()
}


class AircraftPerformance: ObservableObject {
    static let shared: AircraftPerformance = AircraftPerformance()
    static let aircraftRegistrationArchiveKey: String = "kSelectedAircraft"
    
    private let aircraftExtension: String = "acft"
    
    @Published var aircraft: Aircraft = AircraftPerformance.buildBlank()
    
    init() {
        if let acNumber = UserDefaults.standard.string(forKey: AircraftPerformance.aircraftRegistrationArchiveKey) {
           readAircraft(acNumber)
        }
    }
    
    
    @discardableResult
    func readAircraft(_ acRegistration: String) -> Aircraft? {
        var retValue: Aircraft?
        do {
            if let acData = try JSONArchiver().read(from: acRegistration, with: aircraftExtension) {
                retValue = try JSONDecoder().decode(Aircraft.self, from: acData)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        if let ac = retValue {
            aircraft = ac
        }
        
        return retValue
    }
    
    static private func buildBlank() -> Aircraft {
        let dummyAC = Aircraft(registration: "NCC-1701A", standardClimbRate: 0, standardDescentRate: 0, cruiseFuelBurnRate: 0.5, climbToAltitudeFuelBurnRate: 0.5, descendingFuelBurnRate: 0.5, stallSpeed: 10, climbSpeed: 11, cruiseSpeed: 11, descentSpeed: 11)
        return dummyAC
    }
    
    func saveAircraft(_ acRegistration: String) {
        do {
            aircraft.registration = acRegistration
            let acData = try JSONEncoder().encode(aircraft)
            try JSONArchiver().write(data: acData, to: acRegistration, with: aircraftExtension)
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
