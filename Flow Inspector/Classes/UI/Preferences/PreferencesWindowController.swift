//
//  PreferencesWindowController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 7/15/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

struct Preferences {
    static let separator = ","
    var argument: [String] = [String]()
    var environment: [String] = [String]()
    
    func argumentAsString() -> String {
        return argument.joined(separator: Preferences.separator)
    }

    func environmentAsString() -> String {
        return environment.joined(separator: Preferences.separator)
    }
    
    init(argument argumentString: String, environment environmentString: String) {
        self.argument = argumentString.split(separator: ",").map { String($0) }
        environment = environmentString.split(separator: ",").map { String($0) }
    }
    
    init() {
    }
}

protocol PreferencesInput {
    
}

protocol PreferencesOutput {
    func update(_ preferences: Preferences)
}

class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var argumentTextField: NSTextField!
    @IBOutlet weak var environmentTextField: NSTextField!
    
    var preferences: Preferences?
    var output: PreferencesOutput?
    var windowInteraction: WindowControllerInteraction?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if let preferences = preferences {
            self.argumentTextField.stringValue = preferences.argumentAsString()
            self.environmentTextField.stringValue = preferences.environmentAsString()
        }
    }

    init(_ preferences: Preferences, output: PreferencesOutput, windowInteraction: WindowControllerInteraction) {
        super.init(window: nil)
        let nibName = NSNib.Name("PreferencesWindowController")
        Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: nil)
        self.preferences = preferences
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
        output?.update(Preferences(argument: argumentTextField.stringValue, environment: environmentTextField.stringValue))
        self.dismissController(sender)
        if let window = self.window {
            windowInteraction?.endSheet(window: window)
        }
    }
}
