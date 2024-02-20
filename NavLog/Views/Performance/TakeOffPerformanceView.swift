//
//  TakeOffPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI
import Combine
import NavTool

struct TakeOffPerformanceView: View {
    var performance: PerformanceResults
    var environment: WeatherEnvironment
    @StateObject private var metrics = AppMetricsSwift.settings
    
    var body: some View {
        VStack (alignment: .leading, content: {
            
            if performance.isUnderGross {
                Text("Under Max Gross by: \(abs(Int(performance.overWeightAmount))) lbs.")
                    .foregroundStyle(.primary)
                    .bold()
            } else {
                Text("Over Gross: \(Int(performance.overWeightAmount)) lbs.")
                    .foregroundStyle(.red)
                    .bold()
            }
            
            if performance.cgIsInLimits {
                Text("Within CG Limits")
                    .foregroundStyle(.primary)
                    .bold()
            } else {
                Text("Out of CG Limits")
                    .foregroundStyle(.red)
                    .bold()
            }
            
            Text("Crosswind component \(computeCrossWind()) \(metrics.speedMode.modeSymbol)")
                .padding()
                .italic()
            
            Text("Pressure Altitude: \(Int(environment.pressureAltitude))")
            Text("Density Altitude: \(Int(environment.densityAltitude))")
            Divider()
            Text("Take off roll: \(Int(performance.computedTakeOffRoll))")
            Text("Over 50' roll: \(Int(performance.computedOver50Roll))")
            Divider()
            Text("Landing roll: \(performance.computedLandingRoll)")
            Text("Landing over 50': \(performance.computedLandingOver50Roll)")
        })
    }
    
    private func computeCrossWind() -> String {
        let retValue: String
        let deltaWind = abs(environment.windDirection - (environment.runwayDirection * 10))
        let deltaWindRadians = NavTool.shared.convertToRadians(degrees: deltaWind)
        let crossWindRadians = sin(deltaWindRadians)
        let crossWindSpeed = abs(round(crossWindRadians * environment.windSpeed))
        retValue = "\(Int(crossWindSpeed))"
        return retValue
    }
}

#Preview {
    TakeOffPerformanceView(performance: PerformanceResults(), environment: WeatherEnvironment())
}
