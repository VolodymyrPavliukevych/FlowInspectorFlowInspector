//
//  LaunchSettingsWindowController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

protocol LaunchSettingsInput {
}

protocol LaunchSettingsOutput {
}

class LaunchSettingsWindowController: NSWindowController {
    var output: LaunchSettingsOutput?
    var windowInteraction: WindowControllerInteraction?

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    init(_ output: LaunchSettingsOutput, windowInteraction: WindowControllerInteraction) {
        super.init(window: nil)
        let nibName = NSNib.Name("PreferencesWindowController")
        Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: nil)
        self.output = output
        self.windowInteraction = windowInteraction
        self.windowDidLoad()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(window: NSWindow!) {
        super.init(window: window )
    }
    
    @IBAction func closeAction(_ sender: Any?) {
        print("Close")
        self.dismissController(sender)
        if let window = self.window {
            windowInteraction?.endSheet(window: window)
        }
    }
}
