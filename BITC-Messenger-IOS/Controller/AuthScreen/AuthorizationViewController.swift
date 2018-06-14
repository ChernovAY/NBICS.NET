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

    private let mUserDefaults: NSUserDefaultsStrings = NSUserDefaultsStrings()
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
        if mUserDefaults.GetLoginStatus() == false {
            if (!(PasswordField.text?.isEmpty)! && !(LoginField.text?.isEmpty)!){
                if let hash = mHasher.GetMD5Hash(inputString: PasswordField.text!) {
                    if let email = LoginField.text {
                        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.login, params: ["login" : email, "passwordHash" : hash], completionHandler: {(d,s) in{
                            if(!s){
                                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                            }
                            else{
                                if d is Data {
                                    let data = d as! Data
                                    let result = String(data: data, encoding: .utf8)
                                    switch result {
                                    case "0":
                                        self.mUserDefaults.SetUserEmail(email: email)
                                        self.mUserDefaults.SetUserPasswordHash(hash: hash)
                                        
                                        WebAPI.Settings.user = email; WebAPI.Settings.hash = hash;
                                        WebAPI.Profile = VSMProfile()
                                        VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{self.getUserContact(); WebAPI.UserContacts = l;VSMConversation.contacts.addIfNotExists(from: l.SArray); self.NavigateToChats();}()})
                                        print("done")
                                    case "1":
                                        let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Такого логина не существует", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                                        button2Alert.show()
                                    case "2":
                                        let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Неверный пароль", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                                        button2Alert.show()
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
            let email = mUserDefaults.GetUserEmail()!, hash = mUserDefaults.GetUserPasswordHash()!;
            WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.login, params: ["user" : email, "passwordHash" : hash], completionHandler: {(d,s) in{
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
                                    WebAPI.Settings.user = email; WebAPI.Settings.hash = hash;
                                    WebAPI.Profile = VSMProfile()
                                    VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{self.getUserContact(); WebAPI.UserContacts = l;VSMConversation.contacts.addIfNotExists(from: l.SArray); self.NavigateToChats();}()})
                            
                            default: break
                        }
                    }
                }
                }()}
            )
        }
    }
    //Потом найти для этого правильное место!
    private func getUserContact(){
        let z = WebAPI.syncRequest(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.userInformation, params: ["email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash])
            
            if(!z.1){
                UIAlertView(title: "Ошибка", message: z.0 as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if z.0 is Data {
                    let data = z.0 as! Data
                    if let json = try? JSON(data: data) {
                        let dict = json.dictionary!
                        WebAPI.Contact = VSMConversation.contacts.findOrCreate(what: dict)
                        WebAPI.Contact!.isOwnContact = true
                        }
                    }
                }
    }
    
    private func NavigateToChats() {
        let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
        if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "AllChatsViewController") as? AllChatsViewController {
            self.present(chatsViewController, animated: true, completion: nil)
        }
    }
}
