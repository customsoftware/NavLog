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
        NavigationView {
            Form {
                Section("AC Weights", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Maximum:", textWidth: textWidth, promptText: "Enter Max Weight", textValue: $viewModelController.momentData.maxWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Empty", textWidth: textWidth, promptText: "Enter Empty Weight", textValue: $viewModelController.momentData.emptyWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Minimum", textWidth: textWidth, promptText: "Min AC Weight", textValue: $viewModelController.momentData.minWeight)
                    
                    
                })
                
                Section("Fuel", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Gallons", textWidth: textWidth, promptText: "Enter Max Fuel Gallons", isBold: true, textValue: $viewModelController.momentData.maxFuelGallons)
          
                    TextEntryFieldView(formatter: formatter, captionText: "Max Fuel Moment", textWidth: textWidth, promptText: "Max Fuel Moment", isBold: true, textValue: $viewModelController.momentData.fuelMoment)
                })
                
                Section("Cargo and Pax", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Front Seat Max Weight", textWidth: textWidth, promptText: "Front Seat Max Weight", textValue: $viewModelController.momentData.maxFrontWeight)
           
                    TextEntryFieldView(formatter: formatter, captionText: "Front Seat Moment", textWidth: textWidth, promptText: "Front Seat Moment", isBold: true, textValue: $viewModelController.momentData.frontMoment)

    //                TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Max Weight", textWidth: textWidth, promptText: "EMid Seat Max Weight", textValue: .constant(0.0))
    //
    //                TextEntryFieldView(formatter: formatter, captionText: "Mid Seat Moment", textWidth: textWidth, promptText: "Mid Seat Moment", isBold: true, textValue: .constant(0.0))
        
                    TextEntryFieldView(formatter: formatter, captionText: "Back Seat Max Weight", textWidth: textWidth, promptText: "Back Seat Max Weight", textValue: $viewModelController.momentData.maxBackWeight)
        
                    TextEntryFieldView(formatter: formatter, captionText: "Back Seat Moment", textWidth: textWidth, promptText: "Back Seat Moment", isBold: true, textValue: $viewModelController.momentData.backMoment)
         
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo Max Weight", textWidth: textWidth, promptText: "Cargo Max Weight", textValue: $viewModelController.momentData.maxCargoWeight)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Cargo Moment", textWidth: textWidth, promptText: "Cargo Moment", isBold: true, textValue: $viewModelController.momentData.cargoMoment)
                })

                Section("Moment Limit Values", content: {
                    TextEntryFieldView(formatter: formatter, captionText: "Max Moment", textWidth: textWidth, promptText: "Max Moment", isBold: true, textValue: $viewModelController.momentData.maxArm)
                    
                    TextEntryFieldView(formatter: formatter, captionText: "Min Moment", textWidth: textWidth, promptText: "Min Moment", isBold: true, textValue: $viewModelController.momentData.minArm)
                })
            }
            .toolbar(content: {
                HStack {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModelController.updateMomentArms()
                        viewModelController.momentData.save()
                    } label: { Text("Save") }
                }
            })
            .navigationTitle("Aircraft Properties")
        }
    }
}

#Preview {
    AircraftParametersView()
}


class AircraftParametersViewModel : ObservableObject {
    // This stores the data
    @Published var momentData: MomentDatum
    @Published var frontArm: Double?
    @Published var backArm: Double?
    @Published var fuelArm: Double?
    @Published var cargoArm: Double?
    @Published var isUnderGross: Bool = false
    @Published var cgIsInLimits = true
    
    var maxArm: Double?
    var minArm: Double?
    
    
    init(momentData: MomentDatum) {
        self.momentData = momentData
    }
    
    func updateMomentArms() {
        frontArm = computeMomentArm(self.momentData.maxFrontWeight, self.momentData.frontMoment)
        backArm = computeMomentArm(self.momentData.maxBackWeight, self.momentData.backMoment)
        fuelArm = computeMomentArm(self.momentData.maxFuelGallons * self.momentData.fuelWeight, self.momentData.fuelMoment)
        cargoArm = computeMomentArm(self.momentData.maxCargoWeight, self.momentData.cargoMoment)
        minArm = computeMomentArm(self.momentData.minWeight, self.momentData.minArm)
        maxArm = computeMomentArm(self.momentData.maxWeight, self.momentData.maxArm)
   }
    
    private func computeMomentArm(_ weight: Double, _ moment: Double) -> Double {
        return weight / moment
    }
}


