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
    
    private static let period               = 2     // в секундах интервал опроса сервера на предмет наличия новых данных есть - обнавляем модель (без контактоа)
    private static var counter              = 0     // счетчик принудительного обращения к серверу 0 = обнавляем контакты
    private static let MaxCounter           = 10
    
    
    public var NNotReadedMessages      = 0
    public var NNewRequests            = 0
    public var IsReloadNeeded          = false
    
    public var Notifications           = [VSMNotification]()//???????
    
    public var Contacts                = Dictionary<VSMContact.ContactType, [VSMContact]>()
    public var Messages                = Dictionary<String, [VSMMessage]>()

    public var Conversations           = [VSMConversation]()
    
    public var Profile : VSMProfile?
    public var Contact : VSMContact?
    
    public init(){
    
    }
    deinit{
        
    }
    
    
    
}
//---------------------
open class VSMNotification{
    public let time = Date()
}
