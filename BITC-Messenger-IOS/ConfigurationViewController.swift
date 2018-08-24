//
//  ConfigurationViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 15.08.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit
import WebKit

class ConfigurationViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var ConfigurationWebView: WKWebView!
    
    var configurationURL:String?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let js: String = "var style = document.createElement('style'); style.innerHTML = '.VSMCore-left-panel-tabs-buttons-container-div{ display: none; } .VSM-main-content{ width: 100% }'; document.head.appendChild(style);"
        let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        webConfiguration.userContentController = contentController
        
        ConfigurationWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        ConfigurationWebView.uiDelegate = self
        ConfigurationWebView.navigationDelegate = self
        view = ConfigurationWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let viewURL = URL(string: configurationURL!)
        let viewURL = URL(string: configurationURL)
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "VSM_Email=" + VSMAPI.Settings.user + ", VSM_PasswordHash=" + VSMAPI.Settings.hash]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: viewURL!)
        jar.setCookies(cookies, for: viewURL, mainDocumentURL: viewURL)
        let request = URLRequest(url: viewURL!)
        ConfigurationWebView.load(request)
        */
    }
}
