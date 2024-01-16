//
//  AircraftManager.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/16/24.
//

import Foundation


class AircraftManager: ObservableObject {
    
    @Published private (set) var availableAircraft: [MomentDatum] = []
    
    func fetchStoredAircraft(){
        availableAircraft.removeAll()
        availableAircraft.append(MomentDatum(from: "CardinalMoment"))
        availableAircraft.append(MomentDatum(from: "KatanaMoment"))
        availableAircraft.append(MomentDatum(from: "Cherokee140Moment"))
        availableAircraft.append(MomentDatum(from: "DA40 Moment"))
  }
}


// weights are in pounds
// arm is inches from datum
// aircraft arm is different it is moment-arm

