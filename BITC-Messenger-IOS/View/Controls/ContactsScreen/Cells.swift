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
    
    private var mMessage: VSMMessage!
    
    @IBOutlet weak var ReceiverView: UIView!
    @IBOutlet weak var ReceiverMessageLabel: UILabel!
    @IBOutlet weak var ReceiverMessageTimeLabel: UILabel!
    @IBOutlet weak var SenderView: UIView!
    @IBOutlet weak var SenderMessageLabel: UILabel!
    @IBOutlet weak var SenderMessageTimeLabel: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(message: VSMMessage) {
        mMessage = message
        if (message.Sender?.isOwnContact == false) {
            ReceiverMessageLabel.text = ""
            ReceiverMessageTimeLabel.text = ""
            ReceiverView.isHidden = true
            SenderMessageLabel.text = message.Text
            SenderMessageTimeLabel.text = message.Time.toTimeString();
            SenderView.isHidden = false
        } else {
            SenderMessageLabel.text = ""
            SenderMessageTimeLabel.text = ""
            SenderView.isHidden = true
            ReceiverMessageLabel.text = message.Text
            ReceiverMessageTimeLabel.text = message.Time.toTimeString();
            ReceiverView.isHidden = false;
        }
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
