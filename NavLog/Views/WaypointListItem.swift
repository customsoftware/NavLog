//
//  WaypointListItem.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

//  This is the waypoint item used in the Mission Log and Navigation Log. It is read-only in the mission log.

import SwiftUI

struct WaypointListItem: View {
    var body: some View {
        HStack {
            VStack(content: {
                Text("Name")
                Text("Loc")
            })
            VStack(content: {
                Text("Alt")
                Text("Wind")
            })
            VStack(content: {
                Text("Course")
                Text("Heading")
            })
            Text("EDW")
            Text("ETW")
            Text("EFB")
        }
    }
}


#Preview {
    WaypointListItem()
}
