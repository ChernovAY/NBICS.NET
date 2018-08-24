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
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

public typealias Params = [String:Any];

public class VSMAPI{
    public static var sites:[String] = ["https://nbics.net/", "https://sc.gov39.ru/", "http://site.bgr39.ru/", "http://dev.nbics.net/", "http://education.nbics.net/"]
    
    public class Connectivity {
        public class var isConn:Bool {
            return NetworkReachabilityManager()!.isReachable
        }
    }
    
    public struct Settings{
        public static var refreshToken:String{
            get{return UserDefaults.standard.object(forKey: "refreshToken") as? String ?? ""}
            set(value){UserDefaults.standard.set(value, forKey: "refreshToken")}
        }
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
            VSMAPI.Request(addres: Settings.caddress, entry: .DisconnectUserDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(Settings.refreshToken)"]) { (d, b) in
                VSMAPI.Request(addres: Settings.caddress, entry: .UnregisterDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(Settings.refreshToken)"], completionHandler: { (d, b) in
                    VSMAPI.deleteCommunicatorFiles()
                    Settings.user = ""; Settings.hash = ""; Settings.login = false;
                    Data.deleteAll()
                    UIApplication.shared.applicationIconBadgeNumber  = 0
                    })
            }
        }
        public static func refreshFB(fcmToken:String){
            if VSMAPI.Settings.refreshToken != fcmToken{
                if Settings.login{
                    Data.ETimerAction.raise(data: true)
                    VSMAPI.Request(addres: Settings.caddress, entry: .DisconnectUserDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(Settings.refreshToken)"]) { (d, b) in
                        VSMAPI.Request(addres: Settings.caddress, entry: .UnregisterDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(Settings.refreshToken)"], completionHandler: { (d, b) in
                            
                                VSMAPI.Settings.refreshToken = fcmToken
                                VSMAPI.Request(addres: Settings.caddress, entry: .RegisterNewDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(UIDevice.current.identifierForVendor!.uuidString)&\(Settings.refreshToken)", "DeviceOS":"2"], completionHandler: { (d, b) in
                                    VSMAPI.Request(addres: Settings.caddress, entry: .ConnectUserDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"Device":
                                        JSON(["Id":Settings.refreshToken, "OS":2, "IsOnline":"True"]).rawString([.castNilToNSNull: true])!]
                                        ,completionHandler: { (d, b) in
                                            Data.loadAll()
                                    })
                                    
                                })
                        })
                    }
                } else {
                    VSMAPI.Settings.refreshToken = fcmToken
                }
            }
        }
        private static func preLoadAll(){
            Settings.refreshToken = InstanceID.instanceID().token() ?? ""
            VSMAPI.Request(addres: Settings.caddress, entry: .RegisterNewDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"DeviceID":"\(UIDevice.current.identifierForVendor!.uuidString)&\(Settings.refreshToken)", "DeviceOS":"2"], completionHandler: { (d, b) in
                VSMAPI.Request(addres: Settings.caddress, entry: .ConnectUserDevice, params: ["Email":VSMAPI.Settings.user,"PasswordHash":VSMAPI.Settings.hash,"Device":
                    JSON(["Id":Settings.refreshToken, "OS":2, "IsOnline":"True"]).rawString([.castNilToNSNull: true])!]
                    ,completionHandler: { (d, b) in
                        Data.loadAll()
                })
                
            })
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
                preLoadAll()
                return;
            }
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.login, params: ["login" : user, "passwordHash" : hash], completionHandler: {(d,s) in{
                if(!s){
                    UIAlertView(title: "Ошибка", message: d as? String, delegate: self, cancelButtonTitle: "OK").show()
                } else {
                    if d is Data {
                        let data = d as! Data
                        let result = String(data: data, encoding: .utf8)
                        switch result {
                        case "0":
                            Settings.user = user; Settings.hash = hash; Settings.login = true
                            preLoadAll()
                        case "1":
                            let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Такого логина не существует", delegate: self, cancelButtonTitle: "OK")
                            button2Alert.show()
                            VSMAPI.Settings.logOut();
                        case "2":
                            let button2Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Неверный пароль", delegate: self, cancelButtonTitle: "OK")
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
        
        case contactProfile         = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserProfile"
        
        case contatcs               = "VSM.Web.Plugins.Contacts/ContactsHome/GetContacts"        //+++
        case userContactAvatar      = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrl"//----
        case getIcon                = ""    //+++
    
        case lastConversationList   = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserLastConversationList"   //+++
    
        case download               = "VSM.Web.Plugins.Contacts/ContactsHome/Download"  //+++
        case filePreviewIcon        = "VSM.Web.Plugins.Contacts/ContactsHome/GetFilePreviewIcon"    //+++
        case fileImage              = "VSM.Web.Plugins.Contacts/ContactsHome/GetFileImage"  //+++
        
        case newConversation        = "VSM.Web.Plugins.Contacts/ContactsHome/GetConversationFullMetaData"
        case conversationMessages   = "VSM.Web.Plugins.Contacts/ContactsHome/GetConversationNMessagesAfterOrBefore" //+++
        case messageReaded          = "VSM.Web.Plugins.Contacts/ContactsHome/SetConversationMessagesReaded" //+++
        case sendMessage            = "VSM.Web.Plugins.Contacts/ContactsHome/SendMessage"   //+++
        
        case fileUpload             = "VSM.Web.Plugins.Contacts/ContactsHome/UploadMessageFileWithoutDraft" //+++
        case fileDrop               = "VSM.Web.Plugins.Contacts/ContactsHome/RemoveMessageFileFromServerWithoutDraft"   //+++
        
        case NNotReadedMsgs         = "VSM.Web.Plugins.Contacts/ContactsHome/GetNotReadedMessagesCount"
        case NContReqs              = "VSM.Web.Plugins.Contacts/ContactsHome/GetInContactsRequestsCount"
        
        case ContactsRequests       = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsRequests"   //+++
        
        case RegisterNewDevice      = "VSM.Web.Plugins.Contacts/ContactsHome/RegisterNewDevice"  //+++
        case UnregisterDevice       = "VSM.Web.Plugins.Contacts/ContactsHome/UnregisterDevice"  //+++
        case DisconnectUserDevice   = "VSM.Web.Plugins.Contacts/ContactsHome/DisconnectUserDevice"  //+++
        case ConnectUserDevice      = "VSM.Web.Plugins.Contacts/ContactsHome/ConnectUserDevice"  //+++
        
        case SearchContacts         = "VSM.Web.Plugins.Contacts/ContactsHome/SearchContacts"    //+++
        
        case Op_SendUserRequest        = "VSM.Web.Plugins.Contacts/ContactsHome/SendUserRequest"    //+++
        case Op_DeniedUserRequest      = "VSM.Web.Plugins.Contacts/ContactsHome/DeniedUserRequest"    //+++
        case Op_AcceptUserRequest      = "VSM.Web.Plugins.Contacts/ContactsHome/AcceptUserRequest"    //+++
        case Op_CancelUserRequest      = "VSM.Web.Plugins.Contacts/ContactsHome/CancelUserRequest"    //+++
        case Op_DeleteUserFromContacts = "VSM.Web.Plugins.Contacts/ContactsHome/DeleteUserFromContacts"    //+++
        
        case AddNewConversation                 = "VSM.Web.Plugins.Contacts/ContactsHome/AddNewConversation"    //+++
        case ConversationRename                 = "VSM.Web.Plugins.Contacts/ContactsHome/ConversationRename"
        case ConversationUsersIncludeOrExclude  = "VSM.Web.Plugins.Contacts/ContactsHome/ConversationUsersIncludeOrExclude"     //+++
        
        case Configurations             = "Workplace/GetConfigurations" //+++
        case PublicConfigurations       = "Workplace/GetUserRolesWithConfigurations"
        case CopyConfiguration          = "Workplace/CopyNode"
        case DeleteConfiguration        = "Workplace/DeleteNode"
    }
    // Session Manager Configurations!!!!!!!
    public static func syncRequest(addres:String, entry: VSMAPI.WebAPIEntry, postf:String = "", params:Params)->(Any,Bool){
        if !Connectivity.isConn {return("Интернета нету!", false)}
        let request = Alamofire.request(addres + entry.rawValue + postf, method: HTTPMethod.get, parameters: params, headers: nil)
        let resp =  request.syncResponse()
        let succ = resp.error == nil
        if(succ){
            return (resp.data!, true)
        } else
        {
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
            } else {
                res = response.error.unsafelyUnwrapped.localizedDescription
            }
            completionHandler(res, succ)
        }
    }
    public static func delFile(name: String)->Bool{
        let fm = FileManager.default
        let filename = VSMAPI.DBURL.path + "/"+name.replacingOccurrences(of: "/", with: "_")
        return ((try? fm.removeItem(atPath: VSMAPI.DBURL.path+"/"+filename)) != nil)
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
            } else if empty != ""{
                img = UIImage(named: empty)
            }
        } else if empty != ""{
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
                    try? fm.removeItem(atPath: VSMAPI.DBURL.path+"/"+element)
                }
            }
    }
    //----------------------------------------------------------------------------------------
    public static let DBURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("DB", isDirectory: true)
    public static var Data = VSMData()
    
    public struct VSMChatsCommunication{
        public static var conversetionId    = ""{
            didSet{
                checkedContactForConversation.removeAll()
                let a = VSMAPI.Data.getContacts(type: VSMContact.ContactType.Cont)
                let conv = VSMAPI.Data.Conversations[conversetionId]
                let users = conv?.Users ?? [VSMContact]()
                for c in a {
                    let cc = VSMCheckedContact(c,false)
                    
                    if conversetionId != "" {
                        if let _ = users.first(where: ({$0.Id == c.Id})){
                            cc.Checked = true
                        }
                        cc.Conversation = conv
                    }
                    checkedContactForConversation.append(cc)
                }
            }
        }
        public static var contactId         = 0
        public static var BDayDelegate: ()->() = {() in print(VSMAPI.Data.Profile!.BirthDay.toString()) }
        public static var checkedContactForConversation = [VSMCheckedContact]()
        public static var AttMessageId      = ""
        public static var tabBarChats           :UITabBarItem? = UITabBarItem()
        public static var tabBarApplications    :UITabBarItem? = UITabBarItem()
    }
}
