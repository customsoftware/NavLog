//
//  HeadingMasterView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingMasterView: View {
    @Binding var wayPointList: [WayPoint]
    @State var activeWayPoint: Int = 0
    @State var gpsIsRunning: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Text(verbatim: wayPointList[activeWayPoint].name)
                .font(.headline)
                .foregroundStyle(Color(.label))
            HeadingNavigationView(controllingWayPoint: $wayPointList[activeWayPoint],
                                  gpsIsActive: $gpsIsRunning)
            Divider()
            WaypointListItem(wayPoint: $wayPointList[activeWayPoint])
                .padding(.top, 5)
            Spacer()
            HeadingDetailView(aWayPoint: $wayPointList[activeWayPoint],
                              activeIndex: $activeWayPoint,
                              waypointCount: wayPointList.count,
                              gpsIsRunning: $gpsIsRunning)
        })
        .padding()
        .background(Color(.systemGray6))
    }
}

#Preview {
    HeadingMasterView(wayPointList: .constant(Core.services.navEngine.loadWayPoints()))
}
