//
//  ProfileViewController.swift
//  BITC-Messenger-IOS
//
//  Created by bender on 05.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var FullnameLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var BirthDayLabel: UILabel!
    @IBOutlet weak var UserPhoto: UIImageView!
    @IBOutlet weak var FamilyLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var SkypeLabel: UILabel!
    @IBOutlet weak var PatronymicLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let usr = VSMAPI.Profile{
            self.UserPhoto.image = usr.Icon
            self.FullnameLabel.text = "\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)"
            self.NameLabel.text = "\(usr.Name)"
            self.FamilyLabel.text = "\(usr.FamilyName)"
            self.PatronymicLabel.text = "\(usr.Patronymic)"
            self.EmailLabel.text = "\(usr.Email)"
            self.SkypeLabel.text = "\(usr.Skype)"
            self.BirthDayLabel.text = "\(usr.BirthDay.toString())"
        }
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        self.viewDidLoad()
        self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
