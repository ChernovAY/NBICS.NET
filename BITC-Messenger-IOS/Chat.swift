//
//  Chats.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON
//
public class VSMMessages{
    /*public static func VSMMessagesAssync(loadingDelegate: ((VSMMessages)->Void)?=nil){
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
    }*/
    
    private var array:[VSMMessage] = Array<VSMMessage>()
    
    public var selectedText = ""
    
    public var SArray:[VSMMessage]{ get {
        return array
        }
    }
    public  var loadingDelegate:((VSMMessages)->Void)? = nil
    public  var loaded:Bool = false{
        didSet {
            if let ld = loadingDelegate{
                if loaded { ld(self)}
            }
        }
    }
    public init(array:[VSMMessage], loadingDelegate:((VSMMessages)->Void)?=nil){
        self.array = array
        if loadingDelegate != nil {self.loadingDelegate = loadingDelegate}
        if self.array.count>0 {loaded = true}
    }
    public init(){
        
    }
    init(from data: Data, loadingDelegate:((VSMMessages)->Void)?=nil)
    {
        if let ld = loadingDelegate{
            self.loadingDelegate = ld
        }
        if let json = try? JSON(data: data) {
            let arr = json.array!
            for c in arr{
                if let dict = c.dictionary{
                    array.append(VSMMessage(from:dict))
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
    public func getMessages(_ what : String?=nil)->[VSMMessage]{
        setFilter(what)
        return self.selectedText == "" ? self.SArray : self.SArray.filter({ $0.Text.lowercased().range(of: self.selectedText) != nil })
    }
    public class func load(){}
}

public class VSMMessage{

    //Этих потом!!!!! SER!!
    //AttachedConfigurations: [] (0)
    //AttachedFiles: [] (0)
    
    public let ConversationId:  String
    public let Draft:           Bool
    public let Id:              String
    public let Sender:          VSMContact?
    public let Text:            String
    public let Time:            Date
    public let CType:           ContType
    public init
        (ConversationId:  String
        ,Draft:           Bool
        ,Id:              String
        ,Sender:          VSMContact?  //!ref
        ,Text:            String
        ,Time:            Date
        ,CType:           String
        )
    {
        self.ConversationId = ConversationId
        self.Draft          = Draft
        self.Id             = Id
        self.Sender         = Sender
        self.Text           = Text
        self.Time           = Time
        self.CType          = ContType.init(rawValue: CType)!
    }
    public convenience init (from dict:[String:JSON]){
        self.init(
            ConversationId: dict["ConversationId"]!.string!
            ,Draft:         dict["Draft"]!.bool!
            ,Id:            dict["Id"]!.string!
            ,Sender:        VSMConversation.contacts.findOrCreate(what: dict["Sender"]!.dictionary)
            ,Text:          dict["Text"]!.string!
            ,Time:          Date(fromString: dict["Time"]!.string!)
            ,CType:         dict["Type"]!.string!
        )
    }
}

public class VSMAttachedFile{
    public let Extension:   String
    public let Guid:        String
    public let Name:        String
    public var PreviewIcon: UIImage?
    
    public init (Extension: String, Guid: String, Name: String){
        
        
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
}
