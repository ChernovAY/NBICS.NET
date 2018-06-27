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
            Data.ETimerAction.raise(data: true)
            VSMAPI.deleteCommunicatorFiles()
            Settings.user = ""; Settings.hash = ""; Settings.login = false;
            Data.deleteAll()
        }
        
        private static func checkDBDirectory(){
            func directoryExistsAtPath(_ path: String) -> Bool {
                var isDirectory = ObjCBool(true)
                let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
                return exists && isDirectory.boolValue
            }
            
            if !directoryExistsAtPath(VSMAPI.DBURL.path){
                try? FileManager.default.createDirectory(at: VSMAPI.DBURL, withIntermediateDirectories: false)
            }
            
        }
        public static func logIn(user:String, hash: String){
            VSMAPI.Settings.checkDBDirectory()
            if(VSMAPI.Settings.login) {
                Data.loadAll()
                return;
            }
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
                            Data.loadAll()
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
        case captcha                = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/CaptchaGet"//---
        case registration           = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/Registration"//---
    
        case userInformation        = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserInformation" //+++
        case profile                = "VSM.Web.Plugins.NProfile/NProfileHome/GetUserProfileApi"  //+++
        case setProfile             = "VSM.Web.Plugins.NProfile/NProfileHome/SetUserProfileApi" //+++
        
        case contatcs               = "VSM.Web.Plugins.Contacts/ContactsHome/GetContacts"        //+++
        case userContactAvatar      = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrl"//----
        case getIcon                = ""    //+++
    
        case lastConversationList   = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserLastConversationList"   //+++
    
        case download               = "VSM.Web.Plugins.Contacts/ContactsHome/Download"  //+++
        case filePreviewIcon        = "VSM.Web.Plugins.Contacts/ContactsHome/GetFilePreviewIcon"    //+++
        case fileImage              = "VSM.Web.Plugins.Contacts/ContactsHome/GetFileImage"  //+++
        
        case conversationMessages   = "VSM.Web.Plugins.Contacts/ContactsHome/GetConversationNMessagesAfterOrBefore" //+++
        case messageReaded          = "VSM.Web.Plugins.Contacts/ContactsHome/SetConversationMessagesReaded" //+++
        case sendMessage            = "VSM.Web.Plugins.Contacts/ContactsHome/SendMessage"   //+++
        
        case fileUpload             = "VSM.Web.Plugins.Contacts/ContactsHome/UploadMessageFileWithoutDraft" //+++
        case fileDrop               = "VSM.Web.Plugins.Contacts/ContactsHome/RemoveMessageFileFromServerWithoutDraft"   //+++
        
        case NNotReadedMsgs         = "VSM.Web.Plugins.Contacts/ContactsHome/GetNotReadedMessagesCount"
        case NContReqs              = "VSM.Web.Plugins.Contacts/ContactsHome/GetInContactsRequestsCount"
        
        case ContactsRequests       = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsRequests"   //+++
    
    }
    // Session Manager Configurations!!!!!!!
    public static func syncRequest(addres:String, entry: VSMAPI.WebAPIEntry, postf:String = "", params:Params)->(Any,Bool){
        if !Connectivity.isConn {return("Интернета нету!", false)}
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
        if !Connectivity.isConn {completionHandler("Интернета нету!", false);return}
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
    public static func saveFile(name: String, data: Data)->Bool{
        var ret = false
        let fm = FileManager.default
        let filename = VSMAPI.DBURL.path + "/"+name.replacingOccurrences(of: "/", with: "_")
        if(fm.createFile(atPath: filename, contents: data)){
                ret = true
        }
        return ret
    }
    public static func getFile(name:String)->Data?{
        var ret:Data?
        let fm = FileManager.default
        let filename = VSMAPI.DBURL.path + "/" + name.replacingOccurrences(of: "/", with: "_")
        if(fm.fileExists(atPath: filename)){
            if let data = fm.contents(atPath: filename){
                   ret = data
            }
        }
        return ret
    }
    public static func getPicture(name:String, empty:String)->UIImage?{
        var img:UIImage?
        let fm = FileManager.default
        let filename = VSMAPI.DBURL.path + "/" + name.replacingOccurrences(of: "/", with: "_")
        if(fm.fileExists(atPath: filename)){
            if let data = fm.contents(atPath: filename){
                img = UIImage(data: data)
            }
            else if empty != ""{
                img = UIImage(named: empty)
            }
        }
        else if empty != ""{
            img = UIImage(named: empty)
        }
        if img == nil && empty != "" {
            img = UIImage(named: empty)
        }
        return img
    }
    public static func fileExists(_ name:String)->Bool{
        let fm = FileManager.default
        let filename = VSMAPI.DBURL.path + "/" + name
        return fm.fileExists(atPath: filename)
    }
    public static func deleteCommunicatorFiles(){
            let fm = FileManager.default
        
            let enumerator: FileManager.DirectoryEnumerator = fm.enumerator(atPath: VSMAPI.DBURL.path)!
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix(".I"){
                    try? fm.removeItem(atPath: NSTemporaryDirectory()+"/"+element)
                }
            }
    }
    //----------------------------------------------------------------------------------------
    public static let DBURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("DB", isDirectory: true)
    public static var Data = VSMData()
    
    public struct VSMChatsCommunication{
        public static var conversetionId = ""
    }
}
