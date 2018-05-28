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
    /*
         http://nbics.net/VSM.Web.Plugins.Contacts/ContactsHome/GetContactsGroups?Email=1&PasswordHash=06d49632c9dc9bcb62aeaef99612ba6b
         -=Запрос списка групп =- http://nbics.net/VSM.Web.Plugins.Contacts/ContactsHome/GetContactsGroups?Email=1&PasswordHash=06d49632c9dc9bcb62aeaef99612ba6b
         -=Получаем последние N сообщений беседы=-GetConversationLastNMessages(string ConversationId, int N, string Email, string PasswordHash)
         -=Получаем N сообщений беседы после определенного сообщения=-GetConversationNMessagesAfterOrBefore(string ConversationId, string MessageId, int N, bool IsAfter, string Email, string PasswordHash)
         -=Поиск пользователей для добавления в список контактов=- SearchContacts(string Email, string PasswordHash, string SearchString)
         -=Возвращает метадату чата по id=-GetConversationById(string ConversationId, string Email, string PasswordHash)
         -=получить количество непрочитанных сообщений=- GetNotReadedMessagesCount(string Email, string PasswordHash)
         -=последние беседы пользователя=- http://nbics.net/VSM.Web.Plugins.Contacts/ContactsHome/GetUserLastConversationList?Email=1&PasswordHash=06d49632c9dc9bcb62aeaef99612ba6b
         -=Получаем метаданные беседы по Id=- GetConversationFullMetaDataById(string ConversationId, string Email, string PasswordHash)
         -=Получаем метаданные беседы двух пользователей=- GetConversation(string Sender, string Addressee, string Email, string PasswordHash)
         -=Возвращает фотографии пользователей по url=- GetContactsPhotosByUrl(string ContactId, string Email, string PasswordHash)
         -=Запрос списка групп=- http://nbics.net/VSM.Web.Plugins.Contacts/ContactsHome/GetContactsGroups?Email=1&PasswordHash=06d49632c9dc9bcb62aeaef99612ba6b
         -=Запрос списка пользователей группы=-GetContacts(int? GroupId, string Email, string PasswordHash)
    */
        
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
