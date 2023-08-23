//
//  NavLogApp.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/23/23.
//

import SwiftUI
import SwiftData

@main
struct NavLogApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
