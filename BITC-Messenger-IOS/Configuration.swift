//
//  Configuration.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 31.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMConfiguration : tree<Int>{
    //public let Guid: String
    public let Name                     :String
    public let Code                     :String
    //public List<Configuration> Children = new List<Configuration>();
    public let CType                    :String
    public let Author                   :Int?
    public let Editor                   :Int?
    //public DateTime? CreationTime;
    //public DateTime? LastModifyTime;
    public let Index                    :Int
    public var ReadOnly                 :Bool // Признак который выставляет автор конфигурации
    //public var Editable                 :Bool // Признак который показывает можно ли редактировать конфигурацию текущему пользователю
    //public var IsTemplateConfiguration  :Bool // Признак который показывает является ли конфигурация шаблоном
    //public var CreatedFromTemplate      :Bool // Признак который показывает что конфигурация создана из шаблона
    //public VSMConfigSettings Settings = new VSMConfigSettings();

    public init
    (Id:Int
    ,Parent:Int?
    ,Name: String
    ,Code: String
    ,CType:String
    ,Author:Int?
    ,Editor:Int?
    ,Index:Int
    ,ReadOnly:Bool
    ){
        self.Name       = Name
        self.Code       = Code
        self.CType      =  CType
        self.Author     = Author
        self.Editor     = Editor
        self.Index      = Index
        self.ReadOnly   = ReadOnly
        
        super.init(Id: Id, Parent: Parent)
    }
    public convenience init(from dict:[String:JSON]){
        self.init(
            Id:             dict["Id"           ]!.int!
        ,   Parent:         dict["Parent"       ]!.int
        ,   Name:           dict["Name"         ]!.string!
        ,   Code:           dict["Code"         ]!.string!
        ,   CType:          dict["Type"         ]!.string!
        ,   Author:         dict["Author"       ]?.dictionary!["Id"]!.int
        ,   Editor:         dict["Editor"       ]?.dictionary!["Id"]?.int
        ,   Index:          dict["Index"        ]!.int!
        ,   ReadOnly:       dict["ReadOnly"     ]!.bool!
        )
    }
    
}
public class VSMCheckedConfiguration{
    public  var Conf:VSMConfiguration!
    public  var msg:VSMMessage?
    public var Checked:Bool = false{
        didSet{
            if let m = msg{
                let confInMsg = m.AttachedConfs.first(where:({$0.Id == Conf.Id}))
                if Checked && confInMsg == nil{
                    m.AttachedConfs.append(Conf)
                }
                else if !Checked && confInMsg != nil{
                    m.AttachedConfs = m.AttachedConfs.filter({!($0 === confInMsg)})
                }
            }
        }
    }
    public init(_ conf:VSMConfiguration, _ chk:Bool){
        Conf = conf
        Checked = chk
    }
}
