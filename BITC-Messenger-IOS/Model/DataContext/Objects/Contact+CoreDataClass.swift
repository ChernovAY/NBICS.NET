//
//  Contact+CoreDataClass.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 04.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Contact: NSManagedObject {
    
    public func GetImage() -> UIImage {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let imagePath = self.image //String("\(documentDirectory)/\(self.name!)")
        
        return UIImage(contentsOfFile: imagePath!)!
    }
    
}
