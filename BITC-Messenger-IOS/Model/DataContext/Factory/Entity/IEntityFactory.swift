//
//  IEntityFactory.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData

public protocol IEntityFactory {
    func CreateEntity<T: NSManagedObject>(_: T.Type) -> T
}
