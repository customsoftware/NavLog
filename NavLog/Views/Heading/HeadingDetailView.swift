//
//  HeadingDetailView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingDetailView: View {
    @State var manualAltitude: String = ""
    @State var currentAltimeter: Double
    @Binding var altimeterOffset: Double
    @Binding var aWayPoint: WayPoint
    @Binding var activeIndex: Int
    @State var waypointCount: Int
    @Binding var gpsIsRunning: Bool
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            HStack {
                if !gpsIsRunning {
                    Button("Start") {
                        Core.services.gpsEngine.startTrackingLocation()
                        gpsIsRunning = true
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Stop") {
                        Core.services.gpsEngine.stopTrackingLocation()
                        gpsIsRunning = false
                        activeIndex = 0
                    }
                    .buttonStyle(.bordered)
                }
                
                if gpsIsRunning {
                    Button("<<") {
                        activeIndex -= 1
                    }
                    .disabled(activeIndex == 0)
                    .buttonStyle(.bordered)
                    Button(">>") {
                        activeIndex  += 1
                    }
                    .disabled(activeIndex >= (waypointCount - 1))
                    .buttonStyle(.bordered)
                }
            }
            
            TextField("Enter Altitude", text: $manualAltitude)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            Button("Sync Altitude") {
                guard let newAlt = Double(manualAltitude) else { return }
                syncGPSAltitude(newAlt)
            }
            .buttonStyle(.bordered)
        })
        .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        Spacer()
        
    }
    
    func syncGPSAltitude(_ newAltitude: Double) {
        // Get delta between actual altitude and manually entered altitude
        let delta = currentAltimeter - newAltitude
        // Store that delta to the WayPoint delta
        altimeterOffset = delta
    }
}

#Preview {
    HeadingDetailView( currentAltimeter: 5000,
                       altimeterOffset: .constant(0),
                       aWayPoint: .constant(Core.services.navEngine.loadWayPoints().first!),
                       activeIndex: .constant(0),
                       waypointCount: 0,
                       gpsIsRunning: .constant(true))
}
