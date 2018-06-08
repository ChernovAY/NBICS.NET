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
    
         Скачивание файла=- Download(string FileGuid, string FileName, string FileExtension)
         Получаем preview по Guid=- GetFilePreviewIcon(string FileMetaData)
         Получаем изображение файла картинки в base64=- GetFileImage(string FileMetaData)
         
         
         Загрузка файла для сообщения =- UploadMessageFileWithoutDraft(IFormFile File, string Email, string PasswordHash)
         Удаление прикрепленного файла с сервера =- RemoveMessageFileFromServerWithoutDraft(string FileMetaData, string Email, string PasswordHash)
         Поиск пользователей для добавления в список контактов=- SearchContacts(string Email, string PasswordHash, string SearchString)
         Сообщение прочитано=- SetConversationMessagesReaded(string ConversationId, string Email, string PasswordHash)
         Возвращает информацию о пользователе по его Id =- GetUserProfile(int UserId, string Email, string PasswordHash)
         
         Отправка сообщения списка групп =- SendMessage(string Message, string NotificationSettings, string Email, string PasswordHash, bool UseDraft = true)
    
    */
        case login                  = "Account/Login" //+++
        case captcha                = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/CaptchaGet"
        case registration           = "VSM.Web.Plugins.BaseRegistration/BaseRegistrationHome/Registration"
    
        case userInformation        = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserInformation" //+++
        case profile                = "VSM.Web.Plugins.NProfile/NProfileHome/GetUserProfileApi"  //+++
        case setProfile             = "VSM.Web.Plugins.NProfile/NProfileHome/SetUserProfile"
        
        case contatcs               = "VSM.Web.Plugins.Contacts/ContactsHome/GetContacts"        //+++
        case userContactAvatar      = "VSM.Web.Plugins.Contacts/ContactsHome/GetContactsPhotosByUrl"
        case getIcon                = ""    //+++
    
        case lastConversationList   = "VSM.Web.Plugins.Contacts/ContactsHome/GetUserLastConversationList"   //+++
    
        case download               = "VSM.Web.Plugins.Contacts/ContactsHome/Download"
        case filePreviewIcon        = "VSM.Web.Plugins.Contacts/ContactsHome/GetFilePreviewIcon"    //+++
        case fileImage              = "VSM.Web.Plugins.Contacts/ContactsHome/GetFileImage"
        
        case conversationMessages   = "VSM.Web.Plugins.Contacts/ContactsHome/GetConversationNMessagesAfterOrBefore" //+++
        case messageReaded          = "VSM.Web.Plugins.Contacts/ContactsHome/SetConversationMessagesReaded"
        case sendMessage            = "VSM.Web.Plugins.Contacts/ContactsHome/SendMessage"
        
        case fileUpload             = "VSM.Web.Plugins.Contacts/ContactsHome/UploadMessageFileWithoutDraft"
        case fileDrop               = "VSM.Web.Plugins.Contacts/ContactsHome/RemoveMessageFileFromServerWithoutDraft"
        
    
    }
    /*{"FileMetaData":{"Guid":"4eb666d5-3731-4ac1-bcbf-8be4372c47a3","Name":"PIcon_-2147468100","Extension":"I","DownloadURL":"/VSM.Web.Plugins.Contacts/ContactsHome/Download/?FileGuid=4eb666d5-3731-4ac1-bcbf-8be4372c47a3&FileName=PIcon_-2147468100&FileExtension=I","PreviewIcon":null,"ImageBase64":null},"Success":true,"Message":null}*/
    //потом перекинуть в правильное меесто!
    //public static func dropFile()
    public static func upload(filePath:String, loadedDelegate: @escaping (VSMAttachedFile)->Void, progressDelegate: @escaping (Double)->Void){
       let url = URL(fileURLWithPath: filePath)
       let hostUrl = "\(Settings.caddress)\(WebAPIEntry.fileUpload.rawValue)"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "File")
                multipartFormData.append(Settings.user.data(using: String.Encoding.utf8)!, withName: "Email")
                multipartFormData.append(Settings.hash.data(using: String.Encoding.utf8)!, withName: "PasswordHash")
            },
           to: hostUrl,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    //upload.responseString { response in
                    //    debugPrint(response)
                    //    }
                    upload.uploadProgress { progress in // main queue by default
                        progressDelegate(progress.fractionCompleted)
                        
                    }
                    upload.response{ response in
                        if let data = response.data{
                            if let dict = JSON(data).dictionary!["FileMetaData"]?.dictionary{
                                loadedDelegate(VSMAttachedFile(from: dict))
                            }
                        }
                        //print(String(data: response.data! ,encoding: String.Encoding.utf8)!)
                    }

                case .failure(let encodingError):
                    debugPrint(encodingError)
                }
        }
        )
    }
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
    public static var UserContacts = VSMContacts()
    public static var UserConversations = VSMConversations()
    public static var Profile : VSMProfile?
    public static var Contact : VSMContact?
    
    public struct VSMChatsCommunication{
        public static var conversetionId = ""
    }
}
