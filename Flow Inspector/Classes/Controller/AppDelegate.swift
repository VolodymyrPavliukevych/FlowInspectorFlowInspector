//
//  AppDelegate.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/19/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if RELEASE
        trackEvent(.openApp)
        #endif
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

enum AnaliticEvent {
    case openApp
}

protocol AnaliticEventManager {
    func trackEvent(_ event: AnaliticEvent)
}


extension AppDelegate: AnaliticEventManager {
    func trackEvent(_ event: AnaliticEvent) {
        if !GoogleReporter.shared.isReady {
            GoogleReporter.shared.configure(withTrackerId: "UA-109209508-1")
        }
        switch event {
        case .openApp:
            trackOpeningApp()
        }
    }
    
    func trackOpeningApp() {
        DispatchQueue.main.async {
            var version = "unknown"
            var build = "unknown"
            
            if let foundVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                version = foundVersion
            }
            
            if let foundBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                build = foundBuild
            }
            let action = "OpenApplication-\(version)(\(build))"
            GoogleReporter.shared.event("FlowInspector", action: action)
        }
    }
}
