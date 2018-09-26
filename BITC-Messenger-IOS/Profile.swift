//
//  Profile.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 04.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class VSMProfile{
    private var p               = Dictionary<String,Any>()
    private var newPasswordHash = ""{didSet{p["newPasswordHash"] = newPasswordHash  ;   p["oldPasswordHash"] = VSMAPI.Settings.hash }}
    
    public let Email:       String
    public let Entity:      Int?
    public let IconUrl:     String
    
    public var BirthDay:    Date    {didSet{p["birthDay"] = BirthDay.toServerTimeString()                ;                                               }}
    public var Name:        String  {didSet{p["name"] = Name                                             ;   p["nameUpdateFlag"] = true                  }}
    public var Patronymic:  String  {didSet{p["patronymic"] = Patronymic                                 ;   p["patronymicUpdateFlag"] = true            }}
    public var Phone:       String  {didSet{p["phone"] = Phone                                           ;   p["phoneUpdateFlag"] = true                 }}
    public var Skype:       String  {didSet{p["skype"] = Skype                                           ;   p["phoneUpdateFlag"] = true                 }}
    public var FamilyName:  String  {didSet{p["familyName"] = FamilyName                                 ;   p["familyNameUpdateFlag"] = true            }}
    public var Icon:        UIImage?{
        didSet{
            if let i = Icon{
                let imageData = UIImagePNGRepresentation(i)
                let idString = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
                p["icon"] =  idString
                p["photo"] = idString
                p["photoUpdateFlag"] = true
            }
        }
        
    }
    //public let Organizations: [Object] пока без них
    
    public init (
        BirthDay: Date
        ,Email: String
        ,Entity: Int?
        ,FamilyName: String
        ,Icon: String
        ,IconUrl: String
        ,Name: String
        ,Patronymic: String
        ,Phone: String
        ,Skype: String
        ){
            self.BirthDay   = BirthDay
            self.Email      = Email
            self.Entity     = Entity
            self.FamilyName = FamilyName
            self.IconUrl    = IconUrl
            self.Name       = Name
            self.Patronymic = Patronymic
            self.Phone      = Phone
            self.Skype      = Skype

        if (self.IconUrl != "") {
            let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.getIcon, postf:self.IconUrl, params: [:])
            if(!z.1){
                print(z.0 as! String)
            } else {
                 if z.0 is Data {
                    let data = z.0 as! Data
                    if(data.count>0){
                        _ = VSMAPI.saveFile(name:"PIcon_\(String(describing: self.Entity)).I", data: data)
                    }
                }
            }
        } else if Icon != "" {

            if let dataDecoded  = Data(base64Encoded: Icon, options: Data.Base64DecodingOptions.ignoreUnknownCharacters){
                _ = VSMAPI.saveFile(name:"PIcon_\(String(describing: self.Entity)).I", data: dataDecoded)
            }
        }
        self.Icon = VSMAPI.getPicture(name: "PIcon_\(String(describing: self.Entity)).I", empty: "EmptyUser")
    }
    public convenience init?(UserId:Int){
        var z : (Any, Bool)
        if VSMAPI.Connectivity.isConn{
            z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.contactProfile, params: ["UserId":UserId, "Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash])
            if(z.1){
                let d = z.0 as! Data
                if let json = try? JSON(data: d) {
                    if let dict = json.dictionary{
                        self.init(
                            BirthDay: Date.init(fromString: dict["BirthDay"]!.string!)
                            , Email: dict["Email"]!.string ?? ""
                            , Entity: dict["EntityId"]!.int
                            , FamilyName: dict["FamilyName"]!.string ?? ""
                            , Icon: ""
                            , IconUrl: dict["PhotoUrl"]!.string!
                            , Name: dict["Name"]!.string ?? ""
                            , Patronymic: dict["Patronymic"]!.string ?? ""
                            , Phone: dict["Phone"]!.string ?? ""
                            , Skype: dict["Skype"]!.string ?? ""
                        )
                        return
                    }
                }
            } else {
                print(z.0)
            }
        }
            return nil
    }
    public convenience init?(){
        var z : (Any, Bool)
        if VSMAPI.Connectivity.isConn{
            z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.profile, params: ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash])
            _ = VSMAPI.saveFile(name: VSMAPI.WebAPIEntry.profile.rawValue + ".I", data: z.0 as! Data)
        } else {
            if let d = VSMAPI.getFile(name: VSMAPI.WebAPIEntry.profile.rawValue + ".I"){
                z = (d,true)
            } else {
                z = ("И интернета нет и данные не сохранены",false)
            }
        }
        if(z.1){
            let d = z.0 as! Data
            if let json = try? JSON(data: d) {
                if let dict = json.dictionary{
                      self.init(
                        BirthDay: Date.init(fromString: dict["BirthDay"]!.string!)
                        , Email: dict["Email"]!.string ?? ""
                        , Entity: dict["Entity"]!.int
                        , FamilyName: dict["FamilyName"]!.string!
                        , Icon: ""
                        , IconUrl: dict["IconUrl"]!.string ?? ""
                        , Name: dict["Name"]!.string!
                        , Patronymic: dict["Patronymic"]!.string!
                        , Phone: dict["Phone"]!.string!
                        , Skype: dict["Skype"]!.string!
                    )
                    return
                }
            }
        } else {
            print(z.0)
        }
        return nil
    }
    public func setChanges()->Bool{
        if self.p.count != 0 {
            p["Email"] = VSMAPI.Settings.user
            p["PasswordHash"] = VSMAPI.Settings.hash
            p["byMobile"] = true
            let r = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.setProfile, method: .post, params: ["ProfileItem" : JSON(p).rawString([.castNilToNSNull: true])!])
            if !r.1{
                UIAlertView(title: "Ошибка", message: r.0 as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                return false
            } else {
                if let d = r.0 as? Data{
                    if let json = try? JSON(data: d){
                        print(json)
                    }
                    if let nph = p["newPasswordHash"]{ //!!!!!!Может не сработать!!!
                        VSMAPI.Settings.hash = nph as! String
                    }

                    return true
                }
            }
        }
        p = Dictionary<String,Any>()
        return false
    }
    
}
