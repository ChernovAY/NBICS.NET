//
//  DateExtension.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 29.05.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation

extension Date{
    public init(fromString: String){
        self.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: fromString)!
        self = date
    }
    public func toString(_ format:String = "dd.MM.yyyy")->String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from:self)
    }
}
