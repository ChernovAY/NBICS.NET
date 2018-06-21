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
    private let MaxCounter           = 10
    
    private var timer:RepeatingTimer
    private var timerHandler: Disposable?
    
    private var isWorking            = false
    private var internetStatus       = true
    private var counter              = 0     // счетчик принудительного обращения к серверу 0 = обнавляем контакты
    
    public var NNotReadedMessages      = 0
    public var NNewRequests            = 0
    public var IsReloadNeeded          = false
    
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
    public func loadAll(){
        if timerHandler == nil{timerHandler = ETimerAction.addHandler(target: self, handler: VSMData.timerHandlerFunc)}
        if !VSMAPI.Settings.login {return}
        if Profile == nil{Profile = VSMProfile()}
        if Contact == nil{Contact = VSMContact()}
        Contacts[Contact!.Id] = Contact
        //loadContacts(loadConversations)
        
        ETimerAction.raise(data: false)
        EInit.raise(data: true)
    }
    public var EInit            =     Event<Bool>()
    public var EContLoaded    =     Event<()>()
    public var EConvLoaded      =     Event<()>()
    public var EMessLoaded      =     Event<String>()
    public var ENUnreadchanged  =     Event<Int>()
    public var EInternetStatus  =     Event<Bool>()
    
    public var ETimerAction     =     Event<Bool>()
    
    private func timerFired(){
        ETimerAction.raise(data: true)
        if internetStatusFlag(){
            
        }
        ETimerAction.raise(data: false)
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
    private func loadContacts(ContactType: VSMContact.ContactType, entry: VSMAPI.WebAPIEntry, delegate:((Any,Any,Any)->())?=nil){
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.contatcs, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], completionHandler: {(d,s) in{
            if(!s){print("Ошибка \(d as? String)")}
            else{
                if d is Data {
                    let data = d as! Data
                    //let _ = VSMContacts(from: data  , loadingDelegate:loadingDelegate)
                    
                    delegate?()
                }
            }
            }()}
        )
    }
    private func loadInRequests(){
        
    }
    private func loadOutRequests(){
        
    }
    private func loadConversations(_ delegate:(()->())?=nil){
        
    }
}
//---------------------это потом
open class VSMNotification{
    public let time = Date()
}
