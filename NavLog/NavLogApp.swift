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


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Core.services.navEngine.buildTestNavLog()
        
        return true
    }
}
