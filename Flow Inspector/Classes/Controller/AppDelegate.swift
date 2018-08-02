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
        DispatchQueue.main.async {
            GoogleReporter.shared.configure(withTrackerId: "UA-109209508-1")
            GoogleReporter.shared.event("FlowInspector", action: "OpenApp")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
