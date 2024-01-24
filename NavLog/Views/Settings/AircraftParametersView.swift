//
//  AircraftParametersView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct AircraftParametersView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @Bindable var aircraftManager = Core.services.acManager
    @State private var acWhileInTransit: MomentDatum?
    @State private var showingAlert: Bool = false
    @State private var importing = false
    
    private let textWidth: CGFloat = 180.0
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
     
            Form {
                if aircraftManager.isAdding == false {
                    Picker("Choose Aircraft", selection: $aircraftManager.chosenAircraft) {
                        ForEach(aircraftManager.availableAircraft.sorted(by: { r1, r2 in
                            r1.aircraft < r2.aircraft
                        }), id: \.self) {
                            Text("\($0.aircraft)").tag($0)
                        }
                    }
                    .tint(Color.accentColor)
                }
                Section("Aircraft", content: {
                    TextEntryFieldStringView(captionText: "Model:", textWidth: textWidth - 30, promptText: "Enter Airplane type", isBold: false, textValue: $aircraftManager.chosenAircraft.aircraft)
                    
                    TextEntryFieldStringView(captionText: "Engine:", textWidth: textWidth - 30, promptText: "Enter engine type", isBold: false, textValue: $aircraftManager.chosenAircraft.aircraftEngine)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Seats:", textWidth: textWidth, promptText: "Enter Number of Seats", textValue: $aircraftManager.chosenAircraft.seatCount)
                })
                
                Section("AC Weights", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Maximum:", textWidth: textWidth, promptText: "Enter Max Weight", textValue: $aircraftManager.chosenAircraft.maxWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Empty", textWidth: textWidth, promptText: "Enter Empty Weight", textValue: $aircraftManager.chosenAircraft.emptyWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Aircraft Moment", textWidth: textWidth, promptText: "Aircraft Moment", integerOnly: false, textValue: $aircraftManager.chosenAircraft.aircraftArm)
                })
                
                Section("Fuel", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Gallons", textWidth: textWidth, promptText: "Enter Max Fuel Gallons", isBold: false, textValue: $aircraftManager.chosenAircraft.maxFuelGallons)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Arm", textWidth: textWidth, promptText: "Max Fuel Moment", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.fuelMoment)
                    
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Aux Fuel in Gallons", textWidth: textWidth, promptText: "Aux Fuel Tanks", isBold: false, textValue: $aircraftManager.chosenAircraft.auxMaxFuelGallons)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Aux Fuel Arm", textWidth: textWidth, promptText: "Aux Fuel Tanks", isBold: true, textValue: $aircraftManager.chosenAircraft.auxFuelMoment)
                })
                
                Section(header: Text("Cargo and Pax")) {
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Oil Weight", textWidth: textWidth, promptText: "Oil Weight", textValue: $aircraftManager.chosenAircraft.oilWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Oil Arm", textWidth: textWidth, promptText: "Oil Arm", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.oilMoment)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Front Seat Max Weight", textWidth: textWidth, promptText: "Front Seat Max Weight", textValue: $aircraftManager.chosenAircraft.maxFrontWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Front Seat Arm", textWidth: textWidth, promptText: "Front Seat Moment", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.frontMoment)
                    
                    // If more than four seats show the middle row
                    if (aircraftManager.chosenAircraft.seatCount) > 4 {
                        TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Max Weight", textWidth: textWidth, promptText: "Mid Seat Max Weight", textValue: $aircraftManager.chosenAircraft.maxMiddleWeight)
                        
                        TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Arm", textWidth: textWidth, promptText: "Mid Seat Moment", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.middleMoment)
                    }
                    
                    // If more than two seats show the back row
                    if (aircraftManager.chosenAircraft.seatCount) > 2 {
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat Max Weight", textWidth: textWidth, promptText: "Back Seat Max Weight", textValue: $aircraftManager.chosenAircraft.maxBackWeight)
                        
                        TextEntryFieldView(formatter: formatter, captionText: "Back Seat Arm", textWidth: textWidth, promptText: "Back Seat Moment", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.backMoment)
                    }
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo Max Weight", textWidth: textWidth, promptText: "Cargo Max Weight", textValue: $aircraftManager.chosenAircraft.maxCargoWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo Arm", textWidth: textWidth, promptText: "Cargo Moment", isBold: true, integerOnly: false, textValue: $aircraftManager.chosenAircraft.cargoMoment)
                }
            }
            .toolbar(content: {
                HStack {
                    Spacer()
                    if aircraftManager.isAdding == false {
                        Button {
                            // This creates a new empty plane for the user to "build"
                            showingAlert = true
                            
                        } label: { Text("New") }
                    } else {
                        Button {
                            // This creates a new empty plane for the user to "build"
                            aircraftManager.isAdding = false
                            guard let anAC = acWhileInTransit else { return }
                            aircraftManager.chosenAircraft = anAC
                            
                        } label: { Text("Cancel") }
                    }
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if aircraftManager.chosenAircraft.isValid() {
                            aircraftManager.saveCurrentAircraft()
                            if aircraftManager.isAdding == false {
                                dismiss()
                            }
                        } else {
                            print("Why for not???")
                        }
                    } label: { Text("Save") }
                }
            })
            .confirmationDialog("New Aircraft Options", isPresented: $showingAlert, actions: {
                Button("Import") {
                    importing = true
                }
                Button {
                    addNewByEntry()
                } label: {
                    Text("Build")
                }
            })
            .fileImporter(
                isPresented: $importing,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let file):
                    do {
                        let testFile = file.startAccessingSecurityScopedResource()
                        try aircraftManager.importMomentData(using: file)
                    } catch let error {
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .navigationTitle("W&B Key Properties")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addNewByEntry() {
        acWhileInTransit = aircraftManager.chosenAircraft
        aircraftManager.isAdding = true
        var newAC = MomentDatum()
        newAC.aircraft = "New"
        aircraftManager.chosenAircraft = newAC
    }
}

#Preview {
    AircraftParametersView()
}
