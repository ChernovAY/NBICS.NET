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
   
    public let BirthDay:    Date
    public let Email:       String
    public let Entity:      Int
    public let FamilyName:  String
    //public let Gender: Object пока без него
    public var Icon:        UIImage?
    public let IconUrl:     String
    public let Name:        String
    //public let Organizations: [Object] пока без них
    public let Patronymic:  String
    public let Phone:       String
    public let Skype:       String
    //public let UserStatus: "" пока без него
    
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
        
        //Фотка-->
        let fm = FileManager.default
        let filename = NSTemporaryDirectory() + "/PIcon_\(self.Entity).I"
        if(fm.fileExists(atPath: filename)){
            if let data = fm.contents(atPath: filename){
                self.Icon = UIImage(data: data)
            }
            else{
                self.Icon = UIImage(named: "EmptyUser")
            }
        }
        else{
            self.Icon = UIImage(named: "EmptyUser")
        }
        //Фотка--<
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
    
}
