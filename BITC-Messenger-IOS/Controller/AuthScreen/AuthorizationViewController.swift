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
    
    @IBOutlet weak var LoginField: StrickTextBox!
    
    @IBOutlet weak var PasswordField: StrickTextBox!

    private let mHasher: Hasher = Hasher()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func EnterChat(_ sender: Any) {
        if !VSMAPI.Settings.login{
            if (!(PasswordField.text?.isEmpty)! && !(LoginField.text?.isEmpty)!){
                if let hash = mHasher.GetMD5Hash(inputString: PasswordField.text!) {
                    if let email = LoginField.text {
                        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.login, params: ["login" : email, "passwordHash" : hash], completionHandler: {(d,s) in{
                            if(!s){
                                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                            }
                            else{
                                if d is Data {
                                    let data = d as! Data
                                    let result = String(data: data, encoding: .utf8)
                                    switch result {
                                    case "0":
                                        VSMAPI.Settings.logIn(user: email, hash: hash, delegate: self.NavigateToChats)
                                    case "1":
                                        let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Такого логина не существует", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                                        button2Alert.show()
                                        VSMAPI.Settings.logOut();
                                    case "2":
                                        let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Неверный пароль", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                                        button2Alert.show()
                                        VSMAPI.Settings.logOut();
                                    default: break
                                    }
                                }
                            }
                            }()}
                        )
                    }
                }
            } else {
                let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Логин или пароль не могут быть пустыми", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                button2Alert.show()
            }
        } else {
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.login, params: ["login" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], completionHandler: {(d,s) in{
                if(!s){
                    UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                    //UIAlertController(title: "Ошибка", message: d as? String, preferredStyle: UIAlertControllerStyle.alert)
                }
                else{
                    if d is Data {
                        let data = d as! Data
                        let result = String(data: data, encoding: .utf8)
                        switch result {
                            case "0":
                                    VSMAPI.Settings.logIn(user: VSMAPI.Settings.user, hash: VSMAPI.Settings.hash, delegate: self.NavigateToChats)
                            default: break
                        }
                    }
                }
                }()}
            )
        }
    }
    //Потом найти для этого правильное место!
   
    private func NavigateToChats() {
        performSegue(withIdentifier: "successfulAuthorization", sender: self)
    }
}
