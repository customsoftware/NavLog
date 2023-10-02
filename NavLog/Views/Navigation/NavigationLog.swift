//
//  NavigationLog.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

// This is the view used to enter the navigation log waypoints. In a future release it could accept a pre-planned mission via exported file from FlyQ or ForeFlight.

import SwiftUI

struct NavigationLog: View {
    
    @Binding var missionLog: [WayPoint]
    
    var body: some View {
        NavigationSplitView {
            List($missionLog) { waypoint in
                NavigationLink {
                    NavigationDetail(waypoint: waypoint)
                } label: {
                    WaypointListItem(wayPoint: waypoint)
                }
            }
            .navigationTitle("Navigation List")
        } detail: {
            Text("Select a waypoint")
        }
    }
    

    func computeClimb() {
        // This takes current altitude and altitude of the next waypoint. It then takes Vy value and computes time to altitude. Then it computes horizontal distance using ground speed.
        // It then creates a "climbing Waypoint and inserts it between the previous and active waypoint.
        // Once it is injected, the following waypoint is amended to account for this one's impact on distant traveled.
    }

    
    func computeDescent() {
        // This takes current altitude and altitude of the next waypoint. It then takes standard descent value and computes time to altitude. Then it computes horizontal distance using ground speed.
        // It then creates a "descending Waypoint and inserts it between the previous and active waypoint.
        // Once it is injected, the following waypoint is amended to account for this one's impact on distant traveled.
    }
}

#Preview {
    NavigationLog(missionLog: .constant(Core.services.navEngine.buildTestNavLog()!.log))
}
