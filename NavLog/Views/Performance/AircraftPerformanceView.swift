//
//  AircraftPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import SwiftUI

struct AircraftPerformanceView: View {
    @State var viewModel = AircraftPerformanceViewModel()
    
    private let textWidth: CGFloat = 180.0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        NavigationView( content: {
            Form( content: {
                Section(header: Text("Airport")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Elevation", textWidth: textWidth, promptText: "Elevation", textValue: $viewModel.environment.elevation)
                    TextEntryFieldView(formatter: formatter, captionText: "Runway Length", textWidth: textWidth, promptText: "Runway", textValue: $viewModel.environment.runwayLength)
                }
                
                Section(header: Text("Weather")) {
                    TextEntryFieldView(formatter: formatter, captionText: "Pressure", textWidth: textWidth, promptText: "Pressure", textValue: $viewModel.environment.pressure)
                    TextEntryFieldView(formatter: formatter, captionText: "Temperature", textWidth: textWidth, promptText: "Temperature", textValue: $viewModel.environment.temp)
   
                }
                
                Section(header: Text("Mission Load")) {
                    WeightEntryView(missionData: $viewModel.mission)
                }
                
                Section("Results", content: {
                    TakeOffPerformanceView(results: viewModel.missionPerformance)
                })
            })
            .toolbar(content: {
                HStack {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.computePerformance()
                        
                    } label: { Text("Calculate") }
                }
            })
            .navigationTitle("Weight & Balance")
        })
    }
}

#Preview {
    AircraftPerformanceView()
}

class AircraftPerformanceViewModel: ObservableObject {
    @Published var environment: Environment = Environment()
    @Published var mission: MissionData = MissionData()
    @Published var missionPerformance: PerformanceResults = PerformanceResults()
    
    let momentModel: MomentDatum = MomentDatum()
    
    func computePerformance() {
        environment.save()
        computeWeightLimits()
        computeCGLimits()
    }
    
    private func computeWeightLimits() {
        // Add up the weight
        var missionWeight = computeTotalWeight()
        missionPerformance.isUnderGross = missionWeight <= momentModel.maxWeight
    }
    
    private func computeCGLimits() {
        let fuelMoment: Double = momentModel.fuelMoment * mission.fuel * momentModel.fuelWeight
        let frontMoment: Double = momentModel.frontMoment * mission.copilotSeat + mission.pilotSeat
        let backMoment: Double = momentModel.backMoment * mission.backSeat
        let cargoMoment: Double = momentModel.cargoMoment * mission.cargo
        let acftMoment: Double = 170
        let oilMoment: Double = 0.7
        let totalMoment: Double = (fuelMoment + frontMoment + backMoment + cargoMoment + acftMoment + oilMoment)
        let weight = computeTotalWeight()
        
        // Compute moment of weight using min arm
        let weightLimitArm = momentModel.minArm * weight
        
        // Compare value to totalMoment... if less than, we're good
        missionPerformance.cgIsInLimits = weightLimitArm >= totalMoment
    }
    
    private func computeTotalWeight() -> Double {
        return momentModel.emptyWeight + mission.cargo + mission.fuel * momentModel.fuelWeight + mission.copilotSeat + mission.pilotSeat + mission.backSeat
    }
}


struct PerformanceResults {
    var isUnderGross: Bool = false
    var cgIsInLimits: Bool = false
    var computedTakeOffRoll: Double = 1400
    var computedOver50Roll: Double = 2100
}
