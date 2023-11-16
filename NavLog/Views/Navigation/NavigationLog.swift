//
//  NavigationLog.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

// This is the view used to enter the navigation log waypoints. In a future release it could accept a pre-planned mission via exported file from FlyQ or ForeFlight.

import SwiftUI

struct NavigationLog: View {
    @State private var missionLog: [WayPoint] = Core.services.navEngine.activeWayPoints.sorted { w1, w2 in
        w1.sequence < w2.sequence
    }
    
    var body: some View {
            List($missionLog) { waypoint in
                NavigationLink {
                    NavigationDetail(waypoint: waypoint)
                } label: {
                    WaypointListItem(wayPoint: waypoint)
                }
            }
            .navigationTitle("Navigation Log Details")
    }
}

#Preview {
    NavigationLog()
}
