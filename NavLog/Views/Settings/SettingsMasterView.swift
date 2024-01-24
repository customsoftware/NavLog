//
//  SettingsMasterView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import SwiftUI

struct SettingsMasterView: View {
    @State private var isShowingDetail = false

    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    AircraftParametersView()
                } label: {
                    Text("W&B Key Properties")
                }
                
                NavigationLink {
                    AircraftStatsView()
                } label: {
                    // This is for landing performance
                    Text("Landing Performance")
                }
                
                NavigationLink {
                    PerformanceSwiftUIView()
                } label: {
                    // This is for take off
                    Text("Take off Performance")
                }
                
                NavigationLink {
                    AircraftPerformanceSwiftUIView()
                } label: {
                    Text("Aircraft")
                }
                
                NavigationLink {
                    AppMetricsSwiftUIView()
                } label: {
                    Text("Metrics")
                }
                
                NavigationLink {
                    LegalSwiftUIView()
                } label: {
                    Text("Legal")
                }
              
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsMasterView()
}



