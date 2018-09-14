//
//  RememberPasswordViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 14.09.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class RememberPasswordViewController: UIViewController {

    @IBOutlet weak var ServersListView: UIView!
    @IBOutlet weak var CheckServerButton: UIButton!
    @IBOutlet weak var EmailField: StrickTextBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func rememberPasswordButtonClickHandler(_ sender: UIButton) {
        let email = EmailField.text
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
 
    func saveServer(server: String, serverName: String){
        ServersListView.isHidden = true
        CheckServerButton.titleLabel?.text = serverName
        VSMAPI.Settings.caddress = server
    }
    
}
