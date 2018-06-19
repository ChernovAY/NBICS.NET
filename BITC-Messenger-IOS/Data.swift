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
    
    public var Contacts                = Dictionary<String, VSMContact>()
    public var Conversations           = Dictionary<String,VSMConversation>()
    
    public var Profile : VSMProfile?
    public var Contact : VSMContact?
    
    public init(){
        timer = RepeatingTimer(timeInterval: period)
        timer.eventHandler = timerFired
        timer.resume()
    }
    deinit{
        timer.suspend()
        timerHandler?.dispose()
    }
    public func loadAll(){
        if timerHandler == nil{timerHandler = ETimerAction.addHandler(target: self, handler: VSMData.timerHandlerFunc)}
    }
    public var EInitAll        =     Event<()>()
    public var EContLoaded     =     Event<()>()
    public var EConvLoaded     =     Event<()>()
    public var EMessLoaded     =     Event<String>()
    public var ENUnreadchanged =     Event<Int>()
    public var EInternetStatus =     Event<Bool>()
    
    public var ETimerAction   =     Event<Bool>()
    
    private func timerFired(){
        print("TimefFired \(Date().toTimeString())")
        ETimerAction.raise(data: false)
        if internetStatusFlag(){
            
        }
        ETimerAction.raise(data: true)
    }
    private func timerHandlerFunc(_ data: Bool){
        isWorking = data
        if data{
            timer.resume()
        }
        else{
            timer.suspend()
        }
    }
    private func internetStatusFlag()->Bool{
        if internetStatus != VSMAPI.Connectivity.isConn{
            EInternetStatus.raise(data: VSMAPI.Connectivity.isConn)
            internetStatus = VSMAPI.Connectivity.isConn
        }
        return internetStatus
    }
}
//---------------------это потом
open class VSMNotification{
    public let time = Date()
}
