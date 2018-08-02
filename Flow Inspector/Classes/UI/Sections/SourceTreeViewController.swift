//
//  SourceTreeViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/26/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

protocol SourceTreeViewInput {}
protocol SourceTreeViewOutput {
    func selectSourceFile(callback: @escaping (_ fileName: String) -> Void)
    func selectProgramFile(callback: @escaping (_ fileName: String) -> Void)
    func selectDSYMFile(callback: @escaping (_ fileName: String) -> Void)
}


class SourceTreeViewController: NSViewController {

    @IBOutlet weak var sourceFileButton: NSButton!
    @IBOutlet weak var binFileButton: NSButton!
    @IBOutlet weak var dSYMFileButton: NSButton!
    
    var output: SourceTreeViewOutput?
    
    @IBAction func selectSourceFile(_ sender: NSButton) {
        output?.selectSourceFile(callback: { (title) in
            sender.title = title
        })
    }
    
    @IBAction func selectBinFile(_ sender: NSButton) {
        output?.selectProgramFile(callback: { (title) in
            sender.title = title
        })
    }
    
    @IBAction func selectDSYMFile(_ sender: NSButton) {
        output?.selectDSYMFile(callback: { (title) in
            sender.title = title
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
