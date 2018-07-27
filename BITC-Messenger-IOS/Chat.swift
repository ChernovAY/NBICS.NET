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

 public class VSMMessage{

    
    public var isFileUploading = false
    public var AttachedFiles   =  Array<VSMAttachedFile>()
    
    public let part          :  Int?
    public let ConversationId:  String
    public let Draft:           Bool
    public let Id:              String
    public let Sender:          VSMContact?
    public var Text:            String
    public let Time:            Date
    public init
        (ConversationId:  String
        ,Draft:           Bool
        ,Id:              String?
        ,Sender:          VSMContact?
        ,Text:            String
        ,Time:            Date
        ,AttachedFiles:   [VSMAttachedFile]?=nil
        ,part:            Int?=nil
        )
    {
        self.ConversationId = ConversationId
        self.Draft          = Draft
        self.Id             = Id ?? "New"
        self.Sender         = Sender
        self.Text           = Text
        self.Time           = Time
        self.part           = part
        if let af = AttachedFiles {
            self.AttachedFiles  = af
        }
    }
    public convenience init (from dict:[String:JSON], part:Int?=nil){
        self.init(
            ConversationId: dict["ConversationId"]!.string!
            ,Draft:         dict["Draft"]!.bool!
            ,Id:            dict["Id"]!.string
            ,Sender:        VSMAPI.Data.Contacts[(dict["Sender"]!.dictionary?["Id"]?.int) ?? 0]
            ,Text:          dict["Text"]!.string!
            ,Time:          Date(fromString: dict["Time"]!.string!)
            ,part:          part
        )
        
        if let jsonArr = dict["AttachedFiles"]?.array{
            for jaf in jsonArr{
                if let af = jaf.dictionary{
                    AttachedFiles.append(VSMAttachedFile(from:af))
                }
            }
            
        }
    }
    
     
    public func attachFile(filePath: String, loadedDelegate: @escaping (Bool)->Void, progressDelegate: @escaping (Double)->Void)->VSMAttachedFile?{
        if self.Id == "New" {return nil}
        self.isFileUploading = true
        let fileParts = filePath.split(separator: ".")
        let fileExtension = String(fileParts[fileParts.count-1])
        let fileName = String(filePath.replacingOccurrences(of: "."+fileExtension, with: ""))
        
        let newAttFile = VSMAttachedFile(Extension: fileExtension, Guid: "", Name: fileName)
        
        newAttFile.upload(filePath: filePath, loadedDelegate: {B in {
            if self.AttachedFiles.first(where: {$0.Guid == ""}) == nil {
                self.isFileUploading = false
            }
            loadedDelegate(B)
            }()}, progressDelegate: progressDelegate)
        return newAttFile
    }
    
    public func getJSON()->String{
        var j:[String:Any]
        var attArray = [Any]()
        for a in self.AttachedFiles{
            attArray.append(a.getJSON())
        }
        j =
        ["ConversationId": ConversationId
        ,"Text": Text
        ,"Sender":["Id":VSMAPI.Data.Contact!.Id] as [String : Any]
        ] as [String : Any]
        if attArray.count>0{
            j["AttachedFiles"] = attArray
        }
        return JSON(j).rawString([.castNilToNSNull: true])!
    }
}

public class VSMAttachedFile{
    
    public var Extension:   String
    public var Guid:        String
    public var Name:        String
    public var PreviewIcon: UIImage?{
        get{
            if self.Extension.range(of: "(((?i)(jpg|png|gif|bmp))$)", options: .regularExpression, range: nil, locale: nil) != nil{
                if !VSMAPI.fileExists("AIFile_\(self.Guid).I"){
                    let z = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.filePreviewIcon, params: ["FileMetaData":self.getJSON()])
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
                return VSMAPI.getPicture(name: "AIFile_\(self.Guid).I", empty: "AnyFile")
            }
            else{
                return UIImage(named: "AnyFile")
            }
        }
    }
    public var ImageBase64: UIImage?{
        get{
            if !VSMAPI.fileExists("APFile_\(self.Guid).I"){
                if self.Extension.range(of: "(((?i)(jpg|png|gif|bmp))$)", options: .regularExpression, range: nil, locale: nil) != nil{
                    let req = VSMAPI.syncRequest(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.fileImage, params: ["FileMetaData": self.getJSON()])
                    if(req.1){
                        if let j = JSON(req.0).dictionary{
                            if (j["Success"]?.bool!)!{
                                let base64 = j["FileMetaData"]!.dictionary!["ImageBase64"]!.string
                                self.setFileImage(base64!)
                            }
                        }
                    }
                    else{
                        print(req.0)
                    }
                }
            }
            return VSMAPI.getPicture(name: "APFile_\(self.Guid).I", empty: "")
        }
    }
    
    public init (Extension: String, Guid: String, Name: String, PreviewIcon:String = ""){
        self.Extension      = Extension
        self.Guid           = Guid
        self.Name           = Name
 
        if PreviewIcon != "" {
            self.setPrevIcon(PreviewIcon)
        }
     }
    public convenience init(from dict:[String:JSON]){
        self.init(
             Extension      : dict["Extension"]!.string!
            ,Guid           : dict["Guid"]!.string ?? ""
            ,Name           : dict["Name"]!.string!
            ,PreviewIcon    : dict["PreviewIcon"]!.string ?? ""
        )
    }
    public func getJSON()->String{
        return JSON(["Extension":self.Extension, "Guid": self.Guid, "Name":self.Name, "PreviewIcon": nil]).rawString([.castNilToNSNull: true])!
    }
    
    public func upload(filePath:String, loadedDelegate: @escaping (Bool)->Void, progressDelegate: @escaping (Double)->Void){
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
                                self.Extension      = dict["Extension"]!.string!
                                self.Guid           = dict["Guid"]!.string ?? ""
                                self.Name           = dict["Name"]!.string!
                                
                                let pi = dict["PreviewIcon"]!.string ?? ""
                                if pi != "" && self.Extension.range(of: "(((?i)(jpg|png|gif|bmp))$)", options: .regularExpression, range: nil, locale: nil) != nil {
                                    self.setPrevIcon(pi)
                                }
                                loadedDelegate(true)
                            }
                        }
                    }
                    
                case .failure(let encodingError):
                    debugPrint(encodingError)
                }
        }
        )
    }
    
    public func download(loadedDelegate: @escaping (URL?)->Void, progressDelegate: @escaping (Double)->Void){
        let fName = String(self.Name.replacingOccurrences(of: " ", with: "_"))
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.temporaryDirectory
            let fileURL = documentsURL.appendingPathComponent("\(fName).\(self.Extension)")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let urlstr = "\(VSMAPI.Settings.caddress)\(VSMAPI.WebAPIEntry.download.rawValue)?FileGuid=\(self.Guid)&FileName=\(fName))&FileExtension=\(self.Extension)"
        Alamofire.download(urlstr, to: destination)
            .downloadProgress { progress in
                progressDelegate(progress.fractionCompleted)
            }
            .responseData { response in
                if(response.result.isSuccess){
                    loadedDelegate(FileManager.default.temporaryDirectory.appendingPathComponent("\(fName).\(self.Extension)"))
                }
                else{
                        loadedDelegate(nil)
                }
                
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
            _ = VSMAPI.saveFile(name:"AIFile_\(self.Guid).I", data: dataDecoded)
        }
    }
    private func setFileImage(_ from : String){
        if(from != ""){
            let dataDecoded  = Data(base64Encoded: from, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            _ = VSMAPI.saveFile(name:"APFile_\(self.Guid).I", data: dataDecoded)
        }
    }
    
}
