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
    public enum Stage:Int{
        case all = 0
    }
    
    private let period:TimeInterval  = 2     // в секундах интервал опроса сервера на предмет наличия новых данных есть - обнавляем модель (без контактоа)
    private let MaxCounter           = 10
    private let timer:RepeatingTimer
    private var internetStatus       = true
    private var counter              = 0     // счетчик принудительного обращения к серверу 0 = обнавляем контакты
    
    public var NNotReadedMessages      = 0
    public var NNewRequests            = 0
    public var IsReloadNeeded          = false
    
    public var Notifications           = [VSMNotification]()//???????
    
    public var Contacts                = Dictionary<String, VSMContact>()
    public var Messages                = Dictionary<String, [VSMMessage]>()

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
    }
  
    public var InitAll        =     Event<()>()
    public var ContLoaded     =     Event<()>()
    public var ConvLoaded     =     Event<()>()
    public var MessLoaded     =     Event<(String)>()
    public var NUnreadchanged =     Event<(Int)>()
    public var InternetStatus =     Event<(Bool)>()
    
    private func timerFired(){
        if internetStatus != VSMAPI.Connectivity.isConn{
            InternetStatus.raise(data: VSMAPI.Connectivity.isConn)
            internetStatus = VSMAPI.Connectivity.isConn
        }
        if internetStatus{
            
        }
    }
}
//---------------------
open class VSMNotification{
    public let time = Date()
}
