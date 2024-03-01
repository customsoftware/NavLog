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
import NavTool

struct HeadingNavigationView: View {
    
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    @State var size: CGSize = .zero
    
    @State var altimeterTitle: String = "ALT"
    @State var speedTitle: String = "GS"
    let controllingWayPoint: WayPoint
    let nextWayPoint: WayPoint?
    
    @State var altimeterRange: Double = 1000
    var plannedAltimeter: Double
    @Binding var altOffset: Double

    @State var speedRange: Double = 100
    var plannedSpeed: Double

    var gpsIsActive: Bool
    var navMode: NavigationMode
    
    var body: some View {
        ZStack(alignment: .topLeading, content: {
            Rectangle()
                .frame(minWidth: 280, idealWidth: 320, maxWidth: .infinity, minHeight: 280, idealHeight: 320, maxHeight: 320, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(15.0)
                .foregroundColor(Color(.systemBackground))
            VStack(alignment: .center, content: {
                Text("\(getCenterBarCourse())")
                    .font(.bold(.body)())
                    .frame(minWidth: 280, idealWidth: 300, maxWidth: .infinity, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .foregroundColor(Color(.label))
                ZStack {
                    Rectangle() // This is the desired course line
                        .frame(minWidth: 2, idealWidth: 2, maxWidth: 2, minHeight: 175, idealHeight: 240, maxHeight: 270, alignment: .center)
                    .foregroundColor(Color(.label))
                }
                
                if gpsIsActive {
                    Text(getDirectionToTurn())
                }
                
                Spacer()
            })
            
            VStack(alignment: .center) {
                HStack {
                    VStack(alignment: .center) {
                        if gpsIsActive {
                            Text("Time to Waypoint")
                                .frame(width: 75, height: 50, alignment: .leading)
                            Text(convertTimeString(getTimeToNextWaypoint()))
                                .bold()
                                .foregroundColor(Color.accentColor)
                        }
                        SliderBarView(currentValue: (gpsIsActive ? gpsTracker.altitude : 0), range: altimeterRange, center: plannedAltimeter, mode: .altitude)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        if gpsIsActive {
                            Text("")
                                .frame(width: 75, height: 50, alignment: .leading)
                            Text(" ")
                        }
//                        SliderBarView(currentValue: (gpsIsActive ? 35.7632 : 0), range: speedRange, center: plannedSpeed, mode: .groundSpeed)
                        SliderBarView(currentValue: (gpsIsActive ? gpsTracker.speed : 0), range: speedRange, center: plannedSpeed, mode: .groundSpeed)
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
                    .padding([.top], 10)
                })
                .foregroundColor(Color.accentColor)
                .offset(x: convertDegreeToXOffset(), y: -40)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 0)
            }
        })
        .clipped()
    }
    
    /// Returns seconds
    private func getTimeToNextWaypoint() -> Double {
        var retValue: Double = 0
        guard let nextWP = nextWayPoint,
              let currentLoc = gpsTracker.currentLocation  else { return retValue }
        let speed = currentLoc.speed
        let distance = currentLoc.distance(from: nextWP.location)
        guard speed > 0,
              distance > 0 else { return retValue }
        retValue = distance / speed
        return retValue
    }
    
    private func getCenterBarCourse() -> Int {
        let retValue: Int
        switch navMode {
        case .matchHeading:
            retValue = Int(controllingWayPoint.headingFrom())
        case .steerToWayPoint:
            // We need to compute the course from where we are to the next waypoint
            guard let nextWP = nextWayPoint,
                  let currentLoc = gpsTracker.currentLocation else { return 0 }
            let newHeading = Core.services.navEngine.computeCourseBetweeen(currentLocation: nextWP.location, and: currentLoc)
            retValue = Int(newHeading)
        }
        return retValue
    }
    
    private func getDirectionToTurn() -> String {
        var retValue: String = ""
        let plannedHeading: Double = Double(controllingWayPoint.headingFrom())
        let currentHeading: Double = gpsTracker.course
        let turn = NavTool.shared.getDirectionOfTurn(from: currentHeading, to: plannedHeading)
        retValue = "Turn \(turn.textOfTurn)"
        return retValue
    }
    
    func convertDegreeToXOffset() -> CGFloat {
        var retValue: CGFloat = 0
        
        let plannedHeading: Double = Double(controllingWayPoint.headingFrom())
        let currentHeading: Double = gpsTracker.course
        let turn = NavTool.shared.getDirectionOfTurn(from: currentHeading, to: plannedHeading)
        
        let offset: Double
        if turn == .left {
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
    HeadingNavigationView(controllingWayPoint:
                          Core.services.navEngine.loadWayPoints().first!,
                          nextWayPoint: nil,
                          altimeterRange: 1000,
                          plannedAltimeter: 5500,
                          altOffset: .constant(25),
                          speedRange: 100,
                          plannedSpeed: 110,
                          gpsIsActive: true,
                          navMode: NavigationMode.matchHeading)
}
