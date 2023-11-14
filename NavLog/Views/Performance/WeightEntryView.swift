//
//  WeightEntryView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct WeightEntryView: View {
    @Binding var missionData: MissionData
    
    var body: some View {
        Text("Weight Entry")
    }
}

#Preview {
    WeightEntryView(missionData: .constant(MissionData()))
}


struct MissionData {
    var pilotSeat: Double = 150
    var copilotSeat: Double = 0
    var middleSeat: Double = 0
    var backSeat: Double = 0
    var cargo: Double = 80
    var fuel: Double = 48
}
