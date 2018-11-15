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
    private var globalServerName: String!
    private var globalServer: String!
    
    @IBOutlet weak var EmailTextBox: StrickTextBox!
    @IBOutlet weak var PasswordTextBox: StrickTextBox!
    @IBOutlet weak var PasswordConfirmTextBox: StrickTextBox!
    @IBOutlet weak var AuthorizationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ServersListView: UIView!
    @IBOutlet weak var CheckServerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AuthorizationIndicator.isHidden = true
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
    
    @IBAction func checkMarketing(_ sender: UIButton) {
        saveServer(server: "http://marketing.nbics.net/", serverName: "marketing.nbics")
    }
    
    @IBAction func checkGOV(_ sender: UIButton) {
        saveServer(server: "http://sc.gov39.ru/", serverName: "sc.gov39")
    }
    
    @IBAction func checkEducation(_ sender: UIButton) {
        saveServer(server: "http://education.nbics.net/", serverName: "education")
    }
 
    @IBAction func RegistrationButton(_ sender: UIButton) {
        AuthorizationIndicator.isHidden = false
        if (inet.isConn) {
            let email           = EmailTextBox.text?.trimmingCharacters(in: .whitespaces)
            let password        = PasswordTextBox.text?.trimmingCharacters(in: .whitespaces)
            let passwordConfirm = PasswordConfirmTextBox.text?.trimmingCharacters(in: .whitespaces)
            if ((email == "") || (password == "") || (passwordConfirm == "")){
                let alert = UIAlertController(title: "Ошибка регистрации", message: "Поля не могут быть пустыми", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else if (password != passwordConfirm) {
                let alert = UIAlertController(title: "Ошибка регистрации", message: "Пароли не совпадают", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                let passwordHash = mHasher.GetMD5Hash(inputString: password!)
                let result = VSMAPI.Settings.registration(email: email!, passwordHash: passwordHash!)
                if (result == 0) {
                    performSegue(withIdentifier: "successfulAthorizationSegue", sender: self)
                    let alert = UIAlertController(title: "", message: "Вы успешно создали ваш аккаунт. Инструкция по его активации отправлена по электронной почте", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                } else if (result == 1) {
                    let alert = UIAlertController(title: "Ошибка регистрации", message: "Данный почтовый адрес уже зарегистрирован в системе", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Ошибка регистрации", message: "Не удалось отправить письмо на почту", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Ошибка регистрации", message: "Нет связи с интернетом", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        AuthorizationIndicator.isHidden = true
    }
    
    func saveServer(server: String, serverName: String){
        ServersListView.isHidden = true
        CheckServerButton.titleLabel?.text = serverName
        VSMAPI.Settings.caddress = server
        globalServerName = serverName
        globalServer = server
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AuthorizationViewController{
            destination.email            = EmailTextBox.text
            destination.password         = PasswordTextBox.text
            destination.globalServerName = globalServerName
            destination.globalServer     = globalServer
        }
    }
}
