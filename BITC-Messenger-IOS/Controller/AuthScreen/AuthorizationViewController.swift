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
                                        VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{WebAPI.UserContacts = l;VSMConversation.contacts.addIfNotExists(from: l.SArray); self.getUserContact()}()})
                                        self.NavigateToChats()
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
                }
                else{
                    if d is Data {
                        let data = d as! Data
                        let result = String(data: data, encoding: .utf8)
                        switch result {
                            case "0":
                                    WebAPI.Settings.user = email; WebAPI.Settings.hash = hash;
                                    VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{WebAPI.UserContacts = l;VSMConversation.contacts.addIfNotExists(from: l.SArray); self.getUserContact()}()})
                                    self.NavigateToChats()
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
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.userInformation, params: ["email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash], completionHandler: {(d,s) in{
            
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        let dict = json.dictionary!
                        VSMConversation.contacts.findOrCreate(what: dict)?.isOwnContact = true
                        }
                    }
                }
            }()})
    }
        

    private func NavigateToChats() {
        let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
        if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "AllChatsViewController") as? AllChatsViewController {
            self.present(chatsViewController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
