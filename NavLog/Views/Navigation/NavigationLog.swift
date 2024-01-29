//
//  NavigationLog.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

// This is the view used to enter the navigation log waypoints. In a future release it could accept a pre-planned mission via exported file from FlyQ or ForeFlight.
// https://stackoverflow.com/questions/57024263/how-to-navigate-to-a-new-view-from-navigationbar-button-click-in-swiftui

import SwiftUI
import OSLog

struct NavigationLog: View {
    @State var showingImportView: Bool = false
    @State var showingAlert: Bool = false
    @Bindable var navEngine = Core.services.navEngine
    @State var isShowingDone: Bool = false
    
    var body: some View {
        NavLogSummaryView(wayPointList: $navEngine.activeWayPoints)
            .padding()
        Divider()
        List($navEngine.activeWayPoints) { waypoint in
            NavigationLink {
                WayPointDetailSwiftUIView(waypoint: waypoint)
            } label: {
                WaypointListItem(wayPoint: waypoint)
            }
        }
        .alert(isPresented: $isShowingDone, content: {
            Alert(title: Text("Save Complete"))
        })
        .navigationTitle("Nav Log Details")
        .toolbar{
            Button( action: { },
                    label: {
                NavigationLink {
                    ImportNavLogView()
                } label: {
                    Text("Import")
                }
            })
            Button("Refresh") {
                navEngine.refreshNavLog()
            }
            Button("Save") {
                navEngine.saveLogToDisk()
                isShowingDone = true
            }
        }
    }
}

#Preview {
    NavigationLog()
}
