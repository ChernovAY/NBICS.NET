//
//  Chats.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 28.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
//
public class VSMMessages{

    private var N:Int = 20
    private var Last = ""
    private var First = ""
    private var ConversationId = ""
    
    public var array:[VSMMessage] = Array<VSMMessage>()
    
    public var selectedText = ""
    
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
                self.First = self.array.first!.Id
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
        return self.selectedText == "" ? self.array : self.array.filter({ $0.Text.lowercased().range(of: self.selectedText) != nil })
    }
    public func load(isAfter:Bool=false){
        let prms = ["ConversationId":ConversationId, "N":N, "IsAfter":isAfter ? "True" : "False", "MessageId":isAfter ? Last : First, "Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash] as [String : Any]
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.conversationMessages, params: prms, completionHandler: {(d,s) in{
            
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        let arr = json["Messages"].array!
                        var arrMsg = [VSMMessage]()
                        for c in arr{
                            if let dict = c.dictionary{
                                arrMsg.append(VSMMessage(from:dict))
                            }
                        }
                        if isAfter{
                            self.array.append(contentsOf: arrMsg)
                        }
                        else
                        {
                            self.array.insert(contentsOf: arrMsg, at: 0)
                        }

                        if self.array.count>0{
                            self.Last = self.array.last!.Id
                            self.First = self.array.first!.Id
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
    public init
        (ConversationId:  String
        ,Draft:           Bool
        ,Id:              String?
        ,Sender:          VSMContact?
        ,Text:            String
        ,Time:            Date
        ,AttachedFiles:   [VSMAttachedFile]?=nil
        )
    {
        self.ConversationId = ConversationId
        self.Draft          = Draft
        self.Id             = Id ?? "New"
        self.Sender         = Sender
        self.Text           = Text
        self.Time           = Time
        
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
        )
        
        if let jsonArr = dict["AttachedFiles"]?.array{
            for jaf in jsonArr{
                if let af = jaf.dictionary{
                    AttachedFiles.append(VSMAttachedFile(from:af))
                }
            }
            
        }
    }
    
    public func sendMessage(Messages: VSMMessages? = nil, sendDelegate: ((Bool)->Void)? = nil){
        if self.isFileUploading || self.Id != "New" {return;}
        let p = ["Message":getJSON(), "Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash, "UseDraft": "False"] as Params
        
        VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.sendMessage, params: p, completionHandler: {(d,s) in{
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
                if let ms = sendDelegate {
                    ms(false)
                }
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        if json.dictionary!["Success"]!.bool! {
                            if let ms = sendDelegate {
                                 ms(true)
                            }
                            if let mss = Messages{
                                mss.load(isAfter: true)
                            }
                        }
                    }
                }
                if let ms = sendDelegate {
                    ms(false)
                }
            }
            }()})
    }
    
    public func attachFile(filePath: String, progressDelegate: @escaping (Double)->Void){
        self.isFileUploading = true
        VSMAttachedFile.upload(filePath: filePath, loadedDelegate: {af in {
                self.AttachedFiles.append(af)
                self.isFileUploading = false
            }()}, progressDelegate: progressDelegate)
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
        ,"Sender":["Id":VSMAPI.Contact!.Id] as [String : Any]
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
    
    public static func upload(filePath:String, loadedDelegate: @escaping (VSMAttachedFile)->Void, progressDelegate: @escaping (Double)->Void){
        let url = URL(fileURLWithPath: filePath)
        let hostUrl = "\(VSMAPI.Settings.caddress)\(VSMAPI.WebAPIEntry.fileUpload.rawValue)"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "File")
                multipartFormData.append(VSMAPI.Settings.user.data(using: String.Encoding.utf8)!, withName: "Email")
                multipartFormData.append(VSMAPI.Settings.hash.data(using: String.Encoding.utf8)!, withName: "PasswordHash")
        },
            to: hostUrl,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in // main queue by default
                        progressDelegate(progress.fractionCompleted)
                    }
                    upload.response{ response in
                        if let data = response.data{
                            if let dict = JSON(data).dictionary!["FileMetaData"]?.dictionary{
                                loadedDelegate(VSMAttachedFile(from: dict))
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    debugPrint(encodingError)
                }
        }
        )
    }
    
    public let Extension:   String
    public let Guid:        String
    public let Name:        String
    public var PreviewIcon: UIImage?
    public var ImageBase64: UIImage?
    
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
            let json = self.getJSON(false)
            let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.filePreviewIcon, params: ["FileMetaData":json])
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
    
    //сохранять!!!!!
    public func getFileImage()->Bool{
        let req = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.fileImage, params: ["FileMetaData": getJSON()])
        if(req.1){
            if let j = JSON(req.0).dictionary{
                if (j["Success"]?.bool!)!{
                    let base64 = j["FileMetaData"]!.dictionary!["ImageBase64"]!.string
                    self.setFileImage(base64!)
                    return true
                }
            }
        }
        else{
            print(req.0)
        }
        return false
    }
    public func download(loadedDelegate: @escaping (Bool)->Void, progressDelegate: @escaping (Double)->Void){
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("\(self.Name).\(self.Extension)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let urlstr = "\(VSMAPI.Settings.caddress)\(VSMAPI.WebAPIEntry.download.rawValue)?FileGuid=\(self.Guid)&FileName=\(self.Name)&FileExtension=\(self.Extension)"
        Alamofire.download(urlstr, to: destination)
            .downloadProgress { progress in
                progressDelegate(progress.fractionCompleted)
            }
            .responseData { response in
                loadedDelegate(response.result.isSuccess)
        }
    }
    public func dropFile()->Bool{
        let req = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.fileDrop, params: ["FileMetaData": getJSON(),"Email":VSMAPI.Settings.user, "PasswordHash":VSMAPI.Settings.hash])
        if(req.1){
            if let j = JSON(req.0).dictionary{
                return (j["Success"]?.bool)!
            }
        }
        else{
            print(req.0)
        }
        return false
    }
    //------------------------------------------
    private func setPrevIcon(_ from : String){
        if(from != ""){
            let dataDecoded  = Data(base64Encoded: from, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            self.PreviewIcon = UIImage(data: dataDecoded)
        }
    }
    private func setFileImage(_ from : String){
        if(from != ""){
            let dataDecoded  = Data(base64Encoded: from, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            self.ImageBase64 = UIImage(data: dataDecoded)
        }
    }
    
}
