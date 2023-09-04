//
//  MissionLog.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

// This is the view used to fly the mission. It will show the active waypoint. Time to waypoint at current speed is displayed along with distance to waypoint. It shows estimated airspeed and estimated time to waypoint. It will automatically close waypoint when distance to waypoint begins increasing.

// Future version could show moving map with projected courseline between previous waypoint and destination waypoint.

import SwiftUI

struct MissionLog: View {
    
    init() {
        Core.services.gpsEngine.locationManger.startUpdatingLocation()
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MissionLog()
}
