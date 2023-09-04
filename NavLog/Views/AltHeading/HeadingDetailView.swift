//
//  HeadingDetailView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingDetailView: View {
    @State var manualAltitude: String = ""
    @Binding var aWayPoint: WayPoint
    @Binding var activeIndex: Int
    @State var waypointCount: Int
    @Binding var gpsIsRunning: Bool
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20, content: {
            Spacer()
            HStack {
                Button("Start") {
                    Core.services.gpsEngine.locationManger.startUpdatingLocation()
                    gpsIsRunning = true
                }
                .buttonStyle(.bordered)
                .disabled(gpsIsRunning)
                Button("Stop") {
                    Core.services.gpsEngine.locationManger.stopUpdatingLocation()
                    gpsIsRunning = false
                 }
                .disabled(!gpsIsRunning)
                .buttonStyle(.bordered)
                Button("Go Back") {
                    activeIndex -= 1
                }
                .disabled(activeIndex == 0)
                .buttonStyle(.bordered)
                Button("Skip") {
                    activeIndex  += 1
                }
                .disabled(activeIndex >= (waypointCount - 1))
                .buttonStyle(.bordered)
            }
            TextField("Enter Altitude", text: $manualAltitude)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            Button("Sync Altitude") {
                guard let newAlt = Int(manualAltitude) else { return }
                syncGPSAltitude(newAlt)
            }
            .buttonStyle(.bordered)
        })
        .padding()
    }
    
    func syncGPSAltitude(_ newAltitude: Int) {
        // Magic done here
        // Get delta between actual altitude and manually entered altitude
        // Store that delta to the WayPoint delta
    }
}

#Preview {
    HeadingDetailView( aWayPoint: .constant(Core.services.navEngine.loadWayPoints().first!),
                       activeIndex: .constant(0),
                       waypointCount: 0,
                       gpsIsRunning: .constant(true))
}
