//
//  NavigatorAreaViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/7/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

class NavigatorAreaViewController: NSViewController {
    @IBOutlet weak var toolBarView: NSView!
    @IBOutlet weak var contentContainer: NSView!
    var infoAreaViewController: InfoAreaViewController!

    
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
