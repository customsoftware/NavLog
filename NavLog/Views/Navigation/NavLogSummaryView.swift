//
//  NavLogSummaryView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/25/24.
//

import SwiftUI

struct NavLogSummaryView: View {
    
    @Binding var wayPointList: [WayPoint]
    @State private var totalTime: String = ""
    @State private var totalFuel: Double = 0
    @State private var totalDistance: Double = 0
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Log Summary")
                .font(.caption)
            HStack {
                Text("Time: \(totalTime)")
                Text("Fuel: \(String(format: "%g", totalFuel))")
                Text("Distance: \(Int(totalDistance))")
            }
        }
        .onAppear(perform: {
            let values = rollupLogValues()
            totalFuel = values.0
            totalTime = values.1
            totalDistance = values.2
        })
    }
    
    private func rollupLogValues() -> (Double, String, Double) {
        var totalFuel: Double = 0
        var totalDistance: Double = 0
        var totalTime: Double = 0
        var stringTime: String = "0:00"
        
        wayPointList.forEach { aWayPoint in
            totalFuel = totalFuel + aWayPoint.estimatedFuelBurn(acData: AircraftPerformance.shared)
            totalDistance = totalDistance + aWayPoint.estimatedDistanceToNextWaypoint
            totalTime = totalTime + aWayPoint.computeTimeToWaypoint()
        }
        
        stringTime = estimateTime(from: totalTime)
        
        return (totalFuel, stringTime, totalDistance)
    }
    
    private func estimateTime(from totalTime: Double) -> String {
        var retValue: String = ""
        retValue = "\(Int(totalTime)/60):"
        let seconds = Int(totalTime.truncatingRemainder(dividingBy: 60))
        if seconds < 10 {
            retValue = retValue + "0\(seconds)"
        } else {
            retValue = retValue + "\(seconds)"
        }
        return retValue
    }
}

#Preview {
    NavLogSummaryView(wayPointList: .constant(Core.services.navEngine.activeWayPoints))
}
