//
//  DGSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/24/23.
//

import SwiftUI

struct DGSwiftUIView: View {
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    @StateObject var viewModel = DGSwiftViewModel()
    @State var gpsIsRunning: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text(String(format:"%g", gpsTracker.course.rounded()) + " Degrees")
                    .font(.largeTitle)
                    .padding()
                
                DGLine()
                    .rotationEffect(.degrees(gpsTracker.course.rounded()))
                
                Spacer()
            }
            .navigationTitle("Heading")
        }
        .onAppear(perform: {
            Core.services.gpsEngine.startTrackingLocation()
        })
        .onDisappear(perform: {
            Core.services.gpsEngine.stopTrackingLocation()
        })
    }
}

#Preview {
    DGSwiftUIView()
}


class DGSwiftViewModel: ObservableObject {
    @Published var currentHeading: Double = (Core.services.gpsEngine.currentLocation?.course ?? 0).rounded()
    
    @Published var rotation: Double = 0
}

struct DGLine: View {
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 200, y: 100))
            path.addLine(to: CGPoint(x: 200, y: 300))
            path.addLine(to: CGPoint(x: 210, y: 300))
            path.addLine(to: CGPoint(x: 210, y: 100))
        }
        .fill(
                LinearGradient(gradient: Gradient(colors: [.blue, .red, .black]), startPoint: .top, endPoint: .bottom)
            )
    }
}
