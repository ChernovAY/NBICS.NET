//
//  ChatSettingsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 24.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ChatSettingsViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray   = [VSMCheckedContact]()
    private let conv = VSMAPI.VSMChatsCommunication.checkedContactForConversation[0].Conversation
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var AddContactsButton: UIButton!
    @IBOutlet weak var LeftChatButton: UIButton!
    @IBOutlet weak var ChatNameView: UIView!
    
    @IBOutlet weak var SaveNameChatButton: UIButton!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var NameChat: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SaveNameChatButton.layer.cornerRadius = 17
        Table.delegate = self
        Table.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NameChat.text = conv?.Name
        Load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (conv?.sendMembers())!{
            VSMAPI.Data.loadAll()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteContactFromChatCell", for: indexPath) as? DeleteContactFromChatCell {
            var contact: VSMCheckedContact!
            contact = cArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (inet.isConn) {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completion) in
            let c = self.cArray[indexPath.row]
            c.Checked = false
                self.Load()
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return action
    }
    
    private func Load(_ b:Bool=true) {
        if(b) {
            cArray = VSMAPI.VSMChatsCommunication.checkedContactForConversation.filter({$0.Checked})
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    @IBAction func LeaveChat(_ sender: UIButton) {
        if (inet.isConn) {
            conv?.isSendNeeded = true
            if (conv?.LeaveConversation())!{
                VSMAPI.Data.loadAll()
            }
            _ = navigationController?.popToRootViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Не удалось покинуть чат", message: "Нет соединения с интернетом", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveNameChat(_ sender: UIButton) {
        if (inet.isConn) {
            if NameChat.text != conv?.Name && NameChat.text != ""{
                if (conv?.Rename(NameChat.text!))!{
                    VSMAPI.Data.loadAll()
                }
            }
        } else {
            let alert = UIAlertController(title: "Не удалось сохранить имя чата", message: "Нет соединения с интернетом", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func setColors(){
        AddContactsButton.backgroundColor = UIColor.VSMButton
        SaveNameChatButton.backgroundColor = UIColor.VSMButton
        NameChat.textColor = UIColor.VSMBlackWhite
        LeftChatButton.backgroundColor = UIColor.VSMButton
        ChatNameView.backgroundColor = UIColor.VSMContentViewBackground
        
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        
        Load()
    }
    
}
