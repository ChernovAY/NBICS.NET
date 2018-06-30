//
//  Conversations.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMConversation{
  
    private var N:Int = 20
    private var Last:String{
        get{
            return Messages.array.last?.Id ?? ""
        }
    }
    private var First:String{
        get{
            return Messages.array.first?.Id ?? ""
        }
    }
    
    public let Id: String
    public let IsDialog: Bool
    
    public let Name: String
    public var NotReadedMessagesCount: Int
    public var LastMessage: VSMMessage?
    public var Draft: VSMMessage
    public var Users: [VSMContact]
    public var Messages: lms
    
    public init
        (Id:                        String
        ,IsDialog:                  Bool
        ,LastMessage:               VSMMessage?
        ,Messages:                  lms?
        ,Name:                      String
        ,NotReadedMessagesCount:    Int
        ,Users:                     [VSMContact]
        ,Draft:                      VSMMessage?
        ){
        self.Id                     = Id
        self.IsDialog               = IsDialog
        self.LastMessage            = LastMessage
        self.Messages               = Messages ?? lms(Id: Id)
        self.Name                   = Name
        self.NotReadedMessagesCount = NotReadedMessagesCount
        self.Users                  = Users
        self.Draft                  = VSMMessage(ConversationId: Id, Draft: false, Id: nil, Sender: Users.first(where: ({$0.ContType == VSMContact.ContactType.Own})), Text: "", Time: Date())
    }
    private func msgDelegate(_m:[VSMMessage], _ p:Int){
        
    }
    public func sendMessage(){
        if self.Draft.isFileUploading || self.Draft.Id != "New" {return;}
        let p = ["Message":self.Draft.getJSON(), "Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash, "UseDraft": "False"] as Params
        
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.sendMessage, params: p, completionHandler: {(d,s) in{
            if(!s){
                print("Ошибка \(d as? String)")
            }
            else{
                if d is Data {
                    self.Draft = VSMMessage(ConversationId: self.Id, Draft: false, Id: nil, Sender: self.Users.first(where: ({$0.ContType == VSMContact.ContactType.Own})), Text: "", Time: Date())
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            self.Messages.getData(isAfter: true, jamp: true)
                            //VSMAPI.Data.loadAll()
                            return
                        }
                    }
                }
            }
            }()})
    }
    public func markReaded(){
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.messageReaded, params: ["ConversationId":self.Id, "Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash]) { (d, s) in
            if(!s){
                print( "Ошибка \(d as? String)")
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            VSMAPI.Data.ETimerAction.raise(data: true)
                            VSMAPI.Data.NNotReadedMessages = VSMAPI.Data.NNotReadedMessages - self.NotReadedMessagesCount
                            self.NotReadedMessagesCount = 0
                            VSMAPI.Data.ETimerAction.raise(data: false)
                        }
                    }
                }
            }
        }
    }
}
