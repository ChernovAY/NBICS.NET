//
//  VSMData.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 18.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

public class VSMData{
    private let period:TimeInterval  = 10     // в секундах интервал опроса сервера на предмет наличия новых данных есть - обнавляем модель (без контактоа)
    
    private var timer:RepeatingTimer
    private var timerHandler: Disposable?
    
    private var isWorking            = false
    private var internetStatus       = true
    
    public var NNotReadedMessages      = 0
    public var NNewRequests            = 0

    
    public var Notifications           = [VSMNotification]()//???????
    
    public var Contacts                = Dictionary<Int, VSMContact>()
    public var Conversations           = Dictionary<String,VSMConversation>()
    public var Configurations          = Dictionary<Int,VSMConfiguration>()
    public var PublicConfigurations    = Dictionary<Int,VSMConfiguration>()
    
    public var Profile : VSMProfile?
    public var Contact : VSMContact?
    //
    public weak var tabBarController:    UITabBarController?
    public weak var chat:      AllChatsViewController?
    public weak var curConv:   ConfigurationsViewController?
    //
    public init(){
        timer = RepeatingTimer(timeInterval: period)
        timer.eventHandler = timerFired
    }
    deinit{
        timer.suspend()
        timerHandler?.dispose()
    }
    public func newConversation(_ name:String)->VSMConversation?{
        var retVal = nil as VSMConversation?
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.AddNewConversation, params: ["Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash, "ConversationName" : name])
        if(z.1){
            let data = z.0 as! Data
            if let json = try? JSON(data: data) {
                if let dict = json.dictionary{
                    if dict["Success"]!.bool!{
                        retVal = makeConv(what:dict["Conversation"]!.dictionary!)
                    }
                }
            }
        }
        else{
            print(z.0)
        }
        return retVal
    }
    public func searchContacts(SearchString:String)->[VSMContact]{
        var retVal = [VSMContact]()
        let sstr = SearchString == "" ? SearchString : "%"+SearchString+"%"
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.SearchContacts, params: ["Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash, "SearchString" : sstr])
        if(z.1){
            let d = z.0 as! Data
            if let json = try? JSON(data: d) {
                let arr = json["Contacts"].array!
                for c in arr{
                    if let dict = c.dictionary{
                        let nc = VSMContact(from:dict)
                        nc.ContType = .Out
                        retVal.append(nc)
                    }
                }
            }
        } else {
            print(z.0)
        }
        return retVal
    }
    
    public func deleteAll(){
        EInit.raise(data: false)
        ETimerAction.raise(data: true)

        Notifications.removeAll()
        Contacts.removeAll()
        Conversations.removeAll()
        Profile = nil
        Contact = nil
    }
    public func getConversationByContact (ContId: Int)->String{
        if let conv = self.Conversations.values.first(where: {$0.Name == "" && $0.Users.filter({$0.Id == ContId}).count>0}){
            return conv.Id
        } else {
            let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.newConversation, params: ["Sender":"{\"Id\":\"\(Contact!.Id)\"}", "Addressee": "{\"Id\":\"\(ContId)\"}", "Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash])
            if(z.1){
                let d = z.0 as! Data
                if let json = try? JSON(data: d) {
                    if let dict = json.dictionary{
                        return makeConv(what:dict).Id
                    }
                }
            } else {
                print(z.0)
            }
        }
        return ""
    }
    public func getContacts(type: VSMContact.ContactType, filter:String = "" )->[VSMContact]{
        let f = filter.lowercased()
        return self.Contacts.values.filter({ $0.ContType == type && (f == "" || $0.Name.lowercased().range(of: f) != nil) }).sorted(by: {$0.Name < $1.Name})
    }
    public func getConversations(filter:String = "" )->[VSMConversation]{
        let f = filter.lowercased()
        return self.Conversations.values.filter({$0.LastMessage != nil && (f == "" || ( ($0.Name == "" && $0.Users.first(where: ({!$0.isOwnContact}))!.Name.lowercased().range(of: f) != nil) || ($0.Name != "" && $0.Name.lowercased().range(of: f) != nil)))}).sorted(by: {$0.LastMessage?.Time ?? Date() > $1.LastMessage?.Time ?? Date()})
    }
    
    public func loadAll(){
        if timerHandler == nil{timerHandler = ETimerAction.addHandler(target: self, handler: VSMData.timerHandlerFunc)}
        if !VSMAPI.Settings.login /*|| isWorking */{return}
         ETimerAction.raise(data: true)
        if Profile == nil{Profile = VSMProfile()}
        if Contact == nil{Contact = VSMContact()}
        Contacts[Contact!.Id] = Contact

        DataLoader.init(entry: .NNotReadedMsgs, delegate: notreadedMessages, next:
            DataLoader.init(entry: .NContReqs, delegate: newReq, next:
                DataLoader.init(entry: .contatcs, delegate: loadContacts, opt: VSMContact.ContactType.Cont, next:
                    DataLoader.init(entry: .Configurations, delegate: loadConfigurations, next:
                        DataLoader.init(entry: .PublicConfigurations, delegate: loadPublicConfigurations, next:
                            DataLoader.init(params:["IsIn":"True", "email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], entry: .ContactsRequests, delegate: loadContacts, opt: VSMContact.ContactType.In, next:
                                DataLoader.init(params:["IsIn":"False", "email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], entry: .ContactsRequests, delegate: loadContacts, opt: VSMContact.ContactType.Out, next:
                                    DataLoader.init(entry: .lastConversationList, delegate: loadConversations, next:
                                        Loader.init(delegate: { (A, B) in
                                            self.EInit.raise(data: true)
                                            self.ETimerAction.raise(data: false)
                                            VSMAPI.VSMChatsCommunication.tabBarApplications?.badgeValue = self.NNewRequests == 0 ? nil : String(self.NNewRequests)
                                            VSMAPI.VSMChatsCommunication.tabBarChats?.badgeValue = self.NNotReadedMessages == 0 ? nil : String(self.NNotReadedMessages)
                                            UIApplication.shared.applicationIconBadgeNumber  = self.NNewRequests + self.NNotReadedMessages
                                        })
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ).exec()
    }
    public var EInit            =     Event<Bool>()
    public var EMessLoaded      =     Event<String>()
    public var ENUnreadchanged  =     Event<Int>()
    public var EInternetStatus  =     Event<Bool>()
    
    public var ETimerAction     =     Event<Bool>()
    
    public var EMessages        =     Event<(String, Int)>()
    
    public func timerFired(){
        ETimerAction.raise(data: true)
        if internetStatusFlag(){
            let _NNotReadedMessages = NNotReadedMessages
            let _NNewRequests       = NNewRequests
            DataLoader.init(entry: .NNotReadedMsgs, delegate: notreadedMessages, next:
                DataLoader.init(entry: .NContReqs, delegate: newReq, next:
                    Loader.init(delegate: { (A, B) in
                        if _NNotReadedMessages != self.NNotReadedMessages || _NNewRequests != self.NNewRequests {
                        //self.EInit.raise(data: true)
                             self.loadAll()
                        } else {
                            self.ETimerAction.raise(data: false)
                        }
                        //VSMAPI.VSMChatsCommunication.tabBarApplications?.badgeValue = self.NNewRequests == 0 ? nil : String(self.NNewRequests)
                        //VSMAPI.VSMChatsCommunication.tabBarChats?.badgeValue = self.NNotReadedMessages == 0 ? nil : String(self.NNotReadedMessages)
                        //UIApplication.shared.applicationIconBadgeNumber  = self.NNewRequests + self.NNotReadedMessages
                    })
                )
            ).exec()
        }
    }
    private func timerHandlerFunc(_ data: Bool){
        isWorking = data
        if data{
            timer.suspend()
        }
        else{
            timer.resume()
        }
    }
    
    private func notreadedMessages(_ _data:Any?, _ _opt:Any?){
        let data = _data as! Data
        if let json = try? JSON(data: data).dictionary! {
            if let n = json["NotReadedMessagesCount"]?.int{
                self.NNotReadedMessages = n
            }
        }
    }
    private func newReq(_ _data:Any?, _ _opt:Any?){
        let data = _data as! Data
        if let n = String(data: data, encoding: .utf8){
            if let newN = Int(n) {
                self.NNewRequests = newN
            }
        }
    }
    private func internetStatusFlag()->Bool{
        if internetStatus != VSMAPI.Connectivity.isConn{
            EInternetStatus.raise(data: VSMAPI.Connectivity.isConn)
            internetStatus = VSMAPI.Connectivity.isConn
        }
        return internetStatus
    }
    private func loadContacts(_ _data:Any?, _ _opt:Any?){
        let data = _data as! Data
        let opt  = _opt as! VSMContact.ContactType
        
        if let json = try? JSON(data: data) {
            let arr = json.array!
            var oldcont = self.Contacts.filter {$1.ContType == opt}
            for c in arr{
                if let dict = c.dictionary{
                    let nc = VSMContact(from:dict)
                    nc.ContType = opt
                    oldcont = oldcont.filter { $0.key != nc.Id }
                    Contacts[nc.Id] = nc
                }
            }
            for dc in oldcont{
                Contacts = Contacts.filter { $0.key != dc.value.Id }
            }
        }
    }
    private func loadConfigurations(_ _data:Any?, _ _opt:Any?){
        let data = _data as! Data
        
        if let json = try? JSON(data: data) {
            let arr = json.array!
            var oldconf = self.Configurations
            var npp = 0
            fillconf(from: arr, oldconf: &oldconf, npp: &npp, target: &Configurations)
            for dc in oldconf{
                Configurations = Configurations.filter { $0.key != dc.value.Id }
            }
        }
    }
    private func fillconf(from arr: [JSON], oldconf: inout Dictionary<Int,VSMConfiguration>, npp:inout Int, target: inout Dictionary<Int,VSMConfiguration>){
        for c in arr{
            if let dict = c.dictionary{
                let nc = VSMConfiguration(from:dict, npp:npp)
                npp = npp + 1
                
                oldconf = oldconf.filter { $0.key != nc.Id }
                target[nc.Id] = nc
                if let arrC = dict["Children"]?.array{
                    fillconf(from: arrC, oldconf: &oldconf, npp:&npp, target: &target)
                }
            }
        }
    }
    private func loadPublicConfigurations(_ _data:Any?, _ _opt:Any?){ 
        let data = _data as! Data
        
        if let json = try? JSON(data: data) {
            let profiles = json.array!
            
            var oldconf = self.PublicConfigurations
            var npp = 0
            for p in profiles{
                let arr = p["Configurations"].array!
                fillconf(from: arr, oldconf: &oldconf, npp: &npp, target: &PublicConfigurations)
            }
            for dc in oldconf{
                PublicConfigurations = PublicConfigurations.filter { $0.key != dc.value.Id }
            }
        }
    }
    
    private func loadConversations(_ _data:Any, _ _opt:Any){
        let data = _data as! Data
        if let json = try? JSON(data: data) {
            let arr = json.array!
            var oldconv = self.Conversations
            for c in arr{
                if let dict = c.dictionary{
                    let nc = makeConv(what:dict)
                    oldconv = oldconv.filter { $0.key != nc.Id }
                }
            }
            for dc in oldconv{
                Conversations = Conversations.filter { $0.key != dc.value.Id }
            }
        }
    }
    private func convContFindOrCreate(what dict:[String:JSON])->VSMContact?{
        var c:VSMContact? = nil
        if let key = dict["Id"]!.int{
            if let c = Contacts[key]{
                if c.ContType != .Conv{
                    return  Contacts[key]!
                }
            }
        }
        c = VSMContact(from:dict)
        c!.ContType = .Conv
        Contacts[c!.Id] = c
        return c
    }
    private func makeConv(what dict:[String:JSON])->VSMConversation{
        var ret:VSMConversation
        var usrs = [VSMContact]()
        if let usrsJSArray = dict["Users"]?.array{
            for d in usrsJSArray{
                if let dict = d.dictionary{
                    if let cc = convContFindOrCreate(what: dict){
                        usrs.append(cc)
                    }
                }
            }
        }
        
        if let c = Conversations[dict["Id"]!.string!]{
            let msgs    = c.Messages
            let draft   = c.Draft
            ret = VSMConversation(
                Id:                     dict["Id"                      ]!.string!
                ,IsDialog:              dict["IsDialog"                ]!.bool!
                ,LastMessage:           dict["LastMessage"]!.dictionary != nil ? VSMMessage(from:dict["LastMessage"]!.dictionary!) : nil
                ,Messages:              msgs
                ,Name:                  dict["Name"                    ]!.string!
                ,NotReadedMessagesCount:dict["NotReadedMessagesCount"  ]!.int!
                ,Users:                 usrs
                ,Draft:                 draft
            )
        } else {
            ret = VSMConversation(
                Id:                     dict["Id"                      ]!.string!
                ,IsDialog:              dict["IsDialog"                ]!.bool!
                ,LastMessage:           dict["LastMessage"]!.dictionary != nil ? VSMMessage(from:dict["LastMessage"]!.dictionary!) : nil
                ,Messages:              nil
                ,Name:                  dict["Name"                    ]!.string!
                ,NotReadedMessagesCount:dict["NotReadedMessagesCount"  ]!.int!
                ,Users:                 usrs
                ,Draft:                 nil
            )
        }
        Conversations[ret.Id] = ret
        return ret
    }

}
//---------------------это потом
open class VSMNotification{
    public let time = Date()
}
