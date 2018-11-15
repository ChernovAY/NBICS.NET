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

public class LocalMessageStore {
    private class Part{
        var id      : String    = ""
        var part    : Int       = 0
        var N       : Int       = 0
        
        init (id:String, part:Int, N:Int) {
            self.part     = part
            self.N        = N
            self.id       = id
        }
        
        init(name:String) {
          let s = name.split(separator: "_")
            id      = String(s[1])
            part    = Int(String(s[2]))!
            N       = Int(String(s[3]))!
        }
        
        func deleteFile() {
           _ = VSMAPI.delFile(name: "msg_\(id)_\(part)_\(N)_.I")
        }
        
        func saveFile(data:Data) {
            _ = VSMAPI.saveFile(name: "msg_\(id)_\(part)_\(N)_.I", data: data)
        }
        
        func getFileData()->Data? {
            return VSMAPI.getFile(name: "msg_\(id)_\(part)_\(N)_.I")
        }
    }
    
    private var db = Dictionary<Int,Part>()
    private let chank       : Int
    private let id          : String
    private var isAfter     : Bool      = false
    private var allNext     : Bool      = false
    private var jamp        : Bool      = false
    private var filter      : String    = ""

    public var array = [VSMMessage]()
    private func fillDB() {
        let fm = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fm.enumerator(atPath: VSMAPI.DBURL.path)!
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix(".I") && element.hasPrefix("msg_\(id)_"){
                let p = Part(name:element)
                db[p.part] = p
            }
        }
    }
    
    private func loadPart(key:(String,Int)) {
        if VSMAPI.Connectivity.isConn{
            let prms = [
                "ConversationId" :  id,
                "N" :               chank,
                "IsAfter" :         self.isAfter ? "True" : "False",
                "MessageId":        key.0,
                "Email" :           VSMAPI.Settings.user,
                "PasswordHash" :    VSMAPI.Settings.hash
            ] as [String : Any]
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: VSMAPI.WebAPIEntry.conversationMessages, params: prms, completionHandler: {(d,s) in {
                if(!s) {
                    print( "Ошибка \(d as? String)")
                    VSMAPI.Data.EMessages.raise(data: (self.id, -1))
                } else {
                    if d is Data {
                        let data = d as! Data
                        if let json = try? JSON(data: data) {
                            let arr = json["Messages"].array!
                            let _N      = arr.count
                            let _from   = arr.first?.dictionary?["Id"]?.string ?? ""
                            let _to     = arr.last?.dictionary?["Id"]?.string ?? ""
                            if (_N > 0) {
                                let newPart = Part(id: self.id, part: key.1, N: _N)
                                if let part = self.db[key.1]{
                                    part.deleteFile()
                                }
                                newPart.saveFile(data: data)
                                self.db[key.1] = newPart
                                if (self.allNext || self.isAfter) {
                                    let newKey = self.isAfter ? (_to, key.1+1) : (_from, key.1-1)
                                    self.loadPart(key:newKey)
                                    return
                                }
                            }
                            self.fillArray(key.1, true)
                        }
                    }
                }
            }()}
            )
        }
    }
 
    private func filArrayFromFile(_ p:Part?) {
        if let data = p?.getFileData(){
            if let json = try? JSON(data: data) {
                let arr = json["Messages"].array!
                for c in arr {
                    if let dict = c.dictionary {
                        array.append(VSMMessage(from:dict, part:p?.part))
                    }
                }
            }
        }
    }
    
    private func fillArray(_ i:Int, _ raise:Bool = false) {
        var wu = db[i-1]
        var wt = db[i]
        var wd = db[i+1]
        if wt == nil && wd != nil {
            wu = db[i]
            wt = db[i+1]
            wd = db[i+2]
        } else if wt == nil && wu != nil {
            wu = db[i-2]
            wt = db[i-1]
            wd = db[i]
        }
        let oldCurr = isAfter ? array.last : array.first
        self.array.removeAll()
        filArrayFromFile(wu)
        filArrayFromFile(wt)
        filArrayFromFile(wd)
        if raise {
            let addr = array.count == 0 ? -1 : (self.jamp ? array.count - 1 : oldCurr != nil ? array.index(where: {$0.Id == oldCurr?.Id }) ?? -1 : -1)
            VSMAPI.Data.EMessages.raise(data: (self.id, addr))
        }
    }

    public init(Id:String, Chank:Int = 20) {
        chank       = Chank
        id          = Id
        fillDB()
        if let last = db.keys.sorted(by: <).last{
            fillArray(last, false)
        }
    }
    
    public var lastPArt: Int {
        get {
            return db.keys.sorted(by: <).last ?? 0
        }
    }
    
    public func getData(isAfter:Bool = true, jamp:Bool = false) {
        self.isAfter    = isAfter
        self.jamp       = jamp
        self.allNext    = false
        self.filter     = ""
        var key         = ("",0)
        if jamp {
            if let last = db.keys.sorted(by: <).last{
                fillArray(last, false)
                if db[last]!.N == chank{
                    key = (array.last!.Id, last + 1)
                } else {
                    let af =  array.filter({$0.part == last-1})
                    if let l  =  af.last{
                        key = (l.Id, last)
                    }
                }
            }
        } else if let currentIndex = (isAfter ? array.last?.part : array.first?.part) {
            let nextIndex = isAfter ? currentIndex+1 :  currentIndex-1
            if db[nextIndex] != nil {
                fillArray(nextIndex, true)
                return
            }
            if db[currentIndex]!.N < chank && isAfter {
                let af =  array.filter({$0.part == currentIndex - 1})
                if let l  =  af.last{
                    key = (l.Id, currentIndex)
                }
            } else {
                key = (isAfter ? array.last!.Id : array.first!.Id, nextIndex)
            }
        }
        loadPart(key:key)
    }
}

