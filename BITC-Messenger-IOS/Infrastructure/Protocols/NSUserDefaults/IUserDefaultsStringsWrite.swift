//
//  IUserDefaultsStringsWrite.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation

public protocol IUserDefaultsStringsWrite {
    
    func SetUserPasswordHash(hash: String)
    
    func SetUserAvatar(avatar: NSData)
    
    func SetUserLogin(login: String)
    
    func SetUserEmail(email: String)
    
    func SetLoginStatus(isForceLogin: Bool)
    
}
