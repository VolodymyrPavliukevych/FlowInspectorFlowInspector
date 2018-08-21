//
//  ProjectWindowController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/25/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

protocol WindowControllerInteraction {
    func endSheet(window: NSWindow)
}

protocol ProjectWindowControllerInput {
    func openFile(format: [String], callback: @escaping (_ filePath: URL) -> Void)
    func openFolder(format: [String], callback: @escaping (_ filePath: URL) -> Void)
    func progressIndicator(startAnimation: Bool)
    func progressText(_ string: String)
    func progressLabel(hidden: Bool)
    func save(_ fileName: String, allowedFileTypes: [String], message: String, callback: @escaping (_ filePath: URL) -> Void)
    
    func showPreferences(_ preferences: Preferences, output: PreferencesOutput)
    
    func extractFunctionGraphAction(available: Bool)
    func extractMainGraphAction(available: Bool)
}

protocol ProjectWindowControllerOutput {
    func extractMainGraph()
    func extractFunctionGraph()
    func shouldOpenPreferences()
    func launchProfiller()
}

class ProjectWindowController: NSWindowController {
    @IBOutlet weak var toolBarView: NSToolbar!
    @IBOutlet weak var extractMainGraphButton: NSButton!
    @IBOutlet weak var extractFunctionGraphButton: NSButton!
    @IBOutlet weak var showPreferencesButton: NSButton!
    @IBOutlet weak var profillerButton: NSButton!
    @IBOutlet weak var accessoryView: NSView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressTextField: NSTextField!
    
    var preferencesWindowController: PreferencesWindowController?
    var fiDocument: FIDocument?
    var output: ProjectWindowControllerOutput?
    
    internal func inject(document: FIDocument) {
        fiDocument = document
        guard let projectViewController = contentViewController as? ProjectViewController else { return }
        projectViewController.inject(documentInteraction: document)
        output = fiDocument
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    override func windowDidLoad() {
        super.windowDidLoad()
        
        guard let projectWindow = self.window as? ProjectWindow else { return }
        // Create a title bar accessory view controller and attach
        // the view created in Interface Builder
        let titlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        titlebarAccessoryViewController.view = accessoryView
        
        // Set the location and attach the accessory view to the
        // titlebar to be displayed
        titlebarAccessoryViewController.layoutAttribute = .left
        projectWindow.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        
    }
    
    
    @IBAction func extractMainGraph(_ sender: Any) {
        self.output?.extractMainGraph()
    }
    
    @IBAction func extractFunctionGraph(_ sender: Any) {
        self.output?.extractFunctionGraph()
    }
    
    
    @IBAction func showPreferences(_ sender: Any) {
        self.output?.shouldOpenPreferences()
    }
    
    @IBAction func launchProfiller(_ sender: Any) {
        self.output?.launchProfiller()
    }
}

extension ProjectWindowController: ProjectWindowControllerInput {
    func extractMainGraphAction(available: Bool) {
        self.extractMainGraphButton.isEnabled = available
    }
    
    func extractFunctionGraphAction(available: Bool) {
        self.extractFunctionGraphButton.isEnabled = available
    }
    
    func showPreferences(_ preferences: Preferences, output: PreferencesOutput) {
        
        if self.preferencesWindowController == nil {
            self.preferencesWindowController = PreferencesWindowController(preferences, output: output, windowInteraction: self)
        }
        
        guard let window = self.window else { return }
        guard let preferencesWindow = preferencesWindowController?.window else { return }
        window.beginSheet(preferencesWindow, completionHandler: nil)
    }
    
    func progressIndicator(startAnimation: Bool) {
        if startAnimation {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }
    
    func progressText(_ string: String) {
        progressLabel(hidden: false)
        progressTextField.stringValue = string
    }
    
    func progressLabel(hidden: Bool) {
        progressTextField.isHidden = hidden
    }
    
    func openFile(format: [String], callback: @escaping (_ filePath: URL) -> Void) {
        open(format: format, acceptFolder: false, callback: callback)
    }
    
    func openFolder(format: [String], callback: @escaping (_ filePath: URL) -> Void) {
        open(format: format, acceptFolder: true, callback: callback)
    }

    func open(format: [String], acceptFolder: Bool, callback: @escaping (_ filePath: URL) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a \(format) file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        openPanel.canChooseDirectories = acceptFolder
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = format
        openPanel.worksWhenModal = true
        openPanel.resolvesAliases = true
        
        guard let window = self.window else { return }
        
        openPanel.beginSheetModal(for: window) { (response) in
            guard let url = openPanel.url else  { return }
            callback(url)
        }
    }
    
    func save(_ fileName: String, allowedFileTypes: [String], message: String, callback: @escaping (_ filePath: URL) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = allowedFileTypes
        savePanel.nameFieldStringValue = fileName
        savePanel.allowsOtherFileTypes = false
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.message = message
        savePanel.showsHiddenFiles  = true
        
        guard let window = self.window else { return }

        savePanel.beginSheetModal(for: window) { (response) in
            guard let url = savePanel.url else  { return }
            callback(url)
        }
    }
}

extension ProjectWindowController: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        guard let contentView = window?.contentView else { return }
        var frame = accessoryView.frame
        frame.size.width = contentView.bounds.width - 100
        accessoryView.frame = frame
    }
}

extension ProjectWindowController: WindowControllerInteraction {
    func endSheet(window: NSWindow) {
        self.window?.endSheet(window)
    }
}
