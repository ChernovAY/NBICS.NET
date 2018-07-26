//
//  MessageAttachmentsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 25.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class MessageAttachmentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var cArray = [VSMAttachedFile]()
    @IBOutlet weak var Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageAttachmentsCell", for: indexPath) as? MessageAttachmentsCell {
            var file: VSMAttachedFile!
            file = cArray[indexPath.row]
            cell.ConfigureCell(file: file)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    func Load(_ b:Bool = true){
        if b {
            cArray =  (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Messages.array.first(where: {$0.Id == VSMAPI.VSMChatsCommunication.AttMessageId})!.AttachedFiles)!
        }
        else{
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
}
