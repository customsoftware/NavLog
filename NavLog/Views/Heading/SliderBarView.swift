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
    
    var title: String {
        let retValue: String
        switch self {
        case .altitude:
            retValue = "Alt"
        case .groundSpeed:
            retValue = "GS"
        }
        
        return retValue
    }
}

struct SliderBarView: View {
    /// For altitude, this is in meters, for ground speed it's kilometers per hour
    var currentValue: Double
    /// This is pixels above or below the center of the slider. Zero "0" is the center of the slider. Allowable range is plus or minus half the height. Positive is below, Negative is above
    var range: Double
    /// For altitude, this is in feet, for ground speed it's mile per our
    var center: Double
    var mode: SliderMode
    private let height: Double = 125
    
    var body: some View {
        VStack {
            Text(mode.title)
                .offset(y: 10)
            // Upper bounding line
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
            // Lower bounding line
            Rectangle()
                .frame(width: 20, height: 2, alignment: .center)
                .offset(y: -4)
        }
    }
    
    /// GPS gives values in meters, we need to convert to the selected metric - default feet
    /// - Parameters
    /// - None
    /// A negative return value moves the caret up. A positive value moves it down. This way the app can tell if you are higher/faster or
    /// lower/slower than the desired value, which is the center
    func computeDisplayValueInRange() -> CGFloat {
        
        var workingValue: Double = 0
        switch mode {
        case .altitude:
            workingValue = currentValue * GPSObserver.metersToFeet
        case .groundSpeed:
            workingValue = currentValue * GPSObserver.metersToStandardMiles
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

#Preview {
    SliderBarView(currentValue: 40, range: 100, center: 110, mode: .groundSpeed)
}
