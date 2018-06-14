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
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        
        if let usr = WebAPI.Profile{
            self.UserNameLabel.setTitle("\(usr.Email) (\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)", for: .normal)
            self.UserPhoto.image = usr.Icon
        }
        Load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WebAPI.UserConversations.SArray.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conv = WebAPI.UserConversations.SArray[indexPath.row]
        WebAPI.VSMChatsCommunication.conversetionId = conv.Id
        let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
        if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
            self.present(configViewController, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        VSMConversations.VSMConversationsAssync(loadingDelegate:{(c) in{
            WebAPI.UserConversations = c
            self.Table.reloadData()
            }()
        })
    }
    
    /*
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
            case 3:
                let targetStoryboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
                if let settingsControler = targetStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController{
                    self.present(settingsControler, animated: true, completion: nil)
                }
                break
            default: break
        }

    }
 */

}
