//
//  RegistrationViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 23.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {

    private let mHasher: Hasher = Hasher()
    
    @IBOutlet weak var EmailTextBox: StrickTextBox!
    @IBOutlet weak var PasswordTextBox: StrickTextBox!
    @IBOutlet weak var PasswordConfirmTextBox: StrickTextBox!
    @IBOutlet weak var AuthorizationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ServersListView: UIView!
    @IBOutlet weak var CheckServerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
 
    @IBAction func RegistrationButton(_ sender: UIButton) {
        let email           = EmailTextBox.text?.trimmingCharacters(in: .whitespaces)
        let password        = PasswordTextBox.text?.trimmingCharacters(in: .whitespaces)
        let passwordConfirm = PasswordConfirmTextBox.text?.trimmingCharacters(in: .whitespaces)
        
        AuthorizationIndicator.isHidden = false
        
        if ((email == "") || (password == "") || (passwordConfirm == "")){
            let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Поля не могут быть пустыми", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
            button2Alert.show()
            AuthorizationIndicator.isHidden = true
        } else if (password != passwordConfirm) {
            let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Пароли не совпадают", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
            button2Alert.show()
            AuthorizationIndicator.isHidden = true
        } else {
            let passwordHash = mHasher.GetMD5Hash(inputString: password!)
            if let resultRegistrationCode = VSMAPI.Settings.registration(email: email!, passwordHash: passwordHash!){
                let button2Alert: UIAlertView = UIAlertView(title: "", message: "Вы успешно создали ваш аккаунт. Инструкция по его активации отправлена по электронной почте", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                button2Alert.show()
                performSegue(withIdentifier: "successfulAthorizationSegue", sender: self)
            } else {
                let button2Alert: UIAlertView = UIAlertView(title: "", message: "Ошибка регистрации", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                button2Alert.show()
            }
            AuthorizationIndicator.isHidden = true
        }
    }
    
    func saveServer(server: String, serverName: String){
        ServersListView.isHidden = true
        CheckServerButton.titleLabel?.text = serverName
        VSMAPI.Settings.caddress = server
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AuthorizationViewController{
            destination.email = EmailTextBox.text
            destination.password = PasswordTextBox.text
        }
    }
}
