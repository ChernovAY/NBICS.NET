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

public enum ContType:String {
    case User, Group, Chat
}

public class WebAPI{
    public struct Settings{
        public static var hash         = ""
        public static var caddress     = "https://nbics.net/"
        public static var user         = ""
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
    public static func syncRequest(addres:String, entry: WebAPI.WebAPIEntry, postf:String = "", params:Params)->(Any,Bool){
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
    
    public static func Request (addres:String, entry: WebAPI.WebAPIEntry, postf:String = "", method: HTTPMethod = HTTPMethod.get, params:Params, completionHandler: @escaping (Any,Bool) -> ()) {
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
    //public s
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
}
