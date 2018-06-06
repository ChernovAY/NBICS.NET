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

    private var N:Int = 20
    private var Last = ""
    private var ConversationId = ""
    private var array:[VSMMessage] = Array<VSMMessage>()
    
    public var selectedText = ""
    
    public var SArray:[VSMMessage]{ get {
        return array
        }
        set(value){
            self.array = value
        }
    }
    public  var loadingDelegate:((Bool)->Void)? = nil

    public init(ConversationId:String, loadingDelegate:((Bool)->Void)?=nil){
        self.ConversationId = ConversationId
        self.loadingDelegate = loadingDelegate
    }
    
    public convenience init(ConversationId: String, array:[VSMMessage], loadingDelegate:((Bool)->Void)?=nil){
        self.init(ConversationId: ConversationId, loadingDelegate: loadingDelegate)
        
        self.array = array
        if self.array.count>0{
            self.Last = self.array.last!.Id
        }
    }
    convenience init(ConversationId:String, from data: Data, loadingDelegate:((Bool)->Void)?=nil)
    {
        self.init(ConversationId: ConversationId, loadingDelegate: loadingDelegate)
        
        if let json = try? JSON(data: data) {
            let arr = json.array!
            for c in arr{
                if let dict = c.dictionary{
                    array.append(VSMMessage(from:dict))
                }
            }
            if self.array.count>0{
                self.Last = self.array.last!.Id
            }
            if let ld = loadingDelegate { ld(true)}
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
    public func load(){
     
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.conversationMessages, params: ["ConversationId":ConversationId, "N":N, "isAfter":false, "MessageId":Last, "email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash], completionHandler: {(d,s) in{
            
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        let arr = json["Messages"].array!
                        for c in arr{
                            if let dict = c.dictionary{
                                self.array.append(VSMMessage(from:dict))
                            }
                        }
                        if self.array.count>0{
                            self.Last = self.array.last!.Id
                        }
                        if let ld = self.loadingDelegate { ld(true)}
                    }
                }
            }
            }()}
        )
    }
}

 public class VSMMessage{

    private var isFileUploading = false
    public  var AttachedFiles   =  Array<VSMAttachedFile>()
    
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
        ,Id:              String?
        ,Sender:          VSMContact?
        ,Text:            String
        ,Time:            Date
        ,CType:           String
        ,AttachedFiles:   [VSMAttachedFile]?=nil
        )
    {
        self.ConversationId = ConversationId
        self.Draft          = Draft
        self.Id             = Id ?? "New"
        self.Sender         = Sender
        self.Text           = Text
        self.Time           = Time
        self.CType          = ContType.init(rawValue: CType)!
        
        if let af = AttachedFiles {
            self.AttachedFiles  = af
        }
    }
    public convenience init (from dict:[String:JSON]){
        self.init(
            ConversationId: dict["ConversationId"]!.string!
            ,Draft:         dict["Draft"]!.bool!
            ,Id:            dict["Id"]!.string
            ,Sender:        VSMConversation.contacts.findOrCreate(what: dict["Sender"]!.dictionary)
            ,Text:          dict["Text"]!.string!
            ,Time:          Date(fromString: dict["Time"]!.string!)
            ,CType:         dict["Type"]!.string!
        )
        
        if let jsonArr = dict["AttachedFiles"]?.array{
            for jaf in jsonArr{
                if let af = jaf.dictionary{
                    AttachedFiles.append(VSMAttachedFile(from:af))
                }
            }
            
        }
    }
    
    //var m = VSMMessage(ConversationId: self.Id, Draft: false, Id:nil, Sender: nil, Text: "TEEEEEEEEXT!", Time:Date(), CType: ContType.Chat.rawValue)
    //m.sendMessage()
    
    public func sendMessage(sendDelegate: ((VSMMessage)->Void)? = nil){
        if self.isFileUploading {return;}
        let p = ["Message":getJSON(), "Email":WebAPI.Settings.user, "PasswordHash":WebAPI.Settings.hash, "UseDraft": false] as Params
        
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.sendMessage, params: p, completionHandler: {(d,s) in{
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            if let dict = json.dictionary!["Message"]?.dictionary{
                                if let ms = sendDelegate {
                                    ms(VSMMessage(from: dict))
                                }
                            }
                        }
                    }
                }
            }
            }()})
    }
    
    public func uploadFiles(filePath: [String], loadingDelegate:((Int, String)->Void)?){
            let fm = FileManager.default
            for f in filePath{
                if(fm.fileExists(atPath: f)){
                    if let data = fm.contents(atPath: f){
                        //self.Photo = UIImage(data: data)
                    }
                }
            }
        }
        
    public func dropFile(file: String, loadingDelegate:((Bool)->Void)?){
        
    }
    
    public func getJSON(_ forRequest:Bool = true)->String{
        var j:[String:Any]
        if(forRequest){
        var attArray = [Any]()
        for a in self.AttachedFiles{
            attArray.append(a.getJSON())
        }
        j =
        ["ConversationId": ConversationId
        ,"Text": Text
        ,"Sender":["Id":WebAPI.Contact!.Id] as [String : Any]
        ] as [String : Any]
        if attArray.count>0{
            j["AttachedFiles"] = attArray
        }
        }
        else{
            j = [:] as [String:Any]
        }
        return JSON(j).rawString([.castNilToNSNull: true])!
    }
}

