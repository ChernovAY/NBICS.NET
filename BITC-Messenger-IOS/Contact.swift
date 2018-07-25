//
//  Contacts.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMContact {
    public enum ContactType:Int{
        case Del = -1, Own, Cont, Conv, In, Out
    }
    public var ContactType  = VSMContact.ContactType.Del{
        willSet(newType){
            
        }
    }
    public var isOwnContact:Bool{
        get{
            return self.ContType == .Own
        }
    }
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
                        _ = VSMAPI.saveFile(name:"Icon_\(self.Id).I", data: data)
                    }
                }
            }
            }()})
        }
        else if Photo != "" {
            if let dataDecoded  = Data(base64Encoded: Photo, options: Data.Base64DecodingOptions.ignoreUnknownCharacters){
                _ = VSMAPI.saveFile(name:"Icon_\(self.Id).I", data: dataDecoded)
            }
        }
    }
    
    public convenience init(from dict:[String:JSON]){
        self.init(
              Id:           dict["Id"           ]!.int!
            , Code:         dict["Code"         ]?.string
            , Alias:        dict["Alias"        ]?.string
            , Name:         dict["Name"         ]!.string ?? ""
            , FirstName:    dict["FirstName"    ]!.string ?? ""
            , SurName:      dict["SurName"      ]!.string ?? ""
            , Patronymic:   dict["Patronymic"   ]!.string ?? ""
            , IsNew:        dict["IsNew"        ]!.bool!
            , IsOnline:     dict["IsOnline"     ]!.bool!
            , ReadOnly:     dict["ReadOnly"     ]!.bool!
            , PhotoUrl:     dict["PhotoUrl"     ]!.string != nil ? dict["PhotoUrl"     ]!.string! : ""
            , Photo:        dict["Photo"        ]!.string != nil ? dict["Photo"        ]!.string! : ""
        )
    }
    public convenience init?(){
        var z : (Any, Bool)
        if VSMAPI.Connectivity.isConn{
            z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.userInformation, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash])
            _ = VSMAPI.saveFile(name: VSMAPI.WebAPIEntry.userInformation.rawValue + ".I", data: z.0 as! Data)
        }
        else{
            if let d = VSMAPI.getFile(name: VSMAPI.WebAPIEntry.userInformation.rawValue + ".I"){
                z = (d,true)
            }
            else{
                z = ("И интернета нет и данные не сохранены",false)
            }
        }
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
    public func UserContactOperations(_ what:VSMAPI.WebAPIEntry)->Bool{
        if !String(describing: what).hasPrefix("Op_") {return false}
        var retVal = false
        let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: what, params: ["Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash, "UserId" : self.Id])
        if(z.1){
            let data = z.0 as! Data
            if let json = try? JSON(data: data) {
                if json.dictionary!["Success"]!.bool! {
                    retVal = true
                }
            }
        }
        else{
            print(z.0)
        }
        return retVal
    }

}
public class VSMCheckedContact{
    public /*weak*/ var Contact:VSMContact!
    public /*weak*/ var Conversation:VSMConversation?
    public var Checked:Bool = false{
        didSet{
            if let conv = Conversation{
                let contInUsers = conv.Users.first(where:({$0.Id == Contact.Id}))
                if Checked && contInUsers == nil{
                  conv.Users.append(Contact)
                }
                else if !Checked && contInUsers != nil{
                    conv.Users = conv.Users.filter({!($0 === contInUsers)})
                }
            }
        }
    }
    public init(_ contact:VSMContact, _ chk:Bool){
        Contact = contact
        Checked = chk
    }
}
