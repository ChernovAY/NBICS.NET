//
//  Contacts.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMContacts {
    public static func VSMContactsAssync(loadingDelegate: ((VSMContacts)->Void)?=nil){
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.contatcs, params: ["email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash], completionHandler: {(d,s) in{
            
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    let _ = VSMContacts(from: data  , loadingDelegate:loadingDelegate)
                }
            }
            }()}
        )
    }
    
    private var array:[VSMContact] = Array<VSMContact>()
    
    public var selectedText = ""
    
    public var SArray:[VSMContact]{ get {
        return array
        }
    }
    public  var loadingDelegate:((VSMContacts)->Void)? = nil
    public  var loaded:Bool = false{
        didSet {
            if let ld = loadingDelegate{
                if loaded { ld(self)}
            }
        }
    }
    public init(array:[VSMContact], loadingDelegate:((VSMContacts)->Void)?=nil){
        self.array = array
        if loadingDelegate != nil {self.loadingDelegate = loadingDelegate}
        if self.array.count>0 {loaded = true}
    }
    public init(){
        
    }
    init(from data: Data, loadingDelegate:((VSMContacts)->Void)?=nil)
    {
        if let ld = loadingDelegate{
            self.loadingDelegate = ld
        }
        if let json = try? JSON(data: data) {
            let arr = json.array!
            for c in arr{
                if let dict = c.dictionary{
                    array.append(VSMContact(from:dict))
                }
            }
            loaded  = true
            if let ld = loadingDelegate { ld(self)}
        }
    }
    private func setFilter(_ what:String?=nil){
        if let mask = what{
            self.selectedText = mask.lowercased()
        }
        else if self.selectedText != ""{
            self.selectedText = ""
        }
    }
    public func getContacts(_ what : String?=nil)->[VSMContact]{
        setFilter(what)
        return self.selectedText == "" ? self.SArray : self.SArray.filter({ $0.Name.lowercased().range(of: self.selectedText) != nil })
    }
    public class func load(){}
}
//--------------------------------------------------

public class VSMContact {
    public enum ContType:String {
        case User, Group
    }
    
    public let EntityClass:     Int
    public let EntityId:        Int
    public let EntityType:      Int
    public let EntityGuid:      String
    
    public let Id:              Int64
    public let Code:            String?
    public let Alias:           String?
    public let Name:            String
    public let FirstName:       String
    public let SurName:         String
    public let Patronymic:      String
    
    //public let Devices: Devices
    //public let Groups: Groups
    
    public let Guid:            String
    
    public  var IsNew:           Bool
    public  var IsOnline:        Bool
    public  var ReadOnly:        Bool
    
    public var Photo:           UIImage?
    public var PhotoUrl:        String
    
    public var CType:           ContType
    
    public init
        ( EntityClass:     Int
        , EntityId:        Int
        , EntityType:      Int
        , EntityGuid:      String
        
        , Id:              Int64
        , Code:            String?
        , Alias:           String?
        , Name:            String
        , FirstName:       String
        , SurName:         String
        , Patronymic:      String
        
        //public let Devices: Devices
        //public let Groups: Groups
        , Guid:            String
        
        , IsNew:           Bool
        , IsOnline:        Bool
        , ReadOnly:        Bool
        
        , PhotoUrl:        String
        
        , CType:           String
        ){  self.EntityClass    = EntityClass
        self.EntityId       = EntityId
        self.EntityType     = EntityType
        self.EntityGuid     = EntityGuid
        
        self.Id             = Id
        self.Code           = Code
        self.Alias          = Alias
        self.Name           = Name
        self.FirstName      = FirstName
        self.SurName        = SurName
        self.Patronymic     = Patronymic
        
        //public let Devices: Devices
        //public let Groups: Groups
        self.Guid           = Guid
        
        self.IsNew          = IsNew
        self.IsOnline       = IsOnline
        self.ReadOnly       = ReadOnly
        
        self.PhotoUrl       = PhotoUrl
        
        self.CType          = ContType.init(rawValue: CType)!
        //Иконка-->
        let fm = FileManager.default
        let filename = NSTemporaryDirectory() + "/Icon_\(self.Id).I"
        if(fm.fileExists(atPath: filename)){
            if let data = fm.contents(atPath: filename){
                self.Photo = UIImage(data: data)
            }
            else{
                self.Photo = UIImage(named: "EmptyUser")
            }
        }
        else{
            self.Photo = UIImage(named: "EmptyUser")
        }
        //Иконка--<
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.getIcon, postf:self.PhotoUrl, params: [:], completionHandler: {(d,s) in{
            if(!s){
                print(d as! String)
            }
            else{
                if d is Data {
                    let data = d as! Data
                    
                    if(data.count>0){
                        let fm = FileManager.default
                        let filename = NSTemporaryDirectory() + "/Icon_\(self.Id).I"
                        
                        if(fm.createFile(atPath: filename, contents: data)){
                            self.Photo = UIImage(data: data)
                        }
                    }
                }
            }
            }()})
    }
    public convenience init(from dict:[String:JSON]){
        self.init(
            EntityClass:  dict["EntityClass"  ]!.int!
            , EntityId:     dict["EntityId"     ]!.int!
            , EntityType:   dict["EntityType"   ]!.int!
            , EntityGuid:   dict["EntityGuid"   ]!.string!
            , Id:           dict["Id"           ]!.int64!
            , Code:         dict["Code"         ]?.string
            , Alias:        dict["Alias"        ]?.string
            , Name:         dict["Name"         ]!.string!
            , FirstName:    dict["FirstName"    ]!.string!
            , SurName:      dict["SurName"      ]!.string!
            , Patronymic:   dict["Patronymic"   ]!.string!
            , Guid:         dict["Guid"         ]!.string!
            , IsNew:        dict["IsNew"        ]!.bool!
            , IsOnline:     dict["IsOnline"     ]!.bool!
            , ReadOnly:     dict["ReadOnly"     ]!.bool!
            , PhotoUrl:     dict["PhotoUrl"     ]!.string!
            , CType:        dict["Type"         ]!.string!
        )
    }
    
    //Удалит контакт и пошлет сей факТ на сервер
    public func remove()->Bool{
        return false
    }
}
