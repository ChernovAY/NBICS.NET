//
//  ContactProfileViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 04.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    private let profile = VSMProfile(UserId: VSMAPI.VSMChatsCommunication.contactId)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func writeMessage(_ sender: UIBarButtonItem) {
        if VSMAPI.Connectivity.isConn {
            VSMAPI.VSMChatsCommunication.conversetionId = VSMAPI.Data.getConversationByContact(ContId: VSMAPI.VSMChatsCommunication.contactId)
            performSegue(withIdentifier: "showChatFromContact", sender: self)
        }
    }
    
}
