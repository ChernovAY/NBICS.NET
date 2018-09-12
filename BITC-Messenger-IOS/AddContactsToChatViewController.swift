//
//  AddContactsToChatViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 24.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class AddContactsToChatViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {

    private var cArray   = [VSMCheckedContact]()
    private let conv = VSMAPI.VSMChatsCommunication.checkedContactForConversation[0].Conversation
    
    @IBOutlet weak var Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Load()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactToChatCell", for: indexPath) as? AddContactToChatCell {
            var contact: VSMCheckedContact!
            contact = cArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let add = addAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [add])
    }
    
    func addAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Добавить") { (action, view, completion) in
            let c = self.cArray[indexPath.row]
            c.Checked = true
            self.Load()
        }
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = UIColor(red: 0.35, green: 0.77, blue: 0.23, alpha: 1.0)
        return action
    }
   
    private func Load(_ b:Bool=true) {
        if(b) {
            cArray.removeAll()
            cArray = VSMAPI.VSMChatsCommunication.checkedContactForConversation.filter({!$0.Checked})
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    @IBAction func addContacts(_ sender: UIButton) {
        _ = navigationController?.popToViewController((navigationController?.viewControllers[2])! , animated: true)
    }
}
