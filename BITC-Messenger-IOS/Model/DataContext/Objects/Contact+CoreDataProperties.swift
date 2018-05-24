//
//  Contact+CoreDataProperties.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var serverId: Int32
    @NSManaged public var lastMessage: Message?

}
