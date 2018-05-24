//
//  ContactsRepository.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class ContactsRepository : IRepository {
    
    private let mEntityFactory: IEntityFactory = EntityFactory()
    private let nsUserDefaults: IUserDefaultsStringsRead = NSUserDefaultsStrings()
    
    public typealias T = Contact
    
    public func Create(item: Contact) {
        
    }
    
    public func Create(item: NSDictionary) {
        let entityId = item["EntityId"] as! Int32
        
        let dbLesson = GetById(serverId: entityId)
        
        if dbLesson == nil {
            let contact = mEntityFactory.CreateEntity(T.self)
            contact.name = item["Name"] as? String
            contact.serverId = entityId
            
            let imgData = GetImageData(contactId: entityId, passwordHash: nsUserDefaults.GetUserPasswordHash()!, email: nsUserDefaults.GetUserEmail()!)

            contact.image = SaveImageToDisk(data: imgData as Data, name: contact.name!, mimeType: "")
        
            do {
                try DbContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    public func GetAllItems() -> [Contact] {
        var result = [Contact]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        do {
            result = try DbContext.fetch(request) as! [Contact]
        } catch {
            print(error)
        }
        
        return result
    }
    
    public func Update(item: Contact) {
        
    }
    
    public func Delete(item: Contact) {
        
    }
    
    private func GetById(serverId: Int32) -> T? {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
        fetch.predicate = NSPredicate(format: "serverId == %i", serverId)
        
        do {
            let result = try DbContext.fetch(fetch)
            let contacts = result as! [T]
            
            if contacts.count == 0 {
                return nil
            }
            
            return contacts[0]
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func SaveImageToDisk(data: Data, name: String, mimeType: String) -> String? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let imageUrl = documentsDirectory.appendingPathComponent("\(name).png")
        
        do {
            try data.write(to: imageUrl, options: .atomicWrite)
            return imageUrl.path
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func GetImageData(contactId: Int32, passwordHash: String, email: String) -> NSData {
        let url = NSURL(string: WebApi.UserContactAvatar + "?login=\(email)&pswHash=\(passwordHash)&id=\(contactId)")
        
        print(url)
        
        let image_data = NSData(contentsOf: url! as URL)
        
        return image_data!
    }
}
