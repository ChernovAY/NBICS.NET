//
//  VSMData.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 18.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMData{
    private let period:TimeInterval  = 2     // в секундах интервал опроса сервера на предмет наличия новых данных есть - обнавляем модель (без контактоа)
    
    private var timer:RepeatingTimer
    private var timerHandler: Disposable?
    
    private var isWorking            = false
    private var internetStatus       = true

    
    public var NNotReadedMessages      = 0
    public var NNewRequests            = 0

    
    public var Notifications           = [VSMNotification]()//???????
    
    public var Contacts                = Dictionary<Int, VSMContact>()
    public var Conversations           = Dictionary<String,VSMConversation>()
    
    public var Profile : VSMProfile?
    public var Contact : VSMContact?
    
    public init(){
        timer = RepeatingTimer(timeInterval: period)
        timer.eventHandler = timerFired
    }
    deinit{
        timer.suspend()
        timerHandler?.dispose()
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
    public func getContacts(type: VSMContact.ContactType, filter:String = "" )->[VSMContact]{
        let f = filter.lowercased()
        return self.Contacts.values.filter({ $0.ContType == type && (f == "" || $0.Name.lowercased().range(of: f) != nil) }).sorted(by: {$0.Name > $1.Name})
    }
    public func getConversations(filter:String = "" )->[VSMConversation]{
        let f = filter.lowercased()
        return self.Conversations.values.filter({(f == "" || ( ($0.Name == "" && $0.Users.first(where: ({!$0.isOwnContact}))!.Name.lowercased().range(of: f) != nil) || ($0.Name != "" && $0.Name.lowercased().range(of: f) != nil)))}).sorted(by: {$0.LastMessage?.Id ?? "T" < $1.LastMessage?.Id ?? "T"})
    }
    
    public func loadAll(){
        if timerHandler == nil{timerHandler = ETimerAction.addHandler(target: self, handler: VSMData.timerHandlerFunc)}
        if !VSMAPI.Settings.login /*|| isWorking */{return}
         ETimerAction.raise(data: true)
        if Profile == nil{Profile = VSMProfile()}
        if Contact == nil{Contact = VSMContact()}
        Contacts[Contact!.Id] = Contact
        DataLoader.init(entry: .contatcs, delegate: loadContacts, opt: VSMContact.ContactType.Cont, next:
            //DataLoader.init(entry: .contatcs, delegate: loadContacts, opt: VSMContact.ContactType.In, next:
                //DataLoader.init(entry: .contatcs, delegate: loadContacts, opt: VSMContact.ContactType.Out, next:
                    DataLoader.init(entry: .lastConversationList, delegate: loadConversations, next:
                        Loader.init(delegate: { (A, B) in
                            self.EInit.raise(data: true)
                            self.ETimerAction.raise(data: false)
                        })
                    )
                //)
            //)
            
        ).exec()
    }
    public var EInit            =     Event<Bool>()
    public var EMessLoaded      =     Event<String>()
    public var ENUnreadchanged  =     Event<Int>()
    public var EInternetStatus  =     Event<Bool>()
    
    public var ETimerAction     =     Event<Bool>()
    
    private func timerFired(){
        ETimerAction.raise(data: true)
        if internetStatusFlag(){
            let _NNotReadedMessages = NNotReadedMessages
            let _NNewRequests       = NNewRequests
            
            loadAll()///!!!!!!!!tst
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
    private func loadConversations(_ _data:Any, _ _opt:Any){
        let data = _data as! Data
        if let json = try? JSON(data: data) {
            let arr = json.array!
            var oldconv = self.Conversations
            for c in arr{
                if let dict = c.dictionary{
                    let nc = makeConv(what:dict)
                    oldconv = oldconv.filter { $0.key != nc.Id }
                    if let c = Conversations[nc.Id]{
                        let msgs = c.Messages
                        let draft = c.Draft
                        nc.Draft = draft
                        nc.Messages = msgs
                    }
                    Conversations[nc.Id] = nc
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
        ret = VSMConversation(
            Id:                     dict["Id"                      ]!.string!
            ,IsDialog:              dict["IsDialog"                ]!.bool!
            ,LastMessage:           dict["LastMessage"]!.dictionary != nil ? VSMMessage(from:dict["LastMessage"]!.dictionary!) : nil
            ,Messages:              nil
            ,Name:                  dict["Name"                    ]!.string!
            ,NotReadedMessagesCount:dict["NotReadedMessagesCount"  ]!.int!
            ,Users:                 usrs
        )
        return ret
    }

}
//---------------------это потом
open class VSMNotification{
    public let time = Date()
}
