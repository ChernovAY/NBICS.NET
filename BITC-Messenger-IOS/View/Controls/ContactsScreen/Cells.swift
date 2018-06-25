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
    
    public var mMessage: VSMMessage!
    
    @IBOutlet weak var ReceiverView: UIView!
    @IBOutlet weak var ReceiverMessageLabel: UILabel!
    @IBOutlet weak var ReceiverMessageTimeLabel: UILabel!
    @IBOutlet weak var SenderView: UIView!
    @IBOutlet weak var SenderMessageLabel: UILabel!
    @IBOutlet weak var SenderMessageTimeLabel: UILabel!
    @IBOutlet weak var ReceiverImage: UIImageView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(message: VSMMessage) {
        mMessage = message
        self.ReceiverView?.clipsToBounds = true
        self.ReceiverView!.layer.cornerRadius = 10
        self.ReceiverImage?.clipsToBounds = true
        self.ReceiverImage.layer.cornerRadius = 10
        self.SenderView?.clipsToBounds = true
        self.SenderView!.layer.cornerRadius = 10
        SenderMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        SenderMessageLabel.numberOfLines = 0
        ReceiverMessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        ReceiverMessageLabel.numberOfLines = 0
        if (message.Text != ""){
            if (message.Sender?.isOwnContact == false) {
                SenderMessageLabel.text = ""
                SenderMessageTimeLabel.text = ""
                SenderView.isHidden = true
                ReceiverImage.image = message.Sender?.Photo
                ReceiverMessageLabel.text = message.Text
                ReceiverMessageTimeLabel.text = message.Time.toTimeString();
                ReceiverView.isHidden = false;
            } else {
                ReceiverMessageLabel.text = ""
                ReceiverMessageTimeLabel.text = ""
                ReceiverView.isHidden = true
                SenderMessageLabel.text = message.Text
                SenderMessageTimeLabel.text = message.Time.toTimeString();
                SenderView.isHidden = false
                
            }
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
