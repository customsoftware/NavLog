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
    let nextWayPoint: WayPoint?
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                Text("Name:")
                    .font(.caption2)
                Text(nextWayPoint?.name ?? "UNK")
                    .font(.subheadline)
                    .bold()
            }
            .padding()
            VStack(alignment: .leading) {
                Text("Distance to Next:")
                    .font(.caption2)
                Text("\(Int(computeDistanceToWayPoint()))")
                    .font(.subheadline)
                    .bold()
            }
            Spacer()
        }
    }
    
    func computeDistanceToWayPoint() -> Double {
        var retValue: Double = 0.0
        guard let currentLocation = gpsTracker.currentLocation,
              let wayPoint = nextWayPoint else { return retValue }
        
        let distanceInMeters = currentLocation.distance(from: wayPoint.location)
        let mode = AppMetricsSwift.settings.distanceMode
        if distanceInMeters < 2000 {
            retValue = round(distanceInMeters * mode.findConversionValue * 100)/100
        } else {
            retValue = round(distanceInMeters * mode.conversionValue * 100)/100
        }
        return retValue
    }
}

#Preview {
    HeadingSummarySwiftUIView( nextWayPoint: WayPoint(name: "Test", latitude: 42, longitude: -115, altitude: 5000, wind: Wind(speed: 5, directionFrom: 140), courseFrom: 140, estimatedDistanceToNextWaypoint: 30, estimatedGroundSpeed: 85, estimatedTimeReached: 60, computedFuelBurnToNextWayPoint: 4.5))
}
