//
//  HeadingMasterView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingMasterView: View {
    @Binding var wayPointList: [WayPoint]
    @Binding var altimeterOffset: Double
    @State var activeWayPointIndex: Int = 0
    @State var gpsIsRunning: Bool = false
    @State var fuelTimeRemaining: Double = Core.services.navEngine.activeLog?.fuelRemaining() ?? 0
    
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, content: {
                if wayPointList.count > 0 {
                    Text(verbatim: wayPointList[activeWayPointIndex].name)
                        .font(.headline)
                        .foregroundStyle(Color(.label))
                }
                let currentValues = getDisplayValues()
                HeadingNavigationView(
                    controllingWayPoint: $wayPointList[activeWayPointIndex],
                    altimeterRange: 1000,
                    plannedAltimeter: .constant(currentValues.plannedAltitude),
                    altOffset: .constant(25.0),
                    speedRange: 100,
                    plannedSpeed: .constant(currentValues.plannedGroundSpeed),
                    gpsIsActive: $gpsIsRunning,
                    timeToWayPoint: .constant(currentValues.actualTimeToNextWaypoint()),
                    fuelRemaining: $fuelTimeRemaining)
                
                WaypointListItem(wayPoint: $wayPointList[activeWayPointIndex])
                    .padding(.top, 10)
                
                HeadingDetailView(currentAltimeter: Core.services.gpsEngine.currentLocation?.altitude ?? 0, altimeterOffset: $altimeterOffset, aWayPoint: $wayPointList[activeWayPointIndex], activeIndex: $activeWayPointIndex, waypointCount: wayPointList.count, gpsIsRunning: $gpsIsRunning)
                
                // Do something here
                NavigationLink {
                    NavigationLog()
                } label: {
                    Text("Review Navigation Log")
                }
                .padding(.leading, 9)
                .buttonStyle(.bordered)
                
            })
            .padding()
            .background(Color(.systemGray6))
        }

    }
        
    
    func getDisplayValues() -> CourseState {
        let currentLocation = Core.services.gpsEngine.currentLocation
        let currentWaypoint = wayPointList[activeWayPointIndex]
        
        return Core.currentDisplayValues(currentLocation: currentLocation, currentWayPoint: currentWaypoint)
    }
}

#Preview {
    HeadingMasterView(wayPointList: .constant(Core.services.navEngine.loadWayPoints()), altimeterOffset: .constant(0))
}


struct CourseState {
    var currentHeading: Int
    var plannedHeading: Int
    func deviation() -> Int {
        return plannedHeading - Int(currentHeading)
    }
    var plannedAltitude: Double
    var currentAltitude: Double
    var observedGroundSpeed: Double
    var plannedGroundSpeed: Double
    var plannedTimeToNextWaypoint: Double
    var distanceToWayPoint: Double
    func actualTimeToNextWaypoint() -> Double {
        var retValue: Double = 0
        guard observedGroundSpeed > 0 else { return retValue }
        retValue = (round(distanceToWayPoint/(Double(observedGroundSpeed)/60) * 100)) / 100
        return retValue
    }
}
