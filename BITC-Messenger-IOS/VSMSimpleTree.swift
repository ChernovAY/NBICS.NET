//
//  VSMSimpleTree.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 01.08.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class tree{
    public let Id: Int
    public var Parent: Int?
    public let npp:Int
    public init (npp:Int, Id:Int, Parent:Int?){
        self.Id     = Id
        self.Parent = Parent
        self.npp    = npp
    }
}

public class VSMSimpleTree{
   
    public      var root:       VSMSimpleTree?
    public      var all:        [VSMSimpleTree]?
    public      var parent:     VSMSimpleTree?
    public      var children:   [VSMSimpleTree]?
    public      var isExpanded: Bool
    public      let content:    tree?
    public      var level:      Int
    public      var isShown:    Bool = false
    
    public init
    (   root:VSMSimpleTree?            = nil
    ,   parent: VSMSimpleTree?         = nil
    ,   level:Int                      = -1
    ,   content:tree?                  = nil
    ,   children: [VSMSimpleTree]?     = nil
    ,   isExpanded: Bool               = false
    ){
        self.parent     = parent
        self.children   = children
        self.isExpanded = isExpanded
        self.content    = content
        self.level      = level
        self.root       = root ?? self
        
        if root == nil{
            self.all = [VSMSimpleTree]()
        }
        self.children = [VSMSimpleTree]()
        root?.all?.append(self)
    }
    
    deinit {
        self.children?.removeAll()
        root?.all = root?.all?.filter({!($0 === self)})
        parent?.children = parent?.children?.filter({!($0 === self)})
    }
    
    public func fillTreee(root: VSMSimpleTree, from: [tree]) {
        
        let array = from.filter({$0.Parent == self.content?.Id})
        for a in array{
            let cld = VSMSimpleTree(root:self.root, parent:self, level: self.level + 1, content: a)
            self.children?.append(cld)
            cld.fillTreee(root: root, from: from)
        }
    }

    public func collapse(_ delegate:(([VSMSimpleTree]?)->Void)? = nil) {
        self.isExpanded = false
        if let cc = children {
            for c in cc{
                c.collapse()
                c.isShown = false
            }
        }
        if let d = delegate {
            d(root?.all?.filter({$0.isShown}))
        }
    }
    
    public func expand(_ delegate:(([VSMSimpleTree]?)->Void)? = nil) {
       self.isExpanded = true
        if let cc = children {
            for c in cc {
                c.isShown = true
            }
        }
        if let d = delegate {
            d(root?.all?.filter({$0.isShown}))
        }
    }

    public func expandAll(_ delegate:(([VSMSimpleTree]?)->Void)? = nil) {
        self.isExpanded = true
        if let cc = children{
            for c in cc{
                c.isShown = true
                c.expandAll()
            }
        }
        if let d = delegate {
            d(root?.all?.filter({$0.isShown}))
        }
    }
    
    public func delete(_ delegate:(([VSMSimpleTree]?)->Void)? = nil) {
        if let cc = children {
            for c in cc{
                c.delete()
            }
        }
        root?.all = root?.all?.filter({!($0 === self)})
        parent?.children = parent?.children?.filter({!($0 === self)})
        if let d = delegate {
            d(root?.all?.filter({$0.isShown}))
        }
    }
    
}
