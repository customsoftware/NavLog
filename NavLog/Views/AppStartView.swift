//
//  AppStartView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct AppStartView: View {
    var body: some View {
        TabView {
            ZStack {
                Image("LaunchImage", bundle: nil)
                Text("Welcome to Navigator Assistant")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 250, height: 150, alignment: .topLeading)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            ContentView()
                .tabItem {
                    Label("Map", systemImage: "map.circle")
                        .foregroundColor(.black)
                }
            
            MissionLog()
                .tabItem {
                    Label("Mission", systemImage: "airplane.circle")
                }
        }
        .onAppear(perform: {
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
