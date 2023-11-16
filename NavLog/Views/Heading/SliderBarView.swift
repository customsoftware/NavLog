//
//  SliderBarView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/4/23.
//

import SwiftUI
import CoreLocation

enum SliderMode {
    case altitude
    case groundSpeed
}

struct SliderBarView: View {
    
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    
    @Binding var topTitle: String
    /// This is pixels above or below the center of the slider. Zero "0" is the center of the slider. Allowable range is plus or minus half the height. Positive is below, Negative is above
    @Binding var range: Double
    @Binding var center: Double
    @Binding var mode: SliderMode
    @State var height: CGFloat = 125
    
    var body: some View {
        
        
        VStack {
            Text(topTitle)
                .offset(y: 10)
            Rectangle()
                .frame(width: 25, height: 2, alignment: .center)
                .offset(y: 4)
            ZStack {
                
                // Vertical line
                Rectangle()
                    .frame(width: 2, height: height, alignment: .center)
                // Horizontal line
                Rectangle()
                    .frame(width: 25, height: 2, alignment: .center)
                // Actual value caret
                Image(systemName: "diamond.fill", variableValue: 1.00)
                .symbolRenderingMode(.monochrome)
                .foregroundColor(Color.accentColor)
                .font(.system(size: 16, weight: .regular))
                .offset(y: computeDisplayValueInRange())
            }
            Rectangle()
                .frame(width: 20, height: 2, alignment: .center)
                .offset(y: -4)
        }
    }
    
    /// GPS gives values in meters, we need to convert to the selected metric - default feet
    func computeDisplayValueInRange() -> CGFloat {
        guard let _ = Core.services.gpsEngine.currentLocation else { return 0 }
        
        var workingValue: Double = 0
        switch mode {
        case .altitude:
            workingValue = gpsTracker.altitude * GPSObserver.metersToFeet
            print("Slider altitude value updated")
        case .groundSpeed:
            workingValue = gpsTracker.speed * GPSObserver.metersToStandardMiles
            print("Slider airspeed value updated")
        }
        
        let centerPoint = range / 2
        if workingValue > (center + centerPoint) {
            workingValue = center + centerPoint
        } else if workingValue < (center - centerPoint) {
            workingValue = center - centerPoint
        }
        
        return (height * (center - workingValue)) / range
    }
}

//#Preview {
//    SliderBarView(topTitle: .constant("Alt"), value: .constant(830.0), range: .constant(1000), center: .constant(500))
//}
