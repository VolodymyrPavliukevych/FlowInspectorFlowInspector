//
//  CodeViewController.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 6/26/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Cocoa

import WebKit

//MARK: - Input/Output protocols
protocol CodeViewOutput {
    func addGraphMarker(at filePath: String, lineNumber: Int, functionName: String)
    func markerTurnOn(value :Bool, at filePath: String, lineNumber: Int)
    func removeMarker(at filePath: String, lineNumber: Int)
}

protocol CodeViewInput {
    func load(content: Data, filePath: String)
    func addGraphMarker(at filePath: String, lineNumber: Int)
    func removeMarker(at filePath: String, lineNumber: Int)
}

//MARK: - Help JavaScript models
enum MonacoEditorMouseTargetType: Int {
    static let key = "type"
    
    case unknown = 0
    case textarea
    case gutterGlyphMargin
    case gutterLineNumbers
    case gutterLineDecorations
    case gutterViewZone
    case contentText
    case contentEmpty
    case contentViewZone
    case contentWidget
    case overviewRuler
    case scrollbar
    case overlayWidget
    case outsideEditor
}

struct MonacoEditorMarker {
    static let contextKey = "context"
    static let functionKey = "function"
    let context: String
    let function: String
    init?(_ body: [String : Any]) {
        guard let context = body[MonacoEditorMarker.contextKey] as? String else { return nil }
        guard let function = body[MonacoEditorMarker.functionKey] as? String else { return nil }
        self.function = function
        self.context = context
    }
}

struct MonacoEditorPoint {
    static let key = "point"
    static let lineNumberKey = "lineNumber"
    static let columnKey = "column"
    let column: Int
    let lineNumber: Int
    init?(_ body: [String : Any]) {
        guard let point = body[MonacoEditorPoint.key] as? [String : Int] else { return nil }
        self.init(point)
    }
    
    init?(_ point: [String : Int]) {
        guard let column = point[MonacoEditorPoint.columnKey] else { return nil }
        guard let lineNumber = point[MonacoEditorPoint.lineNumberKey] else { return nil }
        self.column =  column
        self.lineNumber = lineNumber
    }
}

//MARK: - WebKit helper class
class WebViewConfiguration: WKWebViewConfiguration {}

//MARK: - CodeViewController
class CodeViewController: NSViewController {
    var codeView: WKWebView?
    
    var output: CodeViewOutput?
    var filePath: String?
    var content: Data?
    
    override func viewDidLayout() {
        super.viewDidLayout()
        self.codeView?.evaluateJavaScript("window.editor.layout();") { (value: Any?, error: Error?) in }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadWebView() {
        let configuration = WebViewConfiguration()
        configuration.userContentController.add(self, name: "onMouseDown")
        
        codeView = WKWebView(frame: view.bounds, configuration: configuration)
        guard let codeView = self.codeView else { return }
        view.addSubview(codeView)
        codeView.translatesAutoresizingMaskIntoConstraints = false
        codeView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        codeView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        codeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        codeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        codeView.isHidden = false
        codeView.navigationDelegate = self
        codeView.uiDelegate = self
        
        guard let resourceURL = Bundle.main.resourceURL else { return }
        guard let monaco = Bundle(url: resourceURL.appendingPathComponent("monaco.bundle")) else { return }
        
        guard let path = monaco.path(forResource:"min/index", ofType: "html") else { return }
        let fileURL = URL(fileURLWithPath: path)
        codeView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
}

extension CodeViewController: CodeViewInput {
    func load(content: Data, filePath: String) {
        self.content = content
        self.filePath = filePath
        loadWebView()
    }

    func addGraphMarker(at filePath: String, lineNumber: Int) {
        self.codeView?.evaluateJavaScript("addMarker(\(lineNumber));") { (value: Any?, error: Error?) in }
    }
    
    func removeMarker(at filePath: String, lineNumber: Int) {}
}

extension CodeViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String : Any] else { return }
        guard let type = body[MonacoEditorMouseTargetType.key] as? Int else { return }
        guard let mouseTargetType = MonacoEditorMouseTargetType(rawValue: type) else { return }
        if (mouseTargetType == .gutterLineDecorations || mouseTargetType == .gutterLineNumbers), let filePath = self.filePath {
            if let point = MonacoEditorPoint(body), let marker = MonacoEditorMarker(body) {
                self.output?.addGraphMarker(at: filePath, lineNumber: point.lineNumber, functionName: marker.function)
            }
        }
    }
}

extension CodeViewController: WKUIDelegate { }

extension CodeViewController: WKNavigationDelegate {
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
