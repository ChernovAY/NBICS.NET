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
    private var isFirst  = true
    
    var ConfigurationWebView: WKWebView!
    
    var configurationURL:String?
    
    override func loadView() {
        super.loadView()
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
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if VSMAPI.VSMChatsCommunication.nailIFirstOpenOfConfigurationBliad{
            VSMAPI.VSMChatsCommunication.nailIFirstOpenOfConfigurationBliad = false
            self.viewDidLoad()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewURL = URL(string: (VSMAPI.VSMChatsCommunication.nailIFirstOpenOfConfigurationBliad ? VSMAPI.Settings.caddress : configurationURL!))
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        let cookieHeaderField = ["Set-Cookie":"Lang=ru, VSM_Alias=\(VSMAPI.Settings.alias), VSM_Email=\(VSMAPI.Settings.user), VSM_PasswordHash=\(VSMAPI.Settings.hash),  ColorCheme=82cdecd6-49c6-4c55-985d-615099564153"]
        
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: URL(string: VSMAPI.Settings.caddress)!)
        for (cookie) in cookies {
            ConfigurationWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        var request = URLRequest(url: viewURL!)

        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }
        self.ConfigurationWebView.load(request)

    }
}
