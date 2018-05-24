//
//  AuthRequests.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 29.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import Alamofire

public class AuthRequests {
    
    public func Authorize(login: String, passwordHash: String,
                          completionHandler: @escaping (UInt8) -> ()) {
        let params : [String: Any] = ["login" : login, "passwordHash" : passwordHash]
            let request = Alamofire.request(WebApi.LoginApi, method: HTTPMethod.get, parameters: params, headers: nil)
            
            request.responseJSON { responce -> Void in
                if let result = responce.result.value {
                    if result is UInt8 {
                        completionHandler(result as! UInt8)
                    }
                }
            }
    }
    
}
