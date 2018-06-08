//
//  ConfigurationsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ConfigurationsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {

    private var Messages: VSMMessages?
    
    @IBOutlet weak var TabBar: MainTabBar!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var MessageField: UITextField!
    @IBOutlet weak var Table: UITableView!
    
    @IBAction func backToChats(_ sender: Any) {
        let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
        if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "AllChatsViewController") as? AllChatsViewController {
            self.present(chatsViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ConversetionId = WebAPI.VSMChatsCommunication.conversetionId
        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[2]
        Table.delegate = self
        Table.dataSource = self
        Messages = VSMMessages(ConversationId: ConversetionId, loadingDelegate: loadedMesseges)
        Messages!.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadedMesseges (b: Bool) {
        if b {self.Table.reloadData()}
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Messages?.getMessages().count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            
            var message: VSMMessage!
            
            message = Messages!.SArray[indexPath.row]
            cell.ConfigureCell(message: message)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
}
