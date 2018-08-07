//
//  ProjectViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/19/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

class ProjectViewController: NSViewController {
    
    @IBOutlet weak var navigatorAreaContainerView: NSView!
    @IBOutlet weak var codeContainerView: NSView!
    @IBOutlet weak var debugContainerView: NSView!
    @IBOutlet weak var graphContainer: NSView!
    
    
    var codeViewController: CodeViewController!
    var debugViewController: DebugViewController!
    var sourceTreeViewController: SourceTreeViewController!
    var graphViewController: GraphViewController!
    var navigatorAreaViewController: NavigatorAreaViewController!
    var documentInteraction: FIDocumentInteraction?
        
    internal func inject(documentInteraction: FIDocumentInteraction) {
        self.documentInteraction = documentInteraction
        //self.sourceTreeViewController.output = documentInteraction
        self.codeViewController.output = documentInteraction
        self.graphViewController.output = documentInteraction
        documentInteraction.injectCodeViewInput(codeViewController)
        documentInteraction.injectDebugViewInput(debugViewController)
        documentInteraction.injectGraphViewInput(graphViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        codeViewController = attachViewController(on: codeContainerView) as CodeViewController
        debugViewController = attachViewController(on: debugContainerView) as DebugViewController
        navigatorAreaViewController = attachViewController(on: navigatorAreaContainerView) as NavigatorAreaViewController
        graphViewController = attachViewController(on: graphContainer) as GraphViewController
    }

    override var representedObject: Any? {
        didSet {}
    }

    func attachViewController<T: NSViewController>(on container: NSView) -> T {
        let name = T.className()
        let attachedViewController = T(nibName: name, bundle: nil)
        self.addChild(attachedViewController)
        attachedViewController.view.frame = container.bounds
        container.addSubview(attachedViewController.view)

        attachedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        attachedViewController.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        attachedViewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        attachedViewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        attachedViewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true

        return attachedViewController
    }

}

