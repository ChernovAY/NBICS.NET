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
    private var EInitHandler: Disposable?
    private var convs = [VSMConversation]()
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var UserPhoto: CircleImageView!
    @IBOutlet weak var UserNameLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: AllChatsViewController.Load)}
        Load()
    }
    deinit {
        EInitHandler?.dispose()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convs.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conv = convs[indexPath.row]
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
                    self.UserNameLabel.setTitle("\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)", for: .normal)
                    self.UserPhoto.image = usr.Icon
                }
            }
        } else {
            convs.removeAll()
        }
        self.Table.reloadData()
    }
}
