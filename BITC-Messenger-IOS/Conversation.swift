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
            return Messages.last?.Id ?? ""
        }
    }
    private var First:String{
        get{
            return Messages.first?.Id ?? ""
        }
    }
    
    public let Id: String
    public let IsDialog: Bool
    
    public let Name: String
    public var NotReadedMessagesCount: Int
    public var LastMessage: VSMMessage?
    public var Draft: VSMMessage
    public var Users: [VSMContact]
    public var Messages = [VSMMessage]()
    public init
        (Id:                        String
        ,IsDialog:                  Bool
        ,LastMessage:               VSMMessage?
        ,Messages:                  [VSMMessage]?
        ,Name:                      String
        ,NotReadedMessagesCount:    Int
        ,Users:                     [VSMContact]
        ){
        self.Id                     = Id
        self.IsDialog               = IsDialog
        self.LastMessage            = LastMessage
        self.Messages               = Messages ?? [VSMMessage]()
        self.Name                   = Name
        self.NotReadedMessagesCount = NotReadedMessagesCount
        self.Users                  = Users
        self.Draft                  = VSMMessage(ConversationId: Id, Draft: false, Id: nil, Sender: Users.first(where: ({$0.ContType == VSMContact.ContactType.Own})), Text: "", Time: Date())
    }
    public func sendMessage(sendDelegate: ((Bool)->Void)? = nil){
        if self.Draft.isFileUploading || self.Draft.Id != "New" {return;}
        let p = ["Message":self.Draft.getJSON(), "Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash, "UseDraft": "False"] as Params
        
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.sendMessage, params: p, completionHandler: {(d,s) in{
            if(!s){
                print("Ошибка \(d as? String)")
                if let ms = sendDelegate {
                    ms(false)
                }
            }
            else{
                if d is Data {
                    self.Draft = VSMMessage(ConversationId: self.Id, Draft: false, Id: nil, Sender: self.Users.first(where: ({$0.ContType == VSMContact.ContactType.Own})), Text: "", Time: Date())
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            VSMAPI.Data.loadAll()
                            //self.load(isAfter: true,loadingDelegate:sendDelegate)
                        }
                    }
                }
                if let ms = sendDelegate {
                    ms(false)
                }
            }
            }()})
    }
    
    public func load(isAfter:Bool=false, loadingDelegate:((Bool)->Void)? = nil){
        let retFlag = isAfter || self.Last == ""
        let prms = ["ConversationId":Id, "N":N, "IsAfter":isAfter ? "True" : "False", "MessageId":isAfter ? Last : First, "Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash] as [String : Any]
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.conversationMessages, params: prms, completionHandler: {(d,s) in{
            
            if(!s){
                print( "Ошибка \(d as? String)")
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        let arr = json["Messages"].array!
                        var arrMsg = [VSMMessage]()
                        for c in arr{
                            if let dict = c.dictionary{
                                arrMsg.append(VSMMessage(from:dict))
                            }
                        }
                        if isAfter{
                            self.Messages.append(contentsOf: arrMsg)
                        }
                        else
                        {
                            self.Messages.insert(contentsOf: arrMsg, at: 0)
                        }
                        if let ld = loadingDelegate { ld(retFlag)}
                    }
                }
            }
            
            }()}
        )
    }
}
