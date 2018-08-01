//
//  VSMSimpleTree.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 01.08.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class tree<T>{
    public var Id: T
    public var Parent: T?
    public init (Id:T, Parent:T?){
        self.Id = Id
        self.Parent = Parent
    }
}
/*public class VSMSimpleTree<T>{
    public var parent: VSMSimpleTree?
    public var children: [VSMSimpleTree]?
    public var isExpanded: Bool? = nil
    public let content:T?
    public var level:Int = 0
    
    /*public init
    (   parent: VSMSimpleTree?
    ,   children: [VSMSimpleTree]?
    ,   isExpanded: Bool? = nil
    ,   content:T?
    ,   level:Int = 0
    ){
        self.parent
        self.children: [VSMSimpleTree]?
        self.isExpanded: Bool? = nil
        self.content:T?
        self.level:Int = 0
    }*/
}*/
