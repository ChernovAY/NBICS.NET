//
//  IUserDefaultsStringsRead.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation

public protocol IUserDefaultsStringsRead {
    
    func GetUserPasswordHash() -> String?
    
    func GetUserAvatar() -> NSData?
    
    func GetUserLogin() -> String?
    
    func GetUserEmail() -> String?
    
    func GetLoginStatus() -> Bool?
    
}
