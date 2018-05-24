//
//  ContactCell.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 25.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit

public class ContactCell : UITableViewCell {
    
    @IBOutlet weak var NameLbl : UILabel!
    @IBOutlet weak var ThumbImage: UIImageView!
    
    private var mContact: Contact!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: Contact) {
        mContact = contact
        
        NameLbl.text = contact.name
        
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        //let imagePath = String("\(documentDirectory)/\(contact.name!)")
        
        ThumbImage.image = UIImage(named: "EmptyUser")
        
        self.backgroundColor = UIColor.clear

    }
}
