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
    
    private var mContact: VSMContact!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMContact) {
        mContact = contact
        
        NameLbl.text = contact.Name
        ThumbImage.image = contact.Photo
        
        self.backgroundColor = UIColor.clear
    }
}
