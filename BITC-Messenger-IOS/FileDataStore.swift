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
    private struct db{
        let path:String
        let from:String
        let to  :String
        let N   :Int
        let Data:JSON?
    }
    
    private let table       : String
    private let separator   : String
    private let chank       : Int
    
    public init(Table:String = "MSG", Chank:Int = 20, Separator:String = "_"){
        chank       = Chank
        table       = Table
        separator   = Separator
    }
    
    public func getData(from:String = "", to:String = ""){
        
    }
    
}
