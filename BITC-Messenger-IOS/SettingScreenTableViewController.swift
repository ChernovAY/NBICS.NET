//
//  SettingScreenTableViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 05.09.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class SettingScreenTableViewController: UITableViewController {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var UserPhoto: CircleImageView!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var PhoneLabel: UILabel!
    @IBOutlet weak var DarkThemeSwitch: UISwitch!
    @IBOutlet weak var ColorThemeLabel: UILabel!
    @IBOutlet weak var PrivateConfigurationsLabel: UILabel!
    @IBOutlet weak var CommonConfigurationsLabel: UILabel!
    
    @IBOutlet var Table: UITableView!
    @IBOutlet weak var ProfileTableCell: UITableViewCell!
    @IBOutlet weak var ColorThemeTableCell: UITableViewCell!
    
    @IBOutlet weak var PrivateConfigurationsTableCell: UITableViewCell!
    @IBOutlet weak var CommonConfigurationsTableCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColors()
        if let usr = VSMAPI.Data.Profile{
            UserPhoto.image = usr.Icon
            NameLabel.text = "\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)"
            EmailLabel.text = "\(usr.Email)"
            PhoneLabel.text = "\(usr.Phone)"
        }
        if (VSMAPI.Settings.darkSchreme == true){
            DarkThemeSwitch.isOn = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let usr = VSMAPI.Data.Profile{
            UserPhoto.image = usr.Icon
            NameLabel.text = "\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)"
            EmailLabel.text = "\(usr.Email)"
            PhoneLabel.text = "\(usr.Phone)"
        }
    }
    @IBAction func switchDarkTheme(_ sender: UISwitch) {
        if (DarkThemeSwitch.isOn == true){
            VSMAPI.Settings.darkSchreme = false
            setColors()
        } else {
            VSMAPI.Settings.darkSchreme = true
            setColors()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func setColors(){
        if VSMAPI.Settings.darkSchreme {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        } else {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        }
        
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.VSMNavigationBarTitle]
        
        Table.backgroundColor = UIColor.VSMMainViewBackground
        ProfileTableCell.backgroundColor = UIColor.VSMContentViewBackground
        NameLabel.textColor = UIColor.VSMBlackWhite
        ColorThemeTableCell.backgroundColor = UIColor.VSMContentViewBackground
        ColorThemeLabel.textColor = UIColor.VSMBlackWhite
        PrivateConfigurationsTableCell.backgroundColor = UIColor.VSMContentViewBackground
        PrivateConfigurationsLabel.textColor = UIColor.VSMBlackWhite
        CommonConfigurationsLabel.textColor = UIColor.VSMBlackWhite
        CommonConfigurationsTableCell.backgroundColor = UIColor.VSMContentViewBackground
        
        tabBarController?.tabBar.barTintColor                   = UIColor.VSMNavigationTabBarBackground
        tabBarController?.tabBar.tintColor                      = UIColor.VSMNavigationTabBarItem
    }
}
