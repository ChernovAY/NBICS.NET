//
//  AlamoFire.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 31.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    
    
    /**
     Wait for the request to finish then return the response value.
     
     - returns: The response.
     */
    public func syncResponse() -> DefaultDataResponse {
        
        let semaphore = DispatchSemaphore(value: 0)
        var result: DefaultDataResponse!
        
        self.response(queue: DispatchQueue.global(qos: .default)) { response in
            
            result = response
            semaphore.signal()
            
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return result
    }
}
