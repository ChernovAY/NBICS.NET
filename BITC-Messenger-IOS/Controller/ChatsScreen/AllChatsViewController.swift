//
//  AllChatsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit
import SwiftyJSON

public class AllChatsViewController: VSMUIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var EInitHandler: Disposable?
    private var convs = [VSMConversation]()
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var AddChatButton: UIBarButtonItem!
    
    @IBOutlet weak var Table: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: AllChatsViewController.Load)}
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?{
            VSMAPI.VSMChatsCommunication.tabBarApplications = (tabItems[2] as! UITabBarItem)
            VSMAPI.VSMChatsCommunication.tabBarChats = (tabItems[0] as! UITabBarItem)
            
            VSMAPI.VSMChatsCommunication.tabBarApplications?.badgeValue = VSMAPI.Data.NNewRequests == 0 ? nil : String(VSMAPI.Data.NNewRequests)
            VSMAPI.VSMChatsCommunication.tabBarChats?.badgeValue = VSMAPI.Data.NNotReadedMessages == 0 ? nil : String(VSMAPI.Data.NNotReadedMessages)
        }
        VSMAPI.Data.chat =              self
        VSMAPI.Data.tabBarController =  self.tabBarController
        Load()
    }
    deinit {
        EInitHandler?.dispose()
        VSMAPI.VSMChatsCommunication.tabBarApplications = nil
        VSMAPI.VSMChatsCommunication.tabBarChats = nil
    }
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convs.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conv = convs[indexPath.row]
        VSMAPI.VSMChatsCommunication.conversetionId = conv.Id
        performSegue(withIdentifier: "showChat", sender: self)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell {
            var conv: VSMConversation!
            conv = convs[indexPath.row]
            cell.ConfigureCell(conversation: conv)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    private func Load(_ b:Bool = true) {
        if b {
            convs = VSMAPI.Data.getConversations()
            if VSMAPI.Settings.login{
                if let usr = VSMAPI.Data.Profile {
                    //self.UserNameLabel.setTitle("\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)", for: .normal)
                    //self.UserPhoto.image = usr.Icon
                }
            }
        } else {
            convs.removeAll()
        }
        self.Table.reloadData()
    }
    
    override func setColors(){
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.VSMNavigationBarTitle]
        AddChatButton.tintColor                                 = UIColor.VSMNavigationBarTitle
        
        tabBarController?.tabBar.barTintColor                   = UIColor.VSMNavigationTabBarBackground
        tabBarController?.tabBar.tintColor                      = UIColor.VSMNavigationTabBarItem
        
        MainView.backgroundColor                                = UIColor.VSMMainViewBackground
        
        Load()
    }
}
