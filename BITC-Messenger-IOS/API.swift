//
//  WebApi.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public typealias Params = [String:Any];

public class VSMAPI{
    public static var sites:[String] = ["https://nbics.net/", "https://sc.gov39.ru", "http://site.bgr39.ru"]
    
    public class Connectivity {
        public class var isConn:Bool {
            return NetworkReachabilityManager()!.isReachable
        }
        public class var fromServer:Bool{
            if(NetworkReachabilityManager()!.isReachable){
                Counter = Counter + 1
                if Counter >= MaxN {
                    Counter = 0
                }
            }
            return (Counter == 0 && NetworkReachabilityManager()!.isReachable)
        }
        private static var Counter = -1
        private static var MaxN = 10
    }
    
    public struct Settings{
        public static var hash:String{
            get{return UserDefaults.standard.object(forKey: "hash") as? String ?? ""}
            set(value){UserDefaults.standard.set(value, forKey: "hash")}
        }
        public static var caddress:String{
            get{return UserDefaults.standard.object(forKey: "caddress") as? String ?? "https://nbics.net/"}
            set(value){UserDefaults.standard.set(value, forKey: "caddress")}
        }
        public static var user:String{
            get{return UserDefaults.standard.object(forKey: "user") as? String ?? ""}
            set(value){UserDefaults.standard.set(value, forKey: "user")}
        }
        public static var login:Bool{
            get{return UserDefaults.standard.object(forKey: "login") as? Bool ?? false}
            set(value){UserDefaults.standard.set(value, forKey: "login")}
        }
        public static func logOut(){
           Settings.user = ""; Settings.hash = ""; Settings.login = false;
            VSMAPI.Profile = nil
            VSMAPI.Contact = nil
            VSMAPI.UserConversations.array.removeAll()
            VSMAPI.UserContacts.array.removeAll()
        }
        public static func logIn(user:String, hash: String, delegate: @escaping ()->Void ){
            if(VSMAPI.Settings.login) {return;}
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.login, params: ["login" : user, "passwordHash" : hash], completionHandler: {(d,s) in{
                if(!s){
                    UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                }
                else{
                    if d is Data {
                        let data = d as! Data
                        let result = String(data: data, encoding: .utf8)
                        switch result {
                        case "0":
                            Settings.user = user; Settings.hash = hash; Settings.login = true;
                            VSMAPI.Profile = VSMProfile()
                            VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in
                                {
                                    VSMAPI.getUserContact();
                                    VSMAPI.UserContacts.addIfNotExists(from: l.array);
                                    VSMConversation.contacts.addIfNotExists(from: l.array);
                                    delegate();}()})
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

    public enum WebAPIEntry:String{
    
        case login                  = "Account/Login" //+++
        case captcha                = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/CaptchaGet"
        case registration           = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/Registration"
    
        case userInformation        = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserInformation" //+++
        case profile                = "VSM.Web.Plugins.NProfile/NProfileHome/GetUserProfileApi"  //+++
        case setProfile             = "VSM.Web.Plugins.NProfile/NProfileHome/SetUserProfileApi"
        
        case contatcs               = "VSM.Web.Plugins.Contacts/ContactsHome/GetContacts"        //+++
        case userContactAvatar      = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrl"
        case getIcon                = ""    //+++
    
        case lastConversationList   = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserLastConversationList"   //+++
    
        case download               = "VSM.Web.Plugins.Contacts/ContactsHome/Download"  //+++
        case filePreviewIcon        = "VSM.Web.Plugins.Contacts/ContactsHome/GetFilePreviewIcon"    //+++
        case fileImage              = "VSM.Web.Plugins.Contacts/ContactsHome/GetFileImage"  //+++
        
        case conversationMessages   = "VSM.Web.Plugins.Contacts/ContactsHome/GetConversationNMessagesAfterOrBefore" //+++
        case messageReaded          = "VSM.Web.Plugins.Contacts/ContactsHome/SetConversationMessagesReaded"
        case sendMessage            = "VSM.Web.Plugins.Contacts/ContactsHome/SendMessage"   //+++
        
        case fileUpload             = "VSM.Web.Plugins.Contacts/ContactsHome/UploadMessageFileWithoutDraft" //+++
        case fileDrop               = "VSM.Web.Plugins.Contacts/ContactsHome/RemoveMessageFileFromServerWithoutDraft"   //+++
        
    
    }
    // Session Manager Configurations!!!!!!!
    public static func syncRequest(addres:String, entry: VSMAPI.WebAPIEntry, postf:String = "", params:Params)->(Any,Bool){
        let request = Alamofire.request(addres + entry.rawValue + postf, method: HTTPMethod.get, parameters: params, headers: nil)
        let resp =  request.syncResponse()
        let succ = resp.error == nil
        if(succ){
            return (resp.data!, true)
        }
        else{
            return (resp.error.unsafelyUnwrapped.localizedDescription, false)
        }
    }
    
    public static func Request (addres:String, entry: VSMAPI.WebAPIEntry, postf:String = "", method: HTTPMethod = HTTPMethod.get, params:Params, completionHandler: @escaping (Any,Bool) -> ()) {
        let addr = addres + entry.rawValue + postf
        let request = Alamofire.request(addr, method: method, parameters: params, headers: nil)
        
        request.response {  response in
            var res:Any
            let succ = response.error == nil
            if(succ){
                    res = response.data!
            }
            else{
                res = response.error.unsafelyUnwrapped.localizedDescription
            }
            completionHandler(res, succ)
        }
    }
    public static func savePicture(name: String, data: Data)->Bool{
        var ret = false
        let fm = FileManager.default
        let filename = NSTemporaryDirectory() + "/"+name
        if(fm.createFile(atPath: filename, contents: data)){
                ret = true
        }
        return ret
    }
    
    public static func getPicture(name:String, empty:String)->UIImage{
        var img:UIImage?
        let fm = FileManager.default
        let filename = NSTemporaryDirectory() + "/" + name
        if(fm.fileExists(atPath: filename)){
            if let data = fm.contents(atPath: filename){
                img = UIImage(data: data)
            }
            else{
                img = UIImage(named: empty)
            }
        }
        else{
            img = UIImage(named: empty)
        }
        if img == nil{
            img = UIImage(named: empty)
        }
        return img!
    }
    
    public static var UserContacts = VSMContacts()
    public static var UserConversations = VSMConversations()
    public static var Profile : VSMProfile?
    public static var Contact : VSMContact?
    
    public struct VSMChatsCommunication{
        public static var conversetionId = ""
    }
    
/////////////////////
    private static func getUserContact(){
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.userInformation, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash])
        
        if(!z.1){
            UIAlertView(title: "Ошибка", message: z.0 as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
        }
        else{
            if z.0 is Data {
                let data = z.0 as! Data
                if let json = try? JSON(data: data) {
                    let dict = json.dictionary!
                    VSMAPI.Contact = VSMConversation.contacts.findOrCreate(what: dict)
                    VSMAPI.Contact!.isOwnContact = true
                }
            }
        }
    }
}
