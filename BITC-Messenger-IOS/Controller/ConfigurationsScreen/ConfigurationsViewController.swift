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
    
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var MessageField: UITextField!
    @IBOutlet weak var Table: UITableView!
    private let ConversetionId = VSMAPI.VSMChatsCommunication.conversetionId
 
    @IBAction func sendMessageButton(_ sender: Any) {
        if let mt = MessageField.text{
            if mt == ""{return}//Сделать проверку на пустую строку и строку из пробелов !!!!!!!!!!!!!!!!!!!!!!!!!!!
            let TextMessage: String = MessageField.text!
            VSMMessage(ConversationId: ConversetionId, Draft: false, Id: nil, Sender: VSMAPI.Contact!, Text: TextMessage, Time: Date(), CType: ContType.User.rawValue).sendMessage(Messages: self.Messages!, sendDelegate:{(b) in
            {
                if b {
                    self.MessageField.text! = ""
                }
            }()})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Table.rowHeight = UITableViewAutomaticDimension
        Table.estimatedRowHeight = 300
        Messages = VSMMessages(ConversationId: ConversetionId, loadingDelegate: loadedMesseges)
        Messages!.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadedMesseges (b: Bool) {
        if b {self.Table.reloadData()}
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.Messages?.array.count)!-1, section: 0)
            self.Table.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Messages?.getMessages().count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            
            var message: VSMMessage!
            
            message = Messages!.array[indexPath.row]
            cell.ConfigureCell(message: message)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
}
