//
//  DatabaseContextFactory.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class DatabaseContextFactory {
    
    public static func GetDefaultModelContext() -> NSManagedObjectContext {
        let context = appDelegate.persistentContainer.newBackgroundContext()
        
        return context
    }
    
}
