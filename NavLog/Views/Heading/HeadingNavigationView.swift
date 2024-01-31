//
//  HeadingNavigationView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//
//  A valuable article
//  https://medium.com/@cmallikarjun118/dependency-injection-in-swiftui-0dd5bc6f00a8

import SwiftUI
import CoreLocation

struct HeadingNavigationView: View {
    
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    @State var size: CGSize = .zero
    
    @State var altimeterTitle: String = "ALT"
    @State var speedTitle: String = "GS"
    @Binding var controllingWayPoint: WayPoint
    
    @State var altimeterRange: Double = 1000
    @Binding var plannedAltimeter: Double
    @Binding var altOffset: Double

    @State var speedRange: Double = 100
    @Binding var plannedSpeed: Double

    @Binding var gpsIsActive: Bool
    @Binding var timeToWayPoint: Double // This is in seconds
    @Binding var fuelRemaining: Double // This is minutes to fuel exhaustion
    
    var body: some View {
        ZStack(alignment: .topLeading, content: {
            Rectangle()
                .frame(minWidth: 280, idealWidth: 320, maxWidth: .infinity, minHeight: 280, idealHeight: 320, maxHeight: 320, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(15.0)
                .foregroundColor(Color(.systemBackground))
            VStack(alignment: .center, content: {
                Text("\(controllingWayPoint.headingFrom())")
                    .font(.bold(.body)())
                    .frame(minWidth: 280, idealWidth: 300, maxWidth: .infinity, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .foregroundColor(Color(.label))
                ZStack {
                    Rectangle() // This is the desired course line
                        .frame(minWidth: 2, idealWidth: 2, maxWidth: 2, minHeight: 175, idealHeight: 240, maxHeight: 270, alignment: .center)
                    .foregroundColor(Color(.label))
                }
                
                if gpsIsActive {
                    Text(getDirectionToTurn(width:300))
                }
                
                Spacer()
            })
            
            VStack(alignment: .center) {
                HStack {
                    VStack(alignment: .center) {
                        Text("Time to Waypoint")
                            .frame(width: 75, height: 50, alignment: .leading)
                        if gpsIsActive {
                            Text(convertTimeString(Double(timeToWayPoint)))
                                .bold()
                                .foregroundColor(Color.accentColor)
                        } else {
                            Text(" ")
                        }
                        
                        SliderBarView(currentValue: gpsTracker.altitude, range: altimeterRange, center: plannedAltimeter, mode: .altitude)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Fuel Left")
                            .frame(width: 50, height: 50, alignment: .leading)
                        if gpsIsActive {
                            Text(convertTimeString(fuelRemaining))
                                .bold()
                                .foregroundColor(Color.accentColor)
                        } else {
                            Text(" ")
                        }
                        
                        SliderBarView(currentValue: gpsTracker.speed, range: speedRange, center: plannedSpeed, mode: .groundSpeed)
                    }
                }
                .padding(.leading, 30)
                .padding(.trailing, 10)
                .padding(.top, 1) // This value depends on screen size
            }
            
            /// The key to this working is its offset must be according to deviation of actual heading, obtained by GPS from planned heading is is programmed in. To do this we need to know the width of the containing view
            if gpsIsActive,
               Int(gpsTracker.course) != -1 {
                
                VStack(content: {
                    GeometryReader { proxy in
                        VStack {} // just an empty container to triggers the onAppear
                            .onAppear {
                                size = proxy.size
                            }
                    }
                    
                    Text("\(String(Int(gpsTracker.course)))")
                        .bold()
                    ZStack (alignment: .center) {
                        Rectangle() // This is the current line
                            .frame(width: 2, height: 125)
                        Image(systemName: "airplane")
                        .symbolRenderingMode(.monochrome)
                        .rotationEffect(.degrees(270))
                        .font(.system(size: 32))
                    }
                })
                .foregroundColor(Color.accentColor)
                .offset(x: convertDegreeToXOffset(size.width), y: -40)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 0)
//            } else {
//                VStack(content: {
//                    Text(" ")
//                        .bold()
//                    ZStack (alignment: .center) {
//                        Rectangle() // This is the current line
//                            .frame(width: 0, height: 125)
//                    }
//                })
//                .foregroundColor(Color.accentColor)
////                .offset(x: 100, y: 100)
//                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 0)
            }
        })
        .clipped()
    }
    
    private func getDirectionToTurn(width: CGFloat) -> String {
        let x = convertDegreeToXOffset(300)
        let string: String
        if x >= 0 {
            string = "Turn Left"
        } else {
            string = "Turn Right"
        }
        return string
    }
    
    func convertDegreeToXOffset(_ width: CGFloat) -> CGFloat {
        var retValue: CGFloat = 0
        
        let plannedHeading: Double = Double(controllingWayPoint.headingFrom())
        let currentHeading: Double = gpsTracker.course
        let reciprocal: Double = plannedHeading - 180
        
        let offset: Double
        if currentHeading < reciprocal {
            offset = (currentHeading + 360) - plannedHeading
        } else {
            offset = currentHeading - plannedHeading
        }
        retValue = CGFloat(offset)

        let range: CGFloat = 25.0
        
        if retValue >= range {
            retValue = range
        } else if retValue <= -range {
            retValue = -range
        }
        
        return (retValue * 2)
    }
    
    private func convertLocationAltitudeToDouble(_ location: CLLocation?) -> Double {
        var locationAltitude: Double = 0
        defer { print("Altitude: \(locationAltitude)") }
        guard let aLocation = location else { return 0 }
        locationAltitude = aLocation.altitude
        return locationAltitude
    }
    
    private func convertLocationSpeedToDouble(_ location: CLLocation?) -> Double {
        guard let aLocation = location else { return 0 }
        let computedSpeed = aLocation.speed
        return computedSpeed
    }
    
    private func convertTimeString(_ timeRemaining: Double?) -> String {
        let computedTimeRemaining: Int
        /// Convert this into minutes and seconds
        if let timeRemaining, timeRemaining >= 0 {
            computedTimeRemaining = Int(timeRemaining)
        } else {
            computedTimeRemaining = 0
        }
        let seconds: Int = computedTimeRemaining % 60
        let minutes: Int = computedTimeRemaining / 60
        return "\(minutes):\(seconds)"
    }
}

#Preview {
    HeadingNavigationView(controllingWayPoint: .constant(Core.services.navEngine.loadWayPoints().first!),
                          altimeterRange: 1000,
                          plannedAltimeter: .constant(5500),
                          altOffset: .constant(25),
                          speedRange: 100,
                          plannedSpeed: .constant(110),
                          gpsIsActive: .constant(true),
                          timeToWayPoint: .constant(76),
                          fuelRemaining: .constant(225))
}
