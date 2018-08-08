//
//  TabButton.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/8/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa
import AppKit

enum TabButtonState {
    case off
    case on
}

class TabButton: NSButton {
    
    @IBInspectable var aTintColor: NSColor? {
        didSet {
            tintColor = aTintColor
        }
    }

    @IBInspectable var aSelectedTintColor: NSColor? {
        didSet {
            selectedTintColor = aSelectedTintColor
        }
    }
    
    @IBInspectable var aBackgroundColor: NSColor? {
        didSet {
            backgroundColor = aBackgroundColor
        }
    }
    
    var tintColor: NSColor?
    var selectedTintColor: NSColor?
    var backgroundColor: NSColor?
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard let image = image, let tintColor = tintColor, let selectedTintColor = selectedTintColor else {
            super.draw(dirtyRect)
            return
        }

        if let backgroundColor = backgroundColor {
            backgroundColor.setFill()
            dirtyRect.fill()
        }
        
        let color = self.state == .on ? selectedTintColor : tintColor
        
        let size = image.size
        
        let originX =  (dirtyRect.size.width - size.width) / 2
        let originY =  (dirtyRect.size.height - size.height) / 2
        image.lockFocus()
        color.set()
        let drawRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        drawRect.fill(using: .sourceAtop)
        image.unlockFocus()
        image.draw(in: NSRect(x: CGFloat(Int(originX)), y: CGFloat(Int(originY)), width: size.width, height: size.height))
    }
    
}
