//
//  WeightEntryView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct WeightEntryView: View {
    @Binding var missionData: MissionData
    var formatter: NumberFormatter
    private let boxWidth: CGFloat = 60.0
    private let boxHeight: CGFloat = 45.0
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Pilot")
                TextField("Pilot", value: $missionData.pilotSeat, formatter: formatter)
                    .keyboardType(.numberPad)
                    .frame(width: boxWidth, height: boxHeight, alignment: .center)
                    .border(.black)
                    .cornerRadius(6.0)
            }
            VStack {
                Text("Co-Pilot")
                TextField("Co-Pilot", value: $missionData.copilotSeat, formatter: formatter)
                    .keyboardType(.numberPad)
                    .frame(width: boxWidth, height: boxHeight, alignment: .center)
                    .border(.black)
                    .cornerRadius(6.0)
            }
            .frame(width: 120, height: 120)
            Spacer()
        }
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
            Text("Fuel")
            HStack {
                TextField("Fuel", value: $missionData.fuel, formatter: formatter)
                    .keyboardType(.numberPad)
                    .frame(width: boxWidth * 3, height: boxHeight, alignment: .center)
                    .border(.black)
                    .cornerRadius(6.0)
            }

            Text("Back Seat")
            TextField("Back Seat", value: $missionData.backSeat, formatter: formatter)
                .keyboardType(.numberPad)
                .frame(width: boxWidth * 2, height: boxHeight, alignment: .center)
                .border(.black)
                .cornerRadius(6.0)

            Text("Cargo")
            TextField("Cargo", value: $missionData.cargo, formatter: formatter)
                .keyboardType(.numberPad)
                .frame(width: boxWidth * 2, height: boxHeight, alignment: .center)
                .border(.black)
                .cornerRadius(6.0)
        })
    }
}

#Preview {
    WeightEntryView(missionData: .constant(MissionData()), formatter: NumberFormatter())
}


struct MissionData {
    var pilotSeat: Double = 150
    var copilotSeat: Double = 0
    var middleSeat: Double = 0
    var backSeat: Double = 0
    var cargo: Double = 80
    var fuel: Double = 48
}
