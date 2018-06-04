//
//  AllChatsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit
import SwiftyJSON

class AllChatsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TabBar: MainTabBar!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var UserPhoto: CircleImageView!
    @IBOutlet weak var UserNameLabel: UIButton!
    @IBOutlet weak var UserFullNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[0]
    
        Table.delegate = self
        Table.dataSource = self
        Load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WebAPI.UserConversations.SArray.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
        if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
            self.present(configViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell {
            
            var conv: VSMConversation!
            
            conv = WebAPI.UserConversations.SArray[indexPath.row]
            cell.ConfigureCell(conversation: conv)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    private func Load() {
        //потом может и убрать?
        VSMConversations.VSMConversationsAssync(loadingDelegate:{(c) in{
            WebAPI.UserConversations = c
            

            
            self.Table.reloadData()
            
            self.getUserContact()
            }()
            })
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tabBarIndex = item.tag
        switch tabBarIndex {
            case 1:
                let targetStoryboard = UIStoryboard(name: "ContactsStoryboard", bundle: nil)
                if let contactsViewController = targetStoryboard.instantiateViewController(withIdentifier:
                    "ContactsViewController") as? ContactsViewController {
                    self.present(contactsViewController, animated: true, completion: nil)
                }
                break
            /*
            case 2:
                let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
                if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
                    self.present(configViewController, animated: true, completion: nil)
                }
                break
            */
            case 3:
                let targetStoryboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
                if let settingsControler = targetStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController{
                    self.present(settingsControler, animated: true, completion: nil)
                }
                break
            default: break
        }

    }

    private func getUserContact(){
        WebAPI.Request(addres: WebAPI.Settings.caddress, entry: WebAPI.WebAPIEntry.userInformation, params: ["email" : WebAPI.Settings.user, "passwordHash" : WebAPI.Settings.hash], completionHandler: {(d,s) in{
            
            if(!s){
                UIAlertView(title: "Ошибка", message: d as? String, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK").show()
            }
            else{
                if d is Data {
                    let data = d as! Data
                    if let json = try? JSON(data: data) {
                        let dict = json.dictionary!
                        let c =  VSMConversation.contacts.findOrCreate(what: dict)
                        c?.isOwnContact = true
                        if let usr = VSMConversation.contacts.SArray.first(where: ({$0.isOwnContact})) {
                            self.UserFullNameLabel.text = usr.Name
                            self.UserPhoto.image = usr.Photo
                        }
                    }
                }
            }
            }()})
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
