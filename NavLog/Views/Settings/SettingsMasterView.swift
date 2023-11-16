//
//  SettingsMasterView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import SwiftUI

struct SettingsMasterView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Aircraft")
                NavigationLink {
                    AircraftParametersView()
                } label: {
                    Text("W&B Key Properties")
                }
                Text("Performance")
                Text("Legal")
                
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsMasterView()
}
