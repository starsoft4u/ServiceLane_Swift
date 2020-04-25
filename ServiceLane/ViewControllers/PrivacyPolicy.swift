//
//  PrivacyPolicy.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: CommonVC {
    var isPrivacy = true

    override func viewDidLoad() {
        title = isPrivacy ? "Privacy Policy" : "Terms and Conditions"

        if let url = URL(string: isPrivacy ? Helper.Url.privacy : Helper.Url.terms) {
            let webView = makeWebview()
            webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
        }
    }

    fileprivate func makeWebview() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(webView)

        return webView
    }
}
