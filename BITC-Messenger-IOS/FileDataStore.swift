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
        let path    : String
        var id      : String
        var from    : String
        var to      : String
        var N       : Int
        var T       : Int//0-1
        init(name:String,  s: String = "_"){
            //msg_-123_-5_-1_18_0_.I
            //msg_-123_-26_-6_20_1_.I
          path = VSMAPI.DBURL.path + "/"+name
          let s = name.split(separator: s.first!)
            id      = String(s[1])
            from    = String(s[2])
            to      = String(s[3])
            N       = Int(String(s[4]))!
            T       = Int(String(s[5]))!
        }
    }
    private var db = [Part]()
    private let table       : String
    private let separator   : String
    private let chank       : Int
    private let id          : String
    
    private func fillDB(){
        let fm = FileManager.default
        
        let enumerator: FileManager.DirectoryEnumerator = fm.enumerator(atPath: VSMAPI.DBURL.path)!
        var tmparr = [Part]()
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix(".I") && element.hasPrefix(table+separator+id+separator){
                tmparr.append(Part(name:element, s:separator))
            }
        }
        db = tmparr.sorted(by:{$0.from < $1.from})
    }
    public init(Id:String, Table:String = "MSG", Chank:Int = 20, Separator:String = "_"){
        chank       = Chank
        table       = Table
        separator   = Separator
        id          = Id
        fillDB()
        if db.count == 0{//еще ничего небыло. надо иницировать. Если вааще ничего нет добавится пустой массив
            
        }
    }
    
    public func getData(from:String = "", to:String = ""){
        
    }
    
}

