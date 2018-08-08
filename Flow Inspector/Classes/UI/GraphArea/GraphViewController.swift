//
//  GraphViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 7/4/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa
import WebKit

protocol GraphViewInput {
    // JSON serialized in data.
    func shouwGraph(graph: Data, for kind: GraphModel.Kind)
    
}

protocol GraphViewOutput {
    func saveGraph(kind: GraphModel.Kind)
    func exportGraphAsEvent(kind: GraphModel.Kind)
    func launchGraphExecution(kind: GraphModel.Kind)
    func launchTimeProfiler(kind: GraphModel.Kind)
}

class GraphViewController: NSViewController {
    @IBOutlet weak var toolBarView: NSView!
    @IBOutlet weak var saveAsEventButton: NSButton!
    @IBOutlet weak var launchButton: NSButton!
    @IBOutlet weak var timeProfilerButton: NSButton!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var graphContainerView: NSView!
    
    
    var codeView: WKWebView?
    var content: Data?
    var graphKind = GraphModel.Kind.main
    
    @IBAction func save(_ sender: Any?) {
        output?.saveGraph(kind: graphKind)
    }
    
    @IBAction func exportAsEvent(_ sender: Any?) {
        output?.exportGraphAsEvent(kind: graphKind)
    }
    
    @IBAction func launch(_ sender: Any?) {
        output?.launchGraphExecution(kind: graphKind)
    }
    
    @IBAction func launchTimeProfiler(_ sender: Any?) {
        output?.launchTimeProfiler(kind: graphKind)
    }
    
    var output: GraphViewOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadWebView() {
        let configuration = WebViewConfiguration()
        configuration.userContentController.add(self, name: "onMouseDown")
        
        codeView = WKWebView(frame: graphContainerView.bounds, configuration: configuration)
        guard let codeView = self.codeView else { return }
        graphContainerView.addSubview(codeView)
        codeView.translatesAutoresizingMaskIntoConstraints = false
        codeView.topAnchor.constraint(equalTo: graphContainerView.topAnchor).isActive = true
        codeView.bottomAnchor.constraint(equalTo: graphContainerView.bottomAnchor).isActive = true
        codeView.leadingAnchor.constraint(equalTo: graphContainerView.leadingAnchor).isActive = true
        codeView.trailingAnchor.constraint(equalTo: graphContainerView.trailingAnchor).isActive = true
        
        codeView.isHidden = false
        codeView.navigationDelegate = self
        codeView.uiDelegate = self
        
        guard let resourceURL = Bundle.main.resourceURL else { return }
        guard let monaco = Bundle(url: resourceURL.appendingPathComponent("graph.bundle")) else { return }
        
        guard let path = monaco.path(forResource:"graphSheet", ofType: "html") else { return }
        let fileURL = URL(fileURLWithPath: path)
        codeView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
    
}

extension GraphViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String : Any] else { return }
        print(body)
    }

}

extension GraphViewController: GraphViewInput {
    func shouwGraph(graph: Data, for kind: GraphModel.Kind) {
        DispatchQueue.main.async {
            self.toolBarView.isHidden = false
            self.graphContainerView.isHidden = false
            self.content = graph
            self.graphKind = kind
            self.loadWebView()
            self.launchButton.isEnabled = kind == .main
        }
    }
}

extension GraphViewController: WKUIDelegate { }

extension GraphViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let content = self.content {
            let parameter = content.base64EncodedString()
            webView.evaluateJavaScript("loadContent('\(parameter)');") { (value: Any?, error: Error?) in
                print(value ?? "Done.")
            }
        }
    }
    
}
