//
//  IRepository.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation

public protocol IRepository {
    associatedtype T
    
    func Create(item: T) -> Void
    
    func Create(item: NSDictionary) -> Void
    
    func GetAllItems() -> [T]
    
    func Update(item: T) -> Void
    
    func Delete(item: T) -> Void
}
