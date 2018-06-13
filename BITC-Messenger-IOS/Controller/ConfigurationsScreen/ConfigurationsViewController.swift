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
    private let ConversetionId = WebAPI.VSMChatsCommunication.conversetionId
    
    @IBAction func backToChats(_ sender: Any) {
        let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
        if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "AllChatsViewController") as? AllChatsViewController {
            self.present(chatsViewController, animated: true, completion: nil)
        }
    }
 
    @IBAction func sendMessageButton(_ sender: Any) {
        if let mt = MessageField.text{
            if mt == ""{return}//Сделать проверку на пустую строку и строку из пробелов !!!!!!!!!!!!!!!!!!!!!!!!!!!
            let TextMessage: String = MessageField.text!
            VSMMessage(ConversationId: ConversetionId, Draft: false, Id: nil, Sender: WebAPI.Contact!, Text: TextMessage, Time: Date(), CType: ContType.User.rawValue).sendMessage(Messages: self.Messages!, sendDelegate:{(b) in
            {
                if b {
                    self.MessageField.text! = ""
                }
            }()})
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[1]
        Table.delegate = self
        Table.dataSource = self
        Table.rowHeight = UITableViewAutomaticDimension
        Table.estimatedRowHeight = 300
        Messages = VSMMessages(ConversationId: ConversetionId, loadingDelegate: loadedMesseges)
        Messages!.load()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadedMesseges (b: Bool) {
        if b {self.Table.reloadData()}
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.Messages?.SArray.count)!-1, section: 0)
            self.Table.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
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
