//
//  TakeOffPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI
import Combine

struct TakeOffPerformanceView: View {
   var performance: PerformanceResults?
    
    var body: some View {
        VStack (alignment: .leading, content: {
            
            if performance?.isUnderGross ?? false {
                Text("Under Max Gross by: \(abs(Int(performance?.overWeightAmount ?? 0))) lbs.")
                    .foregroundStyle(.primary)
                    .bold()
            } else {
                Text("Over Gross: \(Int(performance?.overWeightAmount ?? 0)) lbs.")
                    .foregroundStyle(.red)
                    .bold()
            }
            
            if performance?.cgIsInLimits ?? false {
                Text("Within CG Limits")
                    .foregroundStyle(.primary)
                    .bold()
            } else {
                Text("Out of CG Limits")
                    .foregroundStyle(.red)
                    .bold()
            }
            
            Text("Pressure Altitude: \(Int(performance?.pressureAltitude ?? 0))")
            Text("Density Altitude: \(Int(performance?.densityAltitude ?? 0))")
            Text("Take off roll: \(Int(performance?.computedTakeOffRoll ?? 0))")
            Text("Over 50' roll: \(Int(performance?.computedOver50Roll ?? 0))")
        })
    }
}

#Preview {
    TakeOffPerformanceView()
}
