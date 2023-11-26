//
//  DGSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/24/23.
//

import SwiftUI

struct DGSwiftUIView: View {
    @ObservedObject var gpsTracker = Core.services.gpsEngine
    @StateObject var orientationTracker = Core.services.orientation
    @StateObject var viewModel = DGSwiftViewModel()
    @State var tracking: Bool = false
    @State private var baseLineMotion: MotionCapture?
    @State private var criticalAngle: Double = 0
    @State private var referenceAngle: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text(String(format:"%g", gpsTracker.course.rounded()) + " Degrees")
                    .font(.largeTitle)
                    .padding()
                
                if criticalAngle != 0 {
                    HStack{
                        Text("Critical Angle:")
                            .font(.caption)
                        Text(String(format:"%g", criticalAngle) + " Degrees")
                            .font(.footnote)
                    }
                }
                
                if referenceAngle != 0 {
                    HStack{
                        Text("Reference Angle:")
                            .font(.caption)
                        Text(String(format:"%g", referenceAngle) + " Degrees")
                            .font(.footnote)
                    }
                }
                
                DGLine()
                    .rotationEffect(.degrees(gpsTracker.course.rounded()))
                    .padding()
                if orientationTracker.tracker.isDeviceMotionAvailable {
                    Button {
                        // Start motion tracking
                        guard let opQueue = OperationQueue.current else { return }
                        orientationTracker.tracker.startDeviceMotionUpdates(to: opQueue) { deviceMotion, anError in
                            if let error = anError {
                                // Handle the error
                                print("There was an error with the motion tracker: \(error.localizedDescription)")
                            } else if let motion = deviceMotion {
                                baseLineMotion = orientationTracker.establishBaseline(with: motion, and: gpsTracker.currentLocation)
                                referenceAngle = baseLineMotion?.pitchDegrees ?? 0
                            }
                            
                            orientationTracker.tracker.stopDeviceMotionUpdates()
                            criticalAngle = 0
                        }
                        
                    } label: {
                        Text("Set Reference")
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    
                    if !tracking {
                        Button {
                            // Start motion tracking
                            guard let opQueue = OperationQueue.current else { return }
                            orientationTracker.clearData()
                            orientationTracker.tracker.startDeviceMotionUpdates(to: opQueue) { deviceMotion, anError in
                                if let error = anError {
                                    // Handle the error
                                    print("There was an error with the motion tracker: \(error.localizedDescription)")
                                } else if let motion = deviceMotion {
                                    // Capture the data...
                                    orientationTracker.handleObservedMotion(with: motion, and: gpsTracker.currentLocation)
                                }
                            }
                            tracking = true
                        } label: {
                            Text("Start Tracking")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            // Start motion tracking
                            orientationTracker.tracker.stopDeviceMotionUpdates()
                            tracking = false
                        } label: {
                            Text("Stop Tracking")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button {
//                        let results = orientationTracker.shipData()
//                        EmailController.shared.sendEmail(subject: "Test Resuls", body: results, to: "kcluff50@gmail.com")
                        
                        if let angle = orientationTracker.findCriticalAngle(orientationTracker.motionTrace, baseLine: baseLineMotion) {
                            criticalAngle = angle.pitchDegrees
                        }

                    } label: {
                        Text("Send Results")
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            }
            .navigationTitle("Heading")
        }
        .onAppear(perform: {
            gpsTracker.startTrackingLocation()
        })
        .onDisappear(perform: {
            gpsTracker.stopTrackingLocation()
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
                LinearGradient(gradient: Gradient(colors: [.yellow, .red]), startPoint: .top, endPoint: .bottom)
            )
        .stroke(.black, lineWidth: 2.0)
    }
}
