//
//  HeadingSummarySwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import SwiftUI
import CoreLocation
import Combine

struct HeadingSummarySwiftUIView: View {
    let activeWayPoint: WayPoint
    
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                Text("Name:")
                    .font(.caption2)
                Text(activeWayPoint.name)
                    .font(.subheadline)
                    .bold()
            }
            .padding()
            VStack(alignment: .leading) {
                Text("Distance to Next:")
                    .font(.caption2)
                Text("\(Int(activeWayPoint.distanceToNextWaypoint))")
                    .font(.subheadline)
                    .bold()
            }
            Spacer()
        }
    }
}

#Preview {
    HeadingSummarySwiftUIView( activeWayPoint: WayPoint(name: "Test", location: CLLocation(latitude: 42, longitude: -115), altitude: 5000, wind: Wind(speed: 5, directionFrom: 140), courseFrom: 140, estimatedDistanceToNextWaypoint: 30, estimatedGroundSpeed: 85, estimatedTimeReached: 60, computedFuelBurnToNextWayPoint: 4.5))
}
