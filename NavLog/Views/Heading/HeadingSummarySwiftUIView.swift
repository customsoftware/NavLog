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
                Text("\(Int(computeDistanceToWayPoint().0)) \(computeDistanceToWayPoint().1)")
                    .font(.subheadline)
                    .bold()
            }
            Spacer()
        }
    }
    
    func computeDistanceToWayPoint() -> (Double, String) {
        var retValue: Double = 0.0
        var units: String = ""
        guard let currentLocation = gpsTracker.currentLocation,
              let wayPoint = nextWayPoint else { return (retValue, units) }
        
        let distanceInMeters = currentLocation.distance(from: wayPoint.location)
        let mode = AppMetricsSwift.settings.distanceMode
        if distanceInMeters < 2000 {
            units = mode.fineDetail
            retValue = round(distanceInMeters * mode.findConversionValue * 100)/100
        } else {
            units = mode.coarseDetail
            retValue = round(distanceInMeters * mode.conversionValue * 100)/100
        }
        return (retValue, units)
    }
}

#Preview {
    HeadingSummarySwiftUIView( nextWayPoint: WayPoint(name: "Test", latitude: 42, longitude: -115, altitude: 5000, wind: Wind(speed: 5, directionFrom: 140), courseFrom: 140, estimatedDistanceToNextWaypoint: 30, estimatedGroundSpeed: 85, estimatedTimeReached: 60, computedFuelBurnToNextWayPoint: 4.5))
}
