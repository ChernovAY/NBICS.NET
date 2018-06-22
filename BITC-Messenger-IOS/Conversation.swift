//
//  Conversations.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON


public class VSMConversations{
    public static func VSMConversationsAssync(loadingDelegate: ((VSMConversations)->Void)?=nil){
     VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.lastConversationList, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], completionHandler: {(d,s) in{
     
     if(!s){
        UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
     }
     else{
        if d is Data {
            let data = d as! Data
            let _ = VSMConversations(from: data  , loadingDelegate:loadingDelegate)
        }
     }
     }()}
     )
     }
    
    public var array:[VSMConversation] = Array<VSMConversation>()
    
    public var selectedText = ""
    
    public  var loadingDelegate:((VSMConversations)->Void)? = nil
    public  var loaded:Bool = false{
        didSet {
            if let ld = loadingDelegate{
                if loaded { ld(self)}
            }
        }
    }
    public init(array:[VSMConversation], loadingDelegate:((VSMConversations)->Void)?=nil){
        self.array = array
        if loadingDelegate != nil {self.loadingDelegate = loadingDelegate}
        if self.array.count>0 {loaded = true}
    }
    public init(){
        
    }
    init(from data: Data, loadingDelegate:((VSMConversations)->Void)?=nil)
    {
        if let ld = loadingDelegate{
            self.loadingDelegate = ld
        }
        if let json = try? JSON(data: data) {
            let arr = json.array!
            for c in arr{
                if let dict = c.dictionary{
                    array.append(VSMConversation(from:dict))
                }
            }
            loaded  = true
            if let ld = loadingDelegate { ld(self)}
        }
    }

    public func getConversations()->[VSMConversation]{
        return self.array
    }
}

public class VSMConversation{
    public static let contacts: VSMContacts = VSMContacts() // потом убрать
   
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
    public var Draft: VSMMessage?
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
    public convenience init(from dict:[String:JSON]){
        var usrs = [VSMContact]()///////////!!!!!!!!! Переделать для Data, а это потм удалить!!!!!!!!!!!
        if let usrsJSArray = dict["Users"]?.array{
            for d in usrsJSArray{
                if let dict = d.dictionary{
                    if let c = VSMConversation.contacts.findOrCreate(what: dict){
                        usrs.append(c)
                    }
                }
            }
        }
        self.init(
         Id:                    dict["Id"                      ]!.string!
        ,IsDialog:              dict["IsDialog"                ]!.bool!
        ,LastMessage:           dict["LastMessage"]!.dictionary != nil ? VSMMessage(from:dict["LastMessage"]!.dictionary!) : nil
        ,Messages:              nil
        ,Name:                  dict["Name"                    ]!.string!
        ,NotReadedMessagesCount:dict["NotReadedMessagesCount"  ]!.int!
        ,Users:                 usrs
        )
    }
    public func sendMessage(sendDelegate: ((Bool, String)->Void)? = nil){
        if self.Draft != nil && self.Draft!.isFileUploading || self.Id != "New" {return;}
        let p = ["Message":self.Draft!.getJSON(), "Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash, "UseDraft": "False"] as Params
        
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.sendMessage, params: p, completionHandler: {(d,s) in{
            if(!s){
                print("Ошибка \(d as? String)")
                if let ms = sendDelegate {
                    ms(false, self.Id)
                }
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            if let ms = sendDelegate {
                                ms(true, self.Id)
                            }
                            self.load(isAfter: true)
                        }
                    }
                }
                if let ms = sendDelegate {
                    ms(false, self.Id)
                }
            }
            }()})
    }
    
    public func load(isAfter:Bool=false, loadingDelegate:((Bool, String)->Void)? = nil){
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
                        
                        if let ld = loadingDelegate { ld(retFlag, self.Id)}
                    }
                }
            }
            
            }()}
        )
    }
}
