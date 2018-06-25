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
    
    private var EInitHandler: Disposable?
    
    @IBOutlet weak var LoginField: StrickTextBox!
    
    @IBOutlet weak var PasswordField: StrickTextBox!

    private let mHasher: Hasher = Hasher()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: AuthorizationViewController.NavigateToChats)}
    }
    deinit {
        EInitHandler?.dispose()
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
                        VSMAPI.Settings.logIn(user: email, hash: hash)
                    }
                }
            } else {
                let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Логин или пароль не могут быть пустыми", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                button2Alert.show()
            }
        }
        else {
            VSMAPI.Settings.logIn(user: VSMAPI.Settings.user, hash: VSMAPI.Settings.hash)
        }
    }
  
    private func NavigateToChats(_ b: Bool=true) {
        EInitHandler?.dispose()
        if b{performSegue(withIdentifier: "successfulAuthorization", sender: self)}
    }
}
