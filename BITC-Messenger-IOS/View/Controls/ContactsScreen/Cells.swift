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
    
    @IBOutlet weak var LastMessageLbl: UILabel!
    @IBOutlet weak var NameLbl : UILabel!
    @IBOutlet weak var ThumbImage: UIImageView!
    @IBOutlet weak var CountNotificationsLbl: UILabel!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(conversation: VSMConversation) {
        mConv = conversation
        CountNotificationsLbl.layer.masksToBounds = true
        CountNotificationsLbl.layer.cornerRadius = 8
        if (mConv.NotReadedMessagesCount > 0) {
            CountNotificationsLbl.isHidden = false
            if (mConv.NotReadedMessagesCount < 100) {
                CountNotificationsLbl.text = String(mConv.NotReadedMessagesCount)
            } else {
                CountNotificationsLbl.text = "99+"
            }
        } else  {
            CountNotificationsLbl.isHidden = true
        }
        NameLbl.text = buildName()
        ThumbImage.image = buildImage()
        LastMessageLbl.text = mConv.LastMessage?.Text
        self.backgroundColor = UIColor.clear
    }
    
    private func buildName()->String{
        if mConv.Name != "" {
            return mConv.Name
        }
        if let r = mConv.Users.first(where: ({!$0.isOwnContact}))?.Name {
            return r
        }
        return "name"
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

public class MessageAttachmentsCell : UICollectionViewCell {
    
    private var file: VSMAttachedFile!
    private var previewDelegate: ((URL)->Void)?
    private var stateDelegate:((Bool)->Void)?
    @IBOutlet weak var NameFileLabel: UILabel!
    @IBOutlet weak var FileImage: UIImageView!
    @IBOutlet weak var FileView: UIView!
    @IBOutlet weak var ProgressView: UIProgressView!
    @IBOutlet weak var DownloadFileButton: UIButton!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(file: VSMAttachedFile, previewDelegate:((URL)->Void)?, stateDelegate:((Bool)->Void)?) {
        self.stateDelegate = stateDelegate
        self.previewDelegate = previewDelegate
        
        self.file = file
        FileView?.clipsToBounds = true
        FileView!.layer.cornerRadius = 5
        NameFileLabel.text = file.Name
        FileImage.image = file.PreviewIcon
        
        if VSMAPI.VSMChatsCommunication.AttMessageId == "New"{
            DownloadFileButton.setImage(UIImage(named: "delete"), for: .normal)
            DownloadFileButton.setImage(UIImage(named: "delete"), for: .selected)
            DownloadFileButton.setImage(UIImage(named: "delete"), for: .focused)
            self.file.progressDelegate  = progress
            self.file.loadedDelegate    = uploaded
        }
    }

    @IBAction func downloadFile(_ sender: UIButton) {
        if VSMAPI.VSMChatsCommunication.AttMessageId == "New"{
            if file.dropFile(){
                VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft.AttachedFiles = (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft.AttachedFiles.filter({!($0 === file)}))!
                if let s = stateDelegate{
                    s(false)
                }
            }
        } else {
            ProgressView.progress = 0
            ProgressView.isHidden = false
            if let d = self.stateDelegate{
                d(true)
            }
            self.file.download(loadedDelegate: loaded, progressDelegate: progress)
        }
    }
    
    private func uploaded(B:Bool){
        if B{
            NameFileLabel.text = file.Name
            FileImage.image = file.PreviewIcon
            ProgressView.isHidden = true
            if let msg = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft{
                if msg.AttachedFiles.first(where: {$0.Guid == ""}) == nil {
                    msg.isFileUploading = false
                    if let s = stateDelegate{
                        s(false)
                    }
                }
                DownloadFileButton.isHidden = false
            }
        }
    }
    private func loaded(url:URL?){
        if let d = self.stateDelegate{
            d(false)
        }
        
        if let u = url {
            if let d = previewDelegate{
                d(u)
            }
        }
        ProgressView.isHidden = true
        ProgressView.progress = 0
    }
    private func progress(progress:Double){
        ProgressView.progress = Float(progress)
        if !DownloadFileButton.isHidden {DownloadFileButton.isHidden = true}
        if ProgressView.isHidden {ProgressView.isHidden = false}
    }
}

public class CommonConfigurationCell : UITableViewCell {
    
    private var tree: VSMSimpleTree!
    private var configuration: VSMConfiguration!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ConfView: UIView!
    @IBOutlet weak var ConfViewLeading: NSLayoutConstraint!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(treenode: VSMSimpleTree) {
        tree = treenode
        configuration = tree.content as! VSMConfiguration
        
        ConfView?.clipsToBounds = true
        ConfView!.layer.cornerRadius = 10
        if (configuration.CType == "Folder"){
            ConfView.backgroundColor = nil
            NameLabel.textColor = UIColor.white
        }
        ConfViewLeading.constant = CGFloat(tree.level * 30)
        NameLabel.text = configuration.Name
        self.backgroundColor = UIColor.clear
    }
}

public class PrivateConfigurationCell : UITableViewCell {
    
    private var tree: VSMSimpleTree!
    private var configuration: VSMConfiguration!
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ConfView: UIView!
    @IBOutlet weak var ConfViewLeading: NSLayoutConstraint!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(treenode: VSMSimpleTree) {
        tree = treenode
        configuration = tree.content as! VSMConfiguration
        
        ConfView?.clipsToBounds = true
        ConfView!.layer.cornerRadius = 10
        if (configuration.CType == "Folder"){
            ConfView.backgroundColor = nil
            NameLabel.textColor = UIColor.white
        }
        ConfViewLeading.constant = CGFloat(tree.level * 30)
        NameLabel.text = configuration.Name
        self.backgroundColor = UIColor.clear
    }
}

public class AttachConfigurationCell : UITableViewCell {
    
    private var tree: VSMSimpleTree!
    private var configuration: VSMConfiguration!
    
    @IBOutlet weak var ConfViewLeading: NSLayoutConstraint!
    @IBOutlet weak var ConfView: UIView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var CheckButton: CheckBox!
    @IBOutlet weak var LockButton: LockButton!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func ConfigureCell(treenode: VSMSimpleTree) {
        tree = treenode
        configuration = tree.content as! VSMConfiguration
        
        ConfView?.clipsToBounds = true
        ConfView!.layer.cornerRadius = 10
        if (configuration.CType == "Folder"){
            CheckButton.isHidden = true
            LockButton.isHidden = true
            ConfView.backgroundColor = nil
            NameLabel.textColor = UIColor.white
        }
        ConfViewLeading.constant = CGFloat(tree.level * 30)
        NameLabel.text = configuration.Name
        self.backgroundColor = UIColor.clear
    }
}
