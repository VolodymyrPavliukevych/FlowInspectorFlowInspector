//
//  DebugViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/26/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

protocol DebugViewInput {
    func insertOutput(_ output: String)
    func insertError(_ error: String)
}

protocol DebugViewOutput { }

class DebugViewController: NSViewController {
    @IBOutlet weak var debugTextView: NSTextView!

    @IBAction func clear(sender: Any?) {
        self.debugTextView.string = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func insert(string: String, color: NSColor = NSColor.black) {
        DispatchQueue.main.async {
            guard let storage = self.debugTextView.textStorage else { return }
            let attr: [NSAttributedString.Key : Any] = [.foregroundColor : color,
                                                       .font: NSFont(name: "Monaco", size: 14.0) ?? NSFont.systemFont(ofSize: 14.0)]
            let attributedString = NSAttributedString(string: string, attributes: attr)
            storage.append(attributedString)
            self.debugTextView.scrollRangeToVisible(NSRange(location: self.debugTextView.string.count, length: 0))
        }
    }
}

extension DebugViewController: DebugViewInput{
    func insertOutput(_ output: String) {
        insert(string: output)
    }
    
    func insertError(_ error: String) {
        insert(string: error, color: NSColor.red)
    }
}
