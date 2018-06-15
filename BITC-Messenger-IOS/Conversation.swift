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
    public class func load(){}
}

public class VSMConversation{
    public static let contacts: VSMContacts = VSMContacts()
    
    public let Id: String
    public let IsDialog: Bool
    public let LastMessage: VSMMessage?
    public let Name: String
    public var NotReadedMessagesCount: Int
    public var Users: [VSMContact]
    
    public init
        (Id:                        String
        ,IsDialog:                  Bool
        ,LastMessage:               VSMMessage?
        //Messages: [] (0) Наверное и не надо
        ,Name:                      String
        ,NotReadedMessagesCount:    Int
        ,Users:                     [VSMContact]
        ){
        self.Id                     = Id
        self.IsDialog               = IsDialog
        self.LastMessage            = LastMessage
        //Messages: [] (0) Наверное и не надо
        self.Name                   = Name
        self.NotReadedMessagesCount = NotReadedMessagesCount
        self.Users                  = Users
    }
    public convenience init(from dict:[String:JSON]){
        var usrs = [VSMContact]()
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
        ,Name:                  dict["Name"                    ]!.string!
        ,NotReadedMessagesCount:dict["NotReadedMessagesCount"  ]!.int!
        ,Users:                 usrs
        )
        
    }
}
