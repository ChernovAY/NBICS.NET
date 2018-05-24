//
//  ContactsViewModel.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData

public class ContactsViewModel {
    
    private let mContactsRequests: ContactsRequests = ContactsRequests()
    private let mContactsRepo: ContactsRepository = ContactsRepository()
    
    public func SaveContactsFromWeb(email: String, passwordHash: String, completionHandler: @escaping ([Contact]) -> ()) {
        mContactsRequests.GetContacts(email: email, passwordHash: passwordHash) { result in
            if result.count > 0 {
                for element in result {
                    self.mContactsRepo.Create(item: element)
                }
            }
            
            completionHandler(self.GetMyContacts())
        }
    }
    
    public func GetMyContacts() -> [Contact] {
        return mContactsRepo.GetAllItems()
    }
}
