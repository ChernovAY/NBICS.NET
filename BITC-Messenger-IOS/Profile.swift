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
    private var p               = [String:Any]()
    private var newPasswordHash = ""{didSet{p["newPasswordHash"] = newPasswordHash  ;   p["oldPasswordHash"] = WebAPI.Settings.hash }}
    
    public let Email:       String
    public let Entity:      Int
    public let IconUrl:     String
    
    public var BirthDay:    Date    {didSet{p["birthDay"] = BirthDay                ;                                               }}
    public var Name:        String  {didSet{p["name"] = Name                        ;   p["nameUpdateFlag"] = true                  }}
    public var Patronymic:  String  {didSet{p["patronymic"] = Patronymic            ;   p["patronymicUpdateFlag"] = true            }}
    public var Phone:       String  {didSet{p["phone"] = Phone                      ;   p["phoneUpdateFlag"] = true                 }}
    public var Skype:       String  {didSet{p["skype"] = Skype                      ;   p["phoneUpdateFlag"] = true                 }}
    public var FamilyName:  String  {didSet{p["familyName"] = FamilyName            ;   p["familyNameUpdateFlag"] = true            }}
    public var Icon:        UIImage?{didSet{p["icon"] = Icon                        ;   p["photoUpdateFlag"] = true                 }}
    //public let Organizations: [Object] пока без них

    
    public init (
        BirthDay: Date
        ,Email: String
        ,Entity: Int
        ,FamilyName: String
        ,Icon: String
        ,IconUrl: String
        ,Name: String
        ,Patronymic: String
        ,Phone: String
        ,Skype: String
        ){
            self.BirthDay = BirthDay
            self.Email = Email
            self.Entity = Entity
            self.FamilyName = FamilyName
            self.IconUrl = IconUrl
            self.Name = Name
            self.Patronymic = Patronymic
            self.Phone = Phone
            self.Skype = Skype
        
        self.Icon = WebAPI.getPicture(name: "PIcon_\(self.Entity).I", empty: "EmptyUser")
    
        if (self.IconUrl != "") {
            let z = WebAPI.syncRequest(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.getIcon, postf:self.IconUrl, params: [:])
            if(!z.1){
                print(z.0 as! String)
            }
            else{
                 if z.0 is Data {
                    let data = z.0 as! Data
                    if(data.count>0){
                        let fm = FileManager.default
                        let filename = NSTemporaryDirectory() + "/PIcon_\(self.Entity).I"
                        if(fm.createFile(atPath: filename, contents: data)){
                            self.Icon = UIImage(data: data)
                        }
                    }
                }
            }
        }
        else if Icon != "" {
            if let dataDecoded  = Data(base64Encoded: Icon, options: Data.Base64DecodingOptions.ignoreUnknownCharacters){
                self.Icon = UIImage(data: dataDecoded)
                let fm = FileManager.default
                let filename = NSTemporaryDirectory() + "/PIcon_\(self.Entity).I"
                fm.createFile(atPath: filename, contents: dataDecoded)
            }
            else{
                self.Icon = UIImage(named: "EmptyUser")
            }
        }
    }
    public convenience init?(){
        let z = WebAPI.syncRequest(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.profile, params: ["email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash])
        if(z.1){
            let d = z.0 as! Data
            if let json = try? JSON(data: d) {
                if let dict = json.dictionary{
                    
                      self.init(
                        BirthDay: Date.init(fromString: dict["BirthDay"]!.string!)
                        , Email: dict["Email"]!.string!
                        , Entity: dict["Entity"]!.int!
                        , FamilyName: dict["FamilyName"]!.string!
                        , Icon: ""
                        , IconUrl: dict["IconUrl"]!.string!
                        , Name: dict["Name"]!.string!
                        , Patronymic: dict["Patronymic"]!.string!
                        , Phone: dict["Phone"]!.string!
                        , Skype: dict["Skype"]!.string!
                    )
                    return
                }
            }
        }
        else{
            print(z.0)
        }
        return nil
    }
    public func set()->Bool{
        if self.p.count != 0 {
            p["Email"] = WebAPI.Settings.user
            p["PasswordHash"] = WebAPI.Settings.hash
            p["byMobile"] = true
            let r = WebAPI.syncRequest(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.setProfile, params: ["ProfileItem" : JSON(p).rawString([.castNilToNSNull: true])!])
            if !r.1{
                UIAlertView(title: "Ошибка", message: r.0 as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                return false
            }
            else{
                print(r.0 as! Data)
                if let nph = p["newPasswordHash"]{ //!!!!!!Может не сработать!!!
                    WebAPI.Settings.hash = nph as! String
                }
                return true
            }
        }
        return false
    }
    
}
