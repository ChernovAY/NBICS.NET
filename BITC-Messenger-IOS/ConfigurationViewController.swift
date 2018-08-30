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


        let viewURL = URL(string: configurationURL!)
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie":"Lang=ru, ColorCheme=82cdecd6-49c6-4c55-985d-615099564153, VSM_Email=\(VSMAPI.Settings.login), VSM_PasswordHash=\(VSMAPI.Settings.hash), VSM_Alias=."]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: URL(string: VSMAPI.Settings.caddress)!)
        jar.setCookies(cookies, for: URL(string: VSMAPI.Settings.caddress), mainDocumentURL: URL(string: VSMAPI.Settings.caddress))
        for (cookie) in cookies {
            ConfigurationWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
        var request = URLRequest(url: viewURL!)
        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }
        ConfigurationWebView.load(request)

        print(cookies)
    }
}
