//
//  FileDataStore.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 26.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias lms = LocalMessageStore;

public class LocalMessageStore{
    private class Part{
        var prefix  : String = ""
        var id      : String = ""
        var from    : String = ""
        var to      : String = ""
        var N       : Int    = 0
        init (prefix:String, id:String, from:String, to:String, N:Int){
            self.prefix = prefix
            self.id     = id
            self.from   = from
            self.to     = to
            self.N      = N
        }
        init(name:String,  s: String = "_"){
            //msg_-123_-5_-1_18_.I
            //msg_-123_-26_-6_20_1_.I
          let s = name.split(separator: s.first!)
            prefix  = String(s[0])
            id      = String(s[1])
            from    = String(s[2])
            to      = String(s[3])
            N       = Int(String(s[4]))!
        }
        func deleteFile(){
           _ = VSMAPI.delFile(name:"\(prefix)_\(id)_\(from)_\(to)_\(N)_.I")
        }
        func saveFile(data:Data){
            _ = VSMAPI.saveFile(name:"\(prefix)_\(id)_\(from)_\(to)_\(N)_.I", data: data)
        }
    
    }
    private var db = [Part]()
    private let table       : String
    private let separator   : String
    private let chank       : Int
    private let id          : String
    
    private var isAfter     : Bool      = false
    private var keyMsg      : String    = ""
    private var allNext     : Bool      = false
    private var jamp        : Bool      = false
    private var delegate:([VSMMessage], Int) ->()
    
    private func fillDB(){
        let fm = FileManager.default
        
        let enumerator: FileManager.DirectoryEnumerator = fm.enumerator(atPath: VSMAPI.DBURL.path)!
        var tmparr = [Part]()
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix(".I") && element.hasPrefix(table+separator+id+separator){
                tmparr.append(Part(name:element, s:separator))
            }
        }
        db = tmparr.sorted(by:{$0.from < $1.from || $0.from == ""})
    }
    private func callback(){
        getData(isAfter:isAfter, keyMsg: keyMsg, jamp : jamp)
    }
    private func loadPart(){
        if VSMAPI.Connectivity.isConn{
            let prms = ["ConversationId":id, "N":chank, "IsAfter":self.isAfter ? "True" : "False", "MessageId":self.keyMsg, "Email" : VSMAPI.Settings.user, "PasswordHash" : VSMAPI.Settings.hash] as [String : Any]
        
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.conversationMessages, params: prms, completionHandler: {(d,s) in{
            
                if(!s){
                    print( "Ошибка \(d as? String)")
                }
                else{
                    if d is Data {
                        let data = d as! Data
                        if let json = try? JSON(data: data) {
                            let arr = json["Messages"].array!
                            if let part = self.db.first(where:{$0.from == ""}){
                                part.deleteFile()
                                self.db = self.db.filter { $0 !== part }
                            }
                            let _N      = arr.count
                            let _from   = arr.first?.dictionary?["Id"]?.string ?? ""
                            let _to     = arr.last?.dictionary?["Id"]?.string ?? ""
                            let newPart = Part(prefix: self.table, id: self.id, from: _from, to: _to, N: _N)
                            newPart.saveFile(data: data)
                            if(self.isAfter){
                                self.db.append(newPart)
                            }
                            else{
                                self.db.insert(newPart, at: 0)
                            }
                            if (self.allNext || self.isAfter) && _N > 0{
                                self.loadPart()
                            }
                            else{
                                self.callback()
                            }
                            return
                        }
                    }
                }

            }()}
            )
        }
    }
    public var Messages = [VSMMessage]()
    public init(Id:String, Table:String = "MSG", Chank:Int = 20, Separator:String = "_", Delegate:@escaping ([VSMMessage], Int) ->()){
        chank       = Chank
        table       = Table
        separator   = Separator
        id          = Id
        delegate    = Delegate
        fillDB()
    }
    public func getData(isAfter:Bool = false, keyMsg: String = "", jamp : Bool = false){
        self.isAfter = isAfter
        self.keyMsg  = keyMsg
        self.jamp    = jamp
        self.allNext = false
        if keyMsg == ""{
            if db.count == 0{
                loadPart()
            }
            //заполняем массив из единственного файла и отдаем его
        }
        else if let part = db.first(where: {(isAfter ? $0.to : $0.from) == keyMsg}){
            let i = db.index(where: {(isAfter ? $0.to : $0.from) == keyMsg})
            //if
        }
        else{//нет ничего
            loadPart()
        }
    }
    public func getFilteredData(filter:String, isAfter:Bool = false, keyMsg: String = "", delegate:([VSMMessage], Int) ->()){
        //это попожее
    }
    
}

