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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            //VSMAPI.Settings.registration(email: email!, passwordHash: passwordHash!)
            let resultRegistrationCode = "0"
            var resultRegistrationText = "Вы успешно создали ваш аккаунт. Инструкция по его активации отправлена по электронной почте"
            if (resultRegistrationCode == "1") {
                resultRegistrationText = "Почтовый ящик " + email! + " уже зарегистрирован в системе"
            } else if (resultRegistrationCode != "0") {
                resultRegistrationText = "Ошибка регистрации!"
            }
            let button2Alert: UIAlertView = UIAlertView(title: "", message: resultRegistrationText, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
            button2Alert.show()
            if (resultRegistrationCode == "0") {
                performSegue(withIdentifier: "successfulAthorizationSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AuthorizationViewController{
            destination.email = EmailTextBox.text
            destination.password = PasswordTextBox.text
        }
    }
}
