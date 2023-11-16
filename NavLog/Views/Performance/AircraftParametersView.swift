//
//  AircraftParametersView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct AircraftParametersView: View {
    
    // This manipulates it
    @StateObject var viewModelController = AircraftParametersViewModel(momentData: MomentDatum())
    
    private let textWidth: CGFloat = 180.0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        Form {
            Section("AC Weights", content: {
                TextEntryFieldView(formatter: formatter, captionText: "Maximum:", textWidth: textWidth, promptText: "Enter Max Weight", textValue: $viewModelController.momentData.maxWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Empty", textWidth: textWidth, promptText: "Enter Empty Weight", textValue: $viewModelController.momentData.emptyWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Aircraft Moment", textWidth: textWidth, promptText: "Aircraft Moment", textValue: $viewModelController.momentData.aircraftArm)
            })
            .onAppear(perform: {
                viewModelController.loadProfile()
            })
            
            Section("Fuel", content: {
                TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Gallons", textWidth: textWidth, promptText: "Enter Max Fuel Gallons", isBold: true, textValue: $viewModelController.momentData.maxFuelGallons)
                
                TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Arm", textWidth: textWidth, promptText: "Max Fuel Moment", isBold: true, textValue: $viewModelController.momentData.fuelMoment)
            })
            
            Section(header: Text("Cargo and Pax")) {
                
                TextEntryFieldView(formatter: formatter, captionText: "Oil Weight", textWidth: textWidth, promptText: "Oil Weight", textValue: $viewModelController.momentData.oilWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Oil Arm", textWidth: textWidth, promptText: "Oil Arm", isBold: true, textValue: $viewModelController.momentData.oilMoment)
                
                TextEntryFieldView(formatter: formatter, captionText: "Front Seat Max Weight", textWidth: textWidth, promptText: "Front Seat Max Weight", textValue: $viewModelController.momentData.maxFrontWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Front Seat Arm", textWidth: textWidth, promptText: "Front Seat Moment", isBold: true, textValue: $viewModelController.momentData.frontMoment)
                
                // If more than four seats show
                if (viewModelController.performance?.seatCount ?? 2) > 4 {
                    TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Max Weight", textWidth: textWidth, promptText: "EMid Seat Max Weight", textValue: .constant(0.0))
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Arm", textWidth: textWidth, promptText: "Mid Seat Moment", isBold: true, textValue: .constant(0.0))
                }
                
                TextEntryFieldView(formatter: formatter, captionText: "Back Seat Max Weight", textWidth: textWidth, promptText: "Back Seat Max Weight", textValue: $viewModelController.momentData.maxBackWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Back Seat Arm", textWidth: textWidth, promptText: "Back Seat Moment", isBold: true, textValue: $viewModelController.momentData.backMoment)
                
                TextEntryFieldView(formatter: formatter, captionText: "Cargo Max Weight", textWidth: textWidth, promptText: "Cargo Max Weight", textValue: $viewModelController.momentData.maxCargoWeight)
                
                TextEntryFieldView(formatter: formatter, captionText: "Cargo Arm", textWidth: textWidth, promptText: "Cargo Moment", isBold: true, textValue: $viewModelController.momentData.cargoMoment)
            }
        }
        .toolbar(content: {
            HStack {
                Spacer()
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    viewModelController.momentData.save()
                } label: { Text("Save") }
            }
        })
        .navigationTitle("W&B Key Properties")
        .navigationBarTitleDisplayMode(.inline)
   
    }
}

#Preview {
    AircraftParametersView()
}


class AircraftParametersViewModel : ObservableObject {
    @Published var momentData: MomentDatum
    @Published var oilArm: Double?
    @Published var aircraftArm: Double?
    @Published var frontArm: Double?
    @Published var backArm: Double?
    @Published var fuelArm: Double?
    @Published var cargoArm: Double?
    @Published var isUnderGross: Bool = false
    @Published var cgIsInLimits = true
    private(set) var performance: PerformanceProfile?
    
    init(momentData: MomentDatum) {
        self.momentData = momentData
    }
    
    func loadProfile() {
        // This will change as the app evolves, right now it hard codes to a file
        guard let perfProfilePath = Bundle.main.path(forResource: "CardinalTakeOff", ofType: "json")
        else { return }
        do {
            let perfJSON = try String(contentsOfFile: perfProfilePath).data(using: .utf8)
            let performanceProfile = try JSONDecoder().decode(PerformanceProfile.self, from: perfJSON!)
            self.performance = performanceProfile
        } catch {
            print("Reading the file didn't work. Error: \(error.localizedDescription)")
        }
    }
}


