//
//  ProjectWindow.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/25/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

class ProjectWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask,
                  backing backingStoreType: NSWindow.BackingStoreType,
                  defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.titleVisibility = .hidden
    }
}
