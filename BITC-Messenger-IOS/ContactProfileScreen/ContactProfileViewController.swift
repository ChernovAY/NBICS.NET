//
//  ContactProfileViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 04.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ContactProfileViewController: VSMUIViewController {
    
    public var writeMessageCheck = false
    private let profile = VSMProfile(UserId: VSMAPI.VSMChatsCommunication.contactId)
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var WriteMessageButton: UIBarButtonItem!
    @IBOutlet weak var PhotoView: UIView!
    @IBOutlet weak var NavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var UserDataView: UIView!
    @IBOutlet weak var ContactPhoto: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var BirthDayLabel: UILabel!
    @IBOutlet weak var SkypeLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContactPhoto.image = profile?.Icon
        NameLabel.text = "\(profile!.FamilyName) \(profile!.Name) \(profile!.Patronymic)"
        BirthDayLabel.text = profile!.BirthDay.toString()
        if (profile!.Skype != "") {
            SkypeLabel.text = profile!.Skype
        }
        EmailLabel.text = profile!.Email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (writeMessageCheck) {
            WriteMessageButton.image = UIImage(named: "NewChat.png")
            WriteMessageButton.isEnabled = true
        } else {
            WriteMessageButton.image = nil
            WriteMessageButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func writeMessage(_ sender: UIBarButtonItem) {
        if VSMAPI.Connectivity.isConn {
            VSMAPI.VSMChatsCommunication.conversetionId = VSMAPI.Data.getConversationByContact(ContId: VSMAPI.VSMChatsCommunication.contactId)
            performSegue(withIdentifier: "showChatFromContact", sender: self)
        }
    }
    override func setColors(){
        NavigationBarButton.tintColor = UIColor.VSMNavigationBarTitle
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        
        PhotoView.backgroundColor    = UIColor.VSMContentViewBackground
        UserDataView.backgroundColor = UIColor.VSMContentViewBackground
        NameLabel.textColor          = UIColor.VSMBlackWhite
        BirthDayLabel.textColor      = UIColor.VSMBlackWhite
        SkypeLabel.textColor         = UIColor.VSMBlackWhite
        EmailLabel.textColor         = UIColor.VSMBlackWhite
    }
}