public class VSMAttachedFile{
    public let Extension:   String
    public let Guid:        String
    public let Name:        String
    public var PreviewIcon: UIImage?
    
    private func setPrevIcon(_ from : String){
        if(from != ""){
            let dataDecoded  = Data(base64Encoded: from, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            self.PreviewIcon = UIImage(data: dataDecoded)
        }
    }
    
    
    public init (Extension: String, Guid: String, Name: String){
        self.Extension      = Extension
        self.Guid           = Guid
        self.Name           = Name
        self.PreviewIcon    = UIImage(named:"AnyFile")
    }
    public convenience init(from dict:[String:JSON]){
        self.init(
             Extension: dict["Extension"]!.string!
            ,Guid: dict["Guid"]!.string!
            ,Name: dict["Name"]!.string!
        )
        
        if let ds = dict["PreviewIcon"]!.string {
                self.setPrevIcon(ds)
        }
        else {
            //let json = JSON(["Extension":self.Extension, "Guid": self.Guid, "Name":self.Name, "PreviewIcon": nil]).rawString([.castNilToNSNull: true])!
            let json = self.getJSON(false)
            let z = WebAPI.syncRequest(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.filePreviewIcon, params: ["FileMetaData":json])
            var base64 = ""
            if(z.1){
                let d = z.0 as! Data
                if let json = try? JSON(data: d) {
                    if let dict = json.dictionary{
                        if let dd = dict["FileMetaData"]?.dictionary{
                            if let ddd = dd["PreviewIcon"]{
                                if let ds = ddd.string{
                                    base64 = ds
                                }
                            }
                        }
                    }
                    self.setPrevIcon(base64)
                }
            }
            else{
                print(z.0)
            }
        }
    }
    public func getJSON(_ forRequest:Bool = true)->String{
        if self.PreviewIcon != UIImage(named:"AnyFile") && self.PreviewIcon != nil && !forRequest {
            let p = self.PreviewIcon!
            let image64 = UIImagePNGRepresentation(p)?.base64EncodedString()
            return JSON(["Extension":self.Extension, "Guid": self.Guid, "Name":self.Name, "PreviewIcon": image64]).rawString([.castNilToNSNull: true])!
            
        }
        else{
            return JSON(["Extension":self.Extension, "Guid": self.Guid, "Name":self.Name, "PreviewIcon": nil]).rawString([.castNilToNSNull: true])!
        }
    }
}
