// Copyright 2018 Brightec Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import WebKit

public protocol ThreeDSecureViewDelegate: class {
    func threeDSecure(view: ThreeDSecureView, md: String, paRes: String)
    func threeDSecure(view: ThreeDSecureView, error: Error)
}

public class ThreeDSecureView: UIView {

    /// The webView that loads the 3DSecure URL
    private var webView: WKWebView!

    /// Delegate for passing back the 3DSecure result
    public weak var delegate: ThreeDSecureViewDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// Initialises the webView and adds it to the view hierarchy
    private func commonInit() {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self

        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        self.webView = webView
    }

    /// Starts the 3DSecure process by loading the provided URL with the md/paRes parameters
    ///
    /// - Parameter config: The config required to start the 3DSecure process
    public func start3DSecure(config: ThreeDSecureConfig) {
        var charSet = CharacterSet.urlHostAllowed
        charSet.remove("+")
        charSet.remove("&")

        guard let mdEncoded = config.md.addingPercentEncoding(withAllowedCharacters: charSet),
            let urlEncoded = "https://www.google.com".addingPercentEncoding(withAllowedCharacters: charSet),
            let paReqEncoded = config.paReq.addingPercentEncoding(withAllowedCharacters: charSet) else {
                return
        }

        var request = URLRequest(url: config.cardUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "MD=\(mdEncoded)&TermUrl=\(urlEncoded)&PaReq=\(paReqEncoded)".data(using: .utf8)
        webView.load(request)
    }

}

// MARK: - WKNavigationDelegate
extension ThreeDSecureView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let host = webView.url?.host, host == "www.google.com" {
            let javaScript = "function getHTML() { return document.getElementsByTagName('html')[0].innerHTML; } getHTML();"
            webView.evaluateJavaScript(javaScript) { (result, error) in
                if let error = error {
                    self.delegate?.threeDSecure(view: self, error: error)
                } else if let result = result as? String {
                    guard let md = self.getMd(html: result), let mdValue = self.getValue(input: md),
                        let paRes = self.getPaRes(html: result), let paResValue = self.getValue(input: paRes) else {
                            return
                    }
                    self.delegate?.threeDSecure(view: self, md: mdValue, paRes: paResValue)
                }
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Ignore errors relating to us cancelling the request to the callback URL
        if let errorUrl = (error as NSError).userInfo["NSErrorFailingURLKey"] as? URL,
            errorUrl.host == "www.google.com" {
            return
        }
        delegate?.threeDSecure(view: self, error: error)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.threeDSecure(view: self, error: error)
    }

}

// MARK: - Helpers
extension ThreeDSecureView {

    /// Gets the HTML input tag with a name of MD from the provided HTML
    ///
    /// - Parameter html: The HTML to search
    /// - Returns: The input tag, or nil if not found
    private func getMd(html: String) -> String? {
        guard let regEx = try? NSRegularExpression(pattern: ".*?(<input[^<>]* name=\"MD\"[^<>]*>).*?") else {
            return nil
        }

        return getFirstSubGroup(string: html, regEx: regEx)
    }

    /// Gets the HTML input tag with a name of PaRes from the provided HTML
    ///
    /// - Parameter html: The HTML to search
    /// - Returns: The input tag, or nil if not found
    private func getPaRes(html: String) -> String? {
        guard let regEx = try? NSRegularExpression(pattern: ".*?(<input[^<>]* name=\"PaRes\"[^<>]*>).*?") else {
            return nil
        }

        return getFirstSubGroup(string: html, regEx: regEx)
    }

    /// Gets the value attribute from the provided input tag
    ///
    /// - Parameter input: The input tag to search
    /// - Returns: The found value, or nil
    private func getValue(input: String) -> String? {
        guard let regEx = try? NSRegularExpression(pattern: ".*? value=\"(.*?)\"") else {
            return nil
        }

        return getFirstSubGroup(string: input, regEx: regEx)
    }

    /// Gets the first sub group from the provided string using the provided regular expression
    ///
    /// - Parameters:
    ///   - string: The string to search
    ///   - regEx: The regular expression to evaluate
    /// - Returns: The first sub group, or nil
    private func getFirstSubGroup(string: String, regEx: NSRegularExpression) -> String? {
        guard let match = regEx.firstMatch(in: string, options: [], range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }

        let matchSubGroup = match.range(at: 1)
        guard let range = Range(matchSubGroup, in: string) else {
            return nil
        }

        return String(string[range])
    }

}
