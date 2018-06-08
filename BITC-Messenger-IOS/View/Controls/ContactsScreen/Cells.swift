//
//  ContactCell.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 25.09.17.
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

public class MessageCell : UITableViewCell {

    //@IBOutlet weak var MessageField: UITextField!
    //@IBOutlet weak var MessageLabel: UILabel!
    
    private var mMessage: VSMMessage!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(message: VSMMessage) {
        mMessage = message
        //MessageField.text = message.Text
        //MessageLabel.text = message.Text
        
        self.backgroundColor = UIColor.clear
    }
}

public class ConversationCell : UITableViewCell {
    
    @IBOutlet weak var NameLbl : UILabel!
    @IBOutlet weak var ThumbImage: UIImageView!
    
    private var mConv: VSMConversation!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(conversation: VSMConversation) {
        mConv = conversation
        
        
        NameLbl.text = buildName()
        ThumbImage.image = buildImage()
        
        self.backgroundColor = UIColor.clear
    }
//-------------------------
    private func buildName()->String{
        if mConv.Name != ""
        {
            return mConv.Name
        }
        if let r = mConv.Users.first(where: ({!$0.isOwnContact}))?.Name {
                return r
        }
        return "Фигня какая то"
    }
    private func buildImage()->UIImage{
        if let r = mConv.Users.first(where: ({!$0.isOwnContact}))?.Photo {
            return r
        }
        return UIImage(named: "EmptyUser")!
    }
}
