//
//  ContactsRequests.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import Alamofire

public class ContactsRequests {
    
    public func GetContacts(email: String, passwordHash: String, completionHandler: @escaping ([NSDictionary]) -> ()) {
        let params : [String: Any] = ["email" : email, "passwordHash" : passwordHash]
        let request = Alamofire.request(WebApi.ContatcsApi, method: HTTPMethod.get, parameters: params, headers: nil)
        
        request.responseJSON { responce -> Void in
            if let result = responce.result.value {
                completionHandler(result as! [NSDictionary])
            }
        }
    }
    
}
