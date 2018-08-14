//
//  AuthorizationViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 22.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizationViewController: UIViewController {
    
    private let mHasher: Hasher = Hasher()
    private var EInitHandler: Disposable?
    @IBOutlet weak var LoginField: StrickTextBox!
    @IBOutlet weak var PasswordField: StrickTextBox!
    @IBOutlet weak var ServersListView: UIView!
    @IBOutlet weak var CheckServerButton: UIButton!
    @IBOutlet weak var AuthorizationIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: AuthorizationViewController.NavigateToChats)}
        AuthorizationIndicator.isHidden = true
    }
    deinit {
        EInitHandler?.dispose()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func authorization(_ sender: UIButton) {
        AuthorizationIndicator.isHidden = false
        if !VSMAPI.Settings.login{
            if (!(PasswordField.text?.isEmpty)! && !(LoginField.text?.isEmpty)!){
                if let hash = mHasher.GetMD5Hash(inputString: PasswordField.text!) {
                    if let email = LoginField.text {
                        VSMAPI.Settings.logIn(user: email, hash: hash)
                    }
                }
            } else {
                let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Логин или пароль не могут быть пустыми", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                button2Alert.show()
                AuthorizationIndicator.isHidden = true
            }
        }
        else {
            VSMAPI.Settings.logIn(user: VSMAPI.Settings.user, hash: VSMAPI.Settings.hash)
        }
    }
    
    @IBAction func checkServer(_ sender: UIButton) {
        ServersListView.isHidden = false
    }
    
    @IBAction func checkNBICS(_ sender: UIButton) {
        saveServer(server: "https://nbics.net/", serverName: "nbics")
    }
    
    @IBAction func checkSC(_ sender: UIButton) {
        saveServer(server: "http://sc.nbics.net/", serverName: "sc.nbics")
    }
    
    @IBAction func checkMarketing(_ sender: UIButton) {
        saveServer(server: "http://marketing.nbics.net/", serverName: "marketing.nbics")
    }
    
    @IBAction func checkDev(_ sender: UIButton) {
        saveServer(server: "http://dev.nbics.net/", serverName: "dev.nbics")
    }
    
    @IBAction func checkGOV(_ sender: UIButton) {
        saveServer(server: "http://sc.gov39.ru/", serverName: "sc.gov39")
    }
    
    @IBAction func checkBGR(_ sender: UIButton) {
        saveServer(server: "http://site.bgr39.ru/", serverName: "site.bgr39")
    }
    
    @IBAction func checkEducation(_ sender: UIButton) {
        saveServer(server: "http://education.nbics.net/", serverName: "education")
    }
    
    
    /*
    @IBAction func checkBGR(_ sender: UIButton) {
        saveServer(server: "http://site.bgr39.ru/", serverName: "site.bgr39")
    }
    
    @IBAction func checkGOV(_ sender: UIButton) {
        saveServer(server: "https://sc.gov39.ru/", serverName: "sc.gov39")
    }
    
    @IBAction func checkNBICS(_ sender: UIButton) {
    }
    
    @IBAction func checkEducation(_ sender: UIButton) {
        saveServer(server: "http://education.nbics.net/", serverName: "education")
    }
    */
    func saveServer(server: String, serverName: String){
        ServersListView.isHidden = true
        CheckServerButton.titleLabel?.text = serverName
        VSMAPI.Settings.caddress = server
    }
    
    private func NavigateToChats(_ b: Bool=true) {
        EInitHandler?.dispose()
        if b{performSegue(withIdentifier: "successfulAuthorization", sender: self)}
    }
}
