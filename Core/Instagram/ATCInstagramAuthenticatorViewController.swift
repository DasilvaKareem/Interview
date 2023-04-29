//
//  ATCInstagramAuthenticator.swift
//  DatingApp
//
//  Created by Florian Marcu on 3/6/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import WebKit
protocol ATCInstagramAuthenticatorViewControllerDelegate: class {
    func instagramAuthenticatorDidSucceed(_ accessToken: String) -> Void
    func instagramAuthenticatorDidFail() -> Void
}

class ATCInstagramAuthenticatorViewController: UIViewController {
    private let config: ATCInstagramConfig
    var webView: WKWebView!

    weak var delegate: ATCInstagramAuthenticatorViewControllerDelegate?

    init(config: ATCInstagramConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: "https://api.instagram.com/oauth/authorize/?client_id=\(config.clientID)&redirect_uri=\(config.redirectURL)&response_type=token") else { return }
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }
}

extension ATCInstagramAuthenticatorViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = webView.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        if url.contains("#access_token=") {
            if let range = url.range(of: "#access_token=") {
                let accessToken = url[range.upperBound...]
                decisionHandler(.cancel)
                self.delegate?.instagramAuthenticatorDidSucceed(String(accessToken))
            } else {
                decisionHandler(.cancel)
                self.delegate?.instagramAuthenticatorDidFail()
            }
            self.dismiss(animated: true, completion: nil)
            return
        }
        decisionHandler(.allow)
    }
}
