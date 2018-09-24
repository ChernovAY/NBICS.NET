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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func setColors(){
        if VSMAPI.Settings.darkSchreme {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        } else {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        }
        
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.VSMNavigationBarTitle]
        
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
