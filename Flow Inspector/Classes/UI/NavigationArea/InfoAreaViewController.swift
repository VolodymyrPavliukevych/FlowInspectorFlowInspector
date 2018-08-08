//
//  InfoAreaViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/7/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

class InfoAreaViewController: NSTabViewController {
    var sourceTreeViewController: SourceTreeViewController!
    var tensorInfoViewController: TensorInfoViewController!
    var breakpointViewController: BreakpointViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabStyle = .unspecified
        sourceTreeViewController = addTab()
        tensorInfoViewController = addTab()
        breakpointViewController = addTab()
    }
    
    func addTab<T: NSViewController>(identifier: String? = nil, label: String? = nil, imageName: String? = nil) -> T {
        let name = T.className()
        let viewController = T(nibName: name, bundle: nil)
        
        let tabViewItem = NSTabViewItem(viewController: viewController)
        if let identifier = identifier {
            tabViewItem.identifier = identifier
        } else {
            tabViewItem.identifier = name
        }
        
        if let label = label {
            tabViewItem.label = label
        }
        if let imageName = imageName {
            tabViewItem.image = NSImage(named: imageName)
        }
        
        self.addTabViewItem(tabViewItem)
        return viewController
    }

}
