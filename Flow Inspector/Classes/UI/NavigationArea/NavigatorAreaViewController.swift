//
//  NavigatorAreaViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/7/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

protocol TabIdentifiable: class {
    var tabIdentifier: String { get }
}

extension TabIdentifiable {
    public var tabIdentifier: String {
        return String(describing: self)
    }
}

protocol TabInteractable {
    func openTab(identifier: String)
}

class NavigatorAreaViewController: NSViewController {
    @IBOutlet weak var toolBarView: NSView!
    @IBOutlet weak var contentContainer: NSView!

    @IBOutlet weak var sourceTreeButton: NSButton!
    @IBOutlet weak var tensorInfoButton: NSButton!
    @IBOutlet weak var breakpointButton: NSButton!
    
    
    @IBAction func toolBarDidReceiveAction(_ sender: NSButton) {
        sourceTreeButton.state = .off
        tensorInfoButton.state = .off
        breakpointButton.state = .off
        
        sender.state = .on
        if let tabIdentifier = sender.identifier {
            infoAreaViewController.openTab(identifier: tabIdentifier.rawValue)
        }
    }
    
    private (set) var infoAreaViewController: InfoAreaViewController!

    public var sourceTreeViewController: SourceTreeViewController {
        return infoAreaViewController.sourceTreeViewController
    }
    public var tensorInfoViewController: TensorInfoViewController {
        return infoAreaViewController.tensorInfoViewController
    }
    public var breakpointViewController: BreakpointViewController {
        return infoAreaViewController.breakpointViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoAreaViewController = InfoAreaViewController(nibName: "InfoAreaViewController", bundle: nil)
        self.addChild(infoAreaViewController)
        infoAreaViewController.view.frame = contentContainer.bounds
        contentContainer.addSubview(infoAreaViewController.view)
        
        infoAreaViewController.view.translatesAutoresizingMaskIntoConstraints = false
        infoAreaViewController.view.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true
        infoAreaViewController.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true
        infoAreaViewController.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor).isActive = true
        infoAreaViewController.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor).isActive = true

    }
}
