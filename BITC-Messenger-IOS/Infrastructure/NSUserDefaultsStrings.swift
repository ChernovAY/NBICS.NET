//
//  NSUserDefaultsStrings.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation

public class NSUserDefaultsStrings {
    private let mHashString = "HashString"
    private let mAvatarString = "AvatarString"
    private let mLoginString = "LoginString"
    private let mEmailString = "EmailString"
    private let mLoginStatus = "IsForceLogin"
    
    private let mUserDefaults = UserDefaults.standard
    
    public func GetUserPasswordHash() -> String? {
        if let result = mUserDefaults.object(forKey: mHashString) as? String {
            return result
        }
        
        return nil
    }
    
    public func GetUserAvatar() -> NSData? {
        if let result = mUserDefaults.object(forKey: mAvatarString) as? NSData {
            return result
        }
        
        return nil
    }
    
    public func GetUserLogin() -> String? {
        if let result = mUserDefaults.object(forKey: mLoginString) as? String {
            return result
        }
        
        return nil
    }
    
    public func GetUserEmail() -> String? {
        if let result = mUserDefaults.object(forKey: mEmailString) as? String {
            return result
        }
        return nil
    }
    
    public func GetLoginStatus() -> Bool? {
        if let result = mUserDefaults.object(forKey: mLoginStatus) as? Bool {
            return result
        }
        
        return false;
    }
    
    public func SetUserPasswordHash(hash: String) {
        mUserDefaults.set(hash, forKey: mHashString)
    }
    
    public func SetUserAvatar(avatar: NSData) {
        mUserDefaults.set(avatar, forKey: mAvatarString)
    }
    
    public func SetUserLogin(login: String) {
        mUserDefaults.set(login, forKey: mLoginString)
    }
    
    public func SetUserEmail(email: String) {
        mUserDefaults.set(email, forKey: mEmailString)
    }
    
    public func SetLoginStatus(isForceLogin: Bool) {
        mUserDefaults.set(isForceLogin, forKey: mLoginStatus)
    }
}
