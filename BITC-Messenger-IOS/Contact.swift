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
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.contatcs, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], completionHandler: {(d,s) in{
            
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
    
    public var array:[VSMContact] = Array<VSMContact>()
    public var selectedText = ""
    
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
        return self.selectedText == "" ? self.array : self.array.filter({ $0.Name.lowercased().range(of: self.selectedText) != nil })
    }

    public func addIfNotExists(from a:[VSMContact]){
        
        for ai in a{
            if let af = array.first(where: ({$0.Id == ai.Id})){
                //af.IsNew
                continue
            }
            else{
                array.append(ai)
            }
        }
    }

    public func findOrCreate(what dict:[String:JSON]?)->VSMContact?{
        if let d = dict{
            let id = d["Id"]!.int64!
            if let c = array.first(where: ({$0.Id == id})){
                return c
            }
            else{
                let c = VSMContact(from:d)
                array.append(c)
                return c
            }
        }
        else{
            return nil
        }
    }
    public class func load(){}
}
//--------------------------------------------------

public class VSMContact {
    public enum ContactType:Int{
        case Del = -1, Own, Cont, Conv, In, Out, Cand, Sel
    }
    public var ContactType  = VSMContact.ContactType.Del{
        willSet(newType){
            
        }
    }
    public var isOwnContact = false // потом убрать
    public var ContType         = VSMContact.ContactType.Del
    public let Id:              Int
    public let Code:            String?
    public let Alias:           String?
    public let Name:            String
    public let FirstName:       String
    public let SurName:         String
    public let Patronymic:      String
    
    //public let Devices: Devices
    //public let Groups: Groups
    
   
    public  var IsNew:           Bool
    public  var IsOnline:        Bool
    public  var ReadOnly:        Bool
    
    public var Photo:           UIImage?{
        get{
            return VSMAPI.getPicture(name: "Icon_\(self.Id).I", empty: "EmptyUser")
        }
    }
    public var PhotoUrl:        String
    

    public init
        ( Id:              Int
        , Code:            String?
        , Alias:           String?
        , Name:            String
        , FirstName:       String
        , SurName:         String
        , Patronymic:      String
        
        //public let Devices: Devices
        //public let Groups: Groups
   
        , IsNew:           Bool
        , IsOnline:        Bool
        , ReadOnly:        Bool
        
        , PhotoUrl:        String
        
        , Photo:           String = ""
        ){
        self.Id             = Id
        self.Code           = Code
        self.Alias          = Alias
        self.Name           = Name
        self.FirstName      = FirstName
        self.SurName        = SurName
        self.Patronymic     = Patronymic
        
        //public let Devices: Devices
        //public let Groups: Groups
        
        self.IsNew          = IsNew
        self.IsOnline       = IsOnline
        self.ReadOnly       = ReadOnly
        
        self.PhotoUrl       = PhotoUrl
        
        if (self.PhotoUrl != "") {
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.getIcon, postf:self.PhotoUrl, params: [:], completionHandler: {(d,s) in{
            if(!s){
                print(d as! String)
            }
            else{
                if d is Data {
                    let data = d as! Data
                    
                    if(data.count>0){
                        _ = VSMAPI.savePicture(name:"Icon_\(self.Id).I", data: data)
                    }
                }
            }
            }()})
        }
        else if Photo != "" {
            if let dataDecoded  = Data(base64Encoded: Photo, options: Data.Base64DecodingOptions.ignoreUnknownCharacters){
                _ = VSMAPI.savePicture(name:"Icon_\(self.Id).I", data: dataDecoded)
            }
        }
    }
    
    public convenience init(from dict:[String:JSON]){
        self.init(
              Id:           dict["Id"           ]!.int!
            , Code:         dict["Code"         ]?.string
            , Alias:        dict["Alias"        ]?.string
            , Name:         dict["Name"         ]!.string!
            , FirstName:    dict["FirstName"    ]!.string!
            , SurName:      dict["SurName"      ]!.string!
            , Patronymic:   dict["Patronymic"   ]!.string!
            , IsNew:        dict["IsNew"        ]!.bool!
            , IsOnline:     dict["IsOnline"     ]!.bool!
            , ReadOnly:     dict["ReadOnly"     ]!.bool!
            , PhotoUrl:     dict["PhotoUrl"     ]!.string != nil ? dict["PhotoUrl"     ]!.string! : ""
            , Photo:        dict["Photo"        ]!.string != nil ? dict["Photo"        ]!.string! : ""
        )
    }
    public convenience init?(){
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.userInformation, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash])
        if(!z.1){
            print("Ошибка \(z.0 as? String)")
        }
        else{
            if z.0 is Data {
                let data = z.0 as! Data
                if let json = try? JSON(data: data) {
                    let dict = json.dictionary!
                    self.init(from: dict)
                    ContType = .Own
                    return
                }
            }
        }
        return nil
    }
    
    //Удалит контакт и пошлет сей факТ на сервер
    /*public func remove()->Bool{
        return false
    }*/
}
