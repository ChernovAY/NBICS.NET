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
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var UserPhoto: CircleImageView!
    @IBOutlet weak var UserNameLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Table.delegate = self
        Table.dataSource = self
        if let usr = VSMAPI.Profile{
            self.UserNameLabel.setTitle("\(usr.Email) (\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)", for: .normal)
            self.UserPhoto.image = usr.Icon
        }
        Load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VSMAPI.UserConversations.array.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conv = VSMAPI.UserConversations.array[indexPath.row]
        VSMAPI.VSMChatsCommunication.conversetionId = conv.Id
        performSegue(withIdentifier: "showChat", sender: self)
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
            
            conv = VSMAPI.UserConversations.array[indexPath.row]
            cell.ConfigureCell(conversation: conv)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    private func Load() {
        VSMConversations.VSMConversationsAssync(loadingDelegate:{(c) in{
            VSMAPI.UserConversations = c
            self.Table.reloadData()
            }()
        })
    }

}
