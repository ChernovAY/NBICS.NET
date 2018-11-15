
//
//  DataUtils.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 20.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation

class Loader {
    let next:Loader?
    let delegate: ((Any?, Any?)->())?
    let opt:Any?
    init(next:Loader?=nil, delegate:((Any?,Any?)->())?=nil, opt:Any?=nil){
        self.next           = next
        self.delegate       = delegate
        self.opt            = opt
    }
    
    func exec(_ parm:Any?=nil){
        if let d = delegate{
            d(parm, opt)
        }
    }
}

class DataLoader:Loader {
    var entry: VSMAPI.WebAPIEntry
    var params: Params
    init(params: Params = ["email" : VSMAPI.Settings.user, "passwordHash" : VSMAPI.Settings.hash], entry: VSMAPI.WebAPIEntry,delegate:((Any?, Any?)->())?=nil, opt:Any?=nil, next:Loader?=nil){
        self.params         = params
        self.entry          = entry
        super.init(next:next, delegate:delegate, opt:opt)
    }
    
    override func exec(_ parm:Any?=nil) {
        if VSMAPI.Connectivity.isConn{
            VSMAPI.Request(addres: VSMAPI.Settings.caddress, entry: entry, params: params, completionHandler: {(d,s) in{
                if(!s) {
                    print("Ошибка \(d as? String)")
                } else {
                    if d is Data {
                        let data = d as! Data
                        _ = VSMAPI.saveFile(name: self.entry.rawValue + ".I", data: data)
                        super.exec(data)
                        self.next?.exec()
                    }
                }
            }()}
            )
        } else {
            if let data = VSMAPI.getFile(name: self.entry.rawValue + ".I"){
                super.exec(data)
                self.next?.exec()
            }
        }
    }
}

