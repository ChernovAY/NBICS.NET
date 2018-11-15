//
//  Configuration.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 31.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMConfiguration : tree{
    public let Name                     :String
    public let Code                     :String
    public let CType                    :String
    public let Author                   :Int?
    public let Editor                   :Int?

    public let Index                    :Int
    public var ReadOnly                 :Bool // Признак который выставляет автор конфигурации
    public init
    (npp:Int
    ,Id:Int
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
        super.init(npp: npp, Id: Id, Parent: Parent)
    }
    
    public convenience init(from dict:[String:JSON], npp:Int = 0){
        self.init(
            npp:            npp
        ,   Id:             dict["Id"           ]!.int!
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
    
    public func DeleteConfiguration()->Bool{
        var retVal = false
        let conf = "{\"Id\":\(self.Id)}"
        let parm = ["MetaData":conf, "Email": VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash] as [String : Any]
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: .DeleteConfiguration, params: parm)
        if(z.1){
            let data = z.0 as! Data
            if let json = try? JSON(data: data) {
                if json.dictionary!["Success"]!.bool! {
                    retVal = true
                }
            }
        } else {
            print(z.0)
        }
        return retVal
    }
    
    public func getDictionary()->Dictionary<String, Any?>{
        return ["Id":self.Id, "ReadOnly": self.ReadOnly ? "True" : "False"]
    }
    
    public func CopyConfiguration()->Bool{
        var retVal = false

        let parm = ["NodeId":self.Id, "CopyWithChildren":"False", "Email": VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash] as [String : Any]
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: .CopyConfiguration, params: parm)
        if(z.1){
            let data = z.0 as! Data
            if let json = try? JSON(data: data) {
                if json.dictionary!["Success"]!.bool! {
                    retVal = true
                }
            }
        } else {
            print(z.0)
        }
        return retVal
    }
    
}

public class VSMCheckedConfiguration : tree{
    public  var Conf:VSMConfiguration!
    public  var msg:VSMMessage?
    public var Checked:Bool = false{
        didSet{
            if let m = msg{
                let confInMsg = m.AttachedConfs.first(where:({$0.Id == Conf.Id}))
                if Checked && confInMsg == nil{
                    m.AttachedConfs.append(Conf)
                } else if !Checked && confInMsg != nil{
                    m.AttachedConfs = m.AttachedConfs.filter({!($0 === confInMsg)})
                }
            }
        }
    }
    
    public init(_ conf:VSMConfiguration, _ chk:Bool = false){
        super.init(npp: conf.npp, Id: conf.Id, Parent: conf.Parent)
        Conf = conf
        Checked = chk
    }
}
