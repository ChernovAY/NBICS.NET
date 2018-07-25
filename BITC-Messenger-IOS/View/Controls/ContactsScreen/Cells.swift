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
    @IBOutlet weak var ReceiverImage: UIImageView!
    @IBOutlet weak var SenderMessageLabel: UILabel!
    @IBOutlet weak var SenderMessageTimeLabel: UILabel!
    @IBOutlet weak var SenderAttachedFilesView: UIView!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(message: VSMMessage) {
        mMessage = message
        
        ReceiverView?.clipsToBounds = true
        ReceiverView!.layer.cornerRadius = 10
        
        SenderView?.clipsToBounds = true
        SenderView!.layer.cornerRadius = 10
        if (message.Text != "") {
            SenderMessageLabel.text = ""
            SenderMessageTimeLabel.text = ""
            ReceiverMessageLabel.text = ""
            ReceiverMessageTimeLabel.text = ""
            
            SenderView.isHidden = true
            ReceiverView.isHidden = true
    
            if (message.Sender?.isOwnContact == false) {
                ReceiverView.isHidden = false
                ReceiverMessageLabel.text = message.Text
                ReceiverMessageTimeLabel.text = message.Time.toTimeString();
                ReceiverImage.image = message.Sender?.Photo
            } else {
                SenderView.isHidden = false
                SenderMessageLabel.text = message.Text
                SenderMessageTimeLabel.text = message.Time.toTimeString();
            }
            self.backgroundColor = UIColor.clear
        }
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
    
    private func buildName()->String{
        if mConv.Name != "" {
            return mConv.Name
        }
        if let r = mConv.Users.first(where: ({!$0.isOwnContact}))?.Name {
                return r
        }
        return "Фигня какая то"
    }
    private func buildImage()->UIImage {
        if let r = mConv.Users.first(where: ({!$0.isOwnContact}))?.Photo {
            return r
        }
        return UIImage(named: "EmptyUser")!
    }
}

public class IncommingCell : UITableViewCell {
    
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    private var contact: VSMContact!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMContact) {
        PhotoImage.image = contact.Photo
        NameLabel.text = contact.Name
        
        self.backgroundColor = UIColor.clear
    }
}

public class OutgoingCell : UITableViewCell {
    
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    private var contact: VSMContact!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMContact) {
        PhotoImage.image = contact.Photo
        NameLabel.text = contact.Name
        
        self.backgroundColor = UIColor.clear
    }
}

public class SearchContactCell : UITableViewCell {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var PhotoImage: UIImageView!
    
    private var contact: VSMContact!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMContact) {
        PhotoImage.image = contact.Photo
        NameLabel.text = contact.Name
        
        self.backgroundColor = UIColor.clear
    }
}

public class CreateChatСontactCell : UITableViewCell {
    private var contact: VSMCheckedContact!
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var CheckButton: CheckBox!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public func chkChange(_ b: Bool){
        self.contact.Checked = b
    }
    
    public func ConfigureCell(contact: VSMCheckedContact) {
        self.contact = contact
        PhotoImage.image = contact.Contact.Photo
        NameLabel.text = contact.Contact.Name
        CheckButton.isChecked = contact.Checked
        CheckButton.checkdelegate = chkChange
        self.backgroundColor = UIColor.clear
    }
}

public class DeleteContactFromChatCell : UITableViewCell {
    
    private var contact: VSMCheckedContact!
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMCheckedContact) {
        self.contact = contact
        PhotoImage.image = contact.Contact.Photo
        NameLabel.text = contact.Contact.Name
        self.backgroundColor = UIColor.clear
    }
 
}

public class AddContactToChatCell : UITableViewCell {
    
    private var contact: VSMCheckedContact!
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(contact: VSMCheckedContact) {
        self.contact = contact
        PhotoImage.image = contact.Contact.Photo
        NameLabel.text = contact.Contact.Name
        self.backgroundColor = UIColor.clear
    }
    
}
