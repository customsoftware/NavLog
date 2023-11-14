//
//  AppStartView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct AppStartView: View {
//    @State private var wayPointList: [WayPoint] = Core.services.navEngine.activeWayPoints.sorted { w1, w2 in
//        w1.sequence < w2.sequence
//    }
    @State private var altimeterOffset: Double = 4500
    @State private var currentAltimeter: Double = 4500
    
    var body: some View {
        TabView {
            ZStack {
                Image("LaunchImage", bundle: nil)
                    .aspectRatio(contentMode: .fill)
                Text("Welcome to Navigator Assistant")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 250, height: 150, alignment: .topLeading)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .onAppear {
                print("Started timer")
                UIApplication.shared.isIdleTimerDisabled = false
            }
            AircraftPerformanceView()
                .tabItem {
                    Label("W&B", systemImage: "scalemass.fill")
                }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }            
            AircraftParametersView()
                .tabItem {
                    Label("Aircraft", systemImage: "airplane.circle")
                }                
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            NavigationLog()
                .tabItem {
                    Label("Log", systemImage: "road.lanes")
                }
                .onAppear {
                    print("Started timer")
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            
            
            //            HeadingMasterView(wayPointList: $wayPointList, altimeterOffset: $altimeterOffset)
            //                .tabItem {
            //                    Label("Map", systemImage: "map.circle")
            //                        .foregroundColor(.black)
            //                }
            //                .onAppear {
            //                    print("Shut off timer")
            //                    UIApplication.shared.isIdleTimerDisabled = true
            //                }
        }
        .onAppear(perform: {
            
//            Core.services.navEngine.buildTestNavLog()
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0, execute: {
//                self.wayPointList = Core.services.navEngine.loadWayPoints().sorted(by: { w1, w2 in
//                    w1.sequence < w2.sequence
//                })
//                self.fleshOutWayPointList()
//            })
            
            switch Core.services.gpsEngine.locationManger.authorizationStatus {
            case .notDetermined:
                Core.services.gpsEngine.locationManger.requestAlwaysAuthorization()
            case .restricted, .denied:
                print("You can't use the location services")
            case .authorizedAlways:
                print("You have always authorization")
                Core.services.gpsEngine.locationManger.stopUpdatingLocation()
            case .authorizedWhenInUse:
                print("You have when in use authorization")
                Core.services.gpsEngine.locationManger.stopUpdatingLocation()
            @unknown default:
                fatalError("New authorization status encountered")
            }
        })
    }
}

#Preview {
    AppStartView()
}
