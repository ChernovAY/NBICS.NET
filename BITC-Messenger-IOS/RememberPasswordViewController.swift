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
        let result = VSMAPI.Settings.resetPassword(email: email!)
        if (email == "") {
            let alert = UIAlertController(title: "Ошибка", message: "Поле email пусто", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else if (result == 1) {
            let alert = UIAlertController(title: "Ошибка", message: "Такогой email в сети не зарегистрирован", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "successfulResetPasswordSegue", sender: self)
            let alert = UIAlertController(title: "", message: "Инструкция по восстановлению пароля выслана вам на почту", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
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
 
    
    @IBAction func moveToAuthorizationScreen(_ sender: Any) {
        performSegue(withIdentifier: "successfulResetPasswordSegue", sender: self)
    }
    
    func saveServer(server: String, serverName: String){
        ServersListView.isHidden = true
        CheckServerButton.titleLabel?.text = serverName
        VSMAPI.Settings.caddress = server
    }
    
}
