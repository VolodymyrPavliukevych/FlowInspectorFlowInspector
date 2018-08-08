//
//  InfoAreaViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/7/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

class InfoAreaViewController: NSTabViewController {
    private (set) var sourceTreeViewController: SourceTreeViewController!
    private (set) var tensorInfoViewController: TensorInfoViewController!
    private (set) var breakpointViewController: BreakpointViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabStyle = .unspecified
        self.transitionOptions = .allowUserInteraction
        sourceTreeViewController = addTab()
        tensorInfoViewController = addTab()
        breakpointViewController = addTab()
    }
    
    private func addTab<T: NSViewController>(identifier: String? = nil, label: String? = nil, imageName: String? = nil) -> T {
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

extension InfoAreaViewController: TabInteractable {
    func openTab(identifier: String) {
        let fitted = self.tabViewItems.filter { (item) -> Bool in
            if let itemIdentifier = item.identifier as? String {
                return itemIdentifier == identifier
            }
            return false
        }
        self.tabView.selectTabViewItem(fitted.first)
    }
}
