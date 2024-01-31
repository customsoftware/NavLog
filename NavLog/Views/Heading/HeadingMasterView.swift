//
//  HeadingMasterView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingMasterView: View {
    @Bindable var navEngine: NavigationEngine = Core.services.navEngine
    @Binding var altimeterOffset: Double
    @State var activeWayPointIndex: Int = 0
    @State var gpsIsRunning: Bool = false
    @State var fuelTimeRemaining: Double = Core.services.navEngine.activeLog?.fuelRemaining() ?? 0
    
    
    
    var body: some View {
        NavigationStack {
                VStack(alignment: .leading, content: {
                    if  navEngine.activeWayPoints.count > 0 {
                        Text(verbatim: navEngine.activeWayPoints[activeWayPointIndex].name)
                            .font(.headline)
                            .foregroundStyle(Color(.label))
                    }
                    let currentValues = getDisplayValues()
                    HeadingNavigationView(
                        controllingWayPoint: $navEngine.activeWayPoints[activeWayPointIndex],
                        altimeterRange: 1000,
                        plannedAltimeter: .constant(currentValues.plannedAltitude),
                        altOffset: .constant(25.0),
                        speedRange: 100,
                        plannedSpeed: .constant(currentValues.plannedGroundSpeed),
                        gpsIsActive: $gpsIsRunning,
                        timeToWayPoint: .constant(currentValues.actualTimeToNextWaypoint()),
                        fuelRemaining: $fuelTimeRemaining)
                    .padding(.bottom, 15)
                    if gpsIsRunning  {
                        HeadingSummarySwiftUIView(nextWayPoint: getNextWayPoint())
                            .padding(.bottom, 5)
                    }
                    HeadingDetailView(currentAltimeter: Core.services.gpsEngine.currentLocation?.altitude ?? 0, altimeterOffset: $altimeterOffset, aWayPoint: $navEngine.activeWayPoints[activeWayPointIndex], activeIndex: $activeWayPointIndex, waypointCount: $navEngine.activeWayPoints.count, gpsIsRunning: $gpsIsRunning)
                    
                    NavigationLink {
                        NavigationLog()
                    } label: {
                        Text("Review Navigation Log")
                    }
                    .padding(.leading, 9)
                    .buttonStyle(.bordered)
                    Spacer()
                })
                .padding()
                .background(Color(.systemGray6))
            Spacer()
        }
    }
        
    func getNextWayPoint() -> WayPoint? {
        var retValue: WayPoint?
        let nextIndex = activeWayPointIndex + 1
        guard nextIndex < navEngine.activeWayPoints.count else { return retValue }
        retValue = navEngine.activeWayPoints[nextIndex]
        return retValue
    }
    
    
    func getDisplayValues() -> CourseState {
        let currentLocation = Core.services.gpsEngine.currentLocation
        let currentWaypoint = navEngine.activeWayPoints[activeWayPointIndex]
        
        return Core.currentDisplayValues(currentLocation: currentLocation, currentWayPoint: currentWaypoint)
    }
}

#Preview {
    HeadingMasterView(navEngine: Core.services.navEngine, altimeterOffset: .constant(0))
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
