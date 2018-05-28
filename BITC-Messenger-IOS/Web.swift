//
//  WebApi.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import Alamofire

public typealias Params = [String:Any];

public class WebAPI{
    public struct Settings{
        public static var hash         = ""
        public static var caddress    = "https://nbics.net/"
        public static var user         = ""
    }

    public enum WebAPIEntry:String{
    
    case login              = "Account/Login"
    case captcha            = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/CaptchaGet"
    case registration       = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/Registration"
    case contatcs           = "VSM.Web.Plugins.Contacts/ContactsHome/GetContacts"
    case userContactAvatar  = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrl"
    case getIcon            = ""
    case conversations      = "VSM.Web.Plugins.Contacts/ContactsHome/AllChats"
    }
    
    public static func Request (addres:String, entry: WebAPI.WebAPIEntry, postf:String = "", params:Params, completionHandler: @escaping (Any,Bool) -> ()) {
        let request = Alamofire.request(addres + entry.rawValue + postf, method: HTTPMethod.get, parameters: params, headers: nil)
        
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
}
