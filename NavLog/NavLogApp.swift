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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppStartView()
        }
    }
}


// Inspired by: https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-an-appdelegate-to-a-swiftui-app
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Start loading here...")
        do {
            let wayPoints = try Core.services.navEngine.readWaypointsFromDisk()
            if let wPlist = wayPoints {
                Core.services.navEngine.activeWayPoints = wPlist
            }
        } catch let error {
            /// Here is where we load the data into the app...
            Core.services.navEngine.buildTestNavLog()
        }
        return true
    }
}
