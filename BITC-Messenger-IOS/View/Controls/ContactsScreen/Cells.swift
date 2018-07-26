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
    
    private var mContact: VSMContact!
    
    @IBOutlet weak var NameLbl : UILabel!
    @IBOutlet weak var ThumbImage: UIImageView!
    
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
    private var delegate:(()->Void)?
    
    @IBOutlet weak var ReceiverView: UIView!
    @IBOutlet weak var ReceiverMessageLabel: UILabel!
    @IBOutlet weak var ReceiverMessageTimeLabel: UILabel!
    @IBOutlet weak var SenderView: UIView!
    @IBOutlet weak var ReceiverImage: UIImageView!
    @IBOutlet weak var SenderMessageLabel: UILabel!
    @IBOutlet weak var SenderMessageTimeLabel: UILabel!
    @IBOutlet weak var SenderAttachedFilesButton: UIButton!
    @IBOutlet weak var ReceiverAttachedFilesButton: UIButton!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(message: VSMMessage, AttchsDelegate:(()->Void)? = nil) {
        delegate = AttchsDelegate
        mMessage = message
        
        ReceiverView?.clipsToBounds = true
        ReceiverView!.layer.cornerRadius = 10
        
        SenderView?.clipsToBounds = true
        SenderView!.layer.cornerRadius = 10
        
        SenderMessageLabel.text = ""
        SenderMessageTimeLabel.text = ""
        ReceiverMessageLabel.text = ""
        ReceiverMessageTimeLabel.text = ""
            
        SenderView.isHidden = true
        ReceiverView.isHidden = true
        
        SenderAttachedFilesButton.isHidden = true
        ReceiverAttachedFilesButton.isHidden = true
    
        if (message.Sender?.isOwnContact == false) {
            ReceiverView.isHidden = false
            ReceiverMessageLabel.text = message.Text
            ReceiverMessageTimeLabel.text = message.Time.toTimeString();
            ReceiverImage.image = message.Sender?.Photo
            if (message.AttachedFiles.count > 0){
                ReceiverAttachedFilesButton.isHidden = false
            }
        } else {
            SenderView.isHidden = false
            SenderMessageLabel.text = message.Text
            SenderMessageTimeLabel.text = message.Time.toTimeString();
            if (message.AttachedFiles.count > 0){
                SenderAttachedFilesButton.isHidden = false
            }
        }
        self.backgroundColor = UIColor.clear
    }
    
    @IBAction func showReceiverAttachedFiles(_ sender: UIButton) {
        setAttachsMessage()
    }
    @IBAction func showSenderAttachedFiles(_ sender: UIButton) {
        setAttachsMessage()
    }
    func setAttachsMessage(){
        VSMAPI.VSMChatsCommunication.AttMessageId = self.mMessage.Id
        if let d = self.delegate{
            if self.mMessage.AttachedFiles.count>0{
                d()
            }
        }
    }
    
}

public class ConversationCell : UITableViewCell {
    
    private var mConv: VSMConversation!
    
    @IBOutlet weak var NameLbl : UILabel!
    @IBOutlet weak var ThumbImage: UIImageView!
    
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

    private var contact: VSMContact!
    
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
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
    
    private var contact: VSMContact!
    
    @IBOutlet weak var PhotoImage: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
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
    
    private var contact: VSMContact!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var PhotoImage: UIImageView!
    
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

public class MessageAttachmentsCell : UITableViewCell {
    
    private var file: VSMAttachedFile!
    
    //@IBOutlet weak var DownloadFileButton: UIButton!
   // @IBOutlet weak var NameFileLabel: UILabel!
    @IBOutlet weak var FileImage: UIImageView!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(file: VSMAttachedFile) {
        self.file = file
        //NameFileLabel.text = file.Name
        FileImage.image = file.PreviewIcon
        FileImage.backgroundColor = UIColor.darkGray
        
        //FileImage.sizeToFit()
        
        self.backgroundColor = UIColor.darkGray
    }
}
