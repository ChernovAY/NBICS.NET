//
//  EntityFactory.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData

public class EntityFactory : IEntityFactory {
    
    //TODO: Внедрить фабрику создания контекста, создать глобальный приватный контекст,
    //использовать его при создании сущностей
    
    
    public func CreateEntity<T: NSManagedObject>(_: T.Type) -> T {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: DbContext)
        let record = NSManagedObject(entity: entity!, insertInto: DbContext) as! T
        
        return record
    }
    
}
