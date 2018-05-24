//
//  Hasher.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//
import Foundation

public class Hasher {
    
    public func GetMD5Hash(inputString: String) -> String? {
        
        guard let messageData = CreateMicrosoftString(targetString: inputString)
            .data(using:String.Encoding.utf8) else { return nil }
        
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex =  digestData.map { String(format: "%02hhx", $0) }.joined()
        
        return md5Hex
    }

   private func CreateMicrosoftString(targetString: String) -> String {
        let splitString = [UInt8](targetString.utf8)
        let fullBytes = AddZeroes(inputArray: splitString)
        let finalString = String(bytes: fullBytes, encoding: String.Encoding.utf8)
        if finalString != nil{
            return finalString!
        } else {
            return "0"
        }
    }
    
    private func AddZeroes(inputArray: [UInt8]) -> [UInt8] {
        
        var newArray = inputArray
        
        var startPoint = 1
        for _ in 0...inputArray.count - 1 {
            newArray.insert(0, at: startPoint)
            startPoint += 2
        }
        
        return newArray
    }
    
}
