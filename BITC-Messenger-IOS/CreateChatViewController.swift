//
//  CreateChatViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class CreateChatViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray   = [VSMCheckedContact]()
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var NewChatView: UIView!
    
    @IBOutlet weak var NameChatField: UITextField!
    @IBOutlet weak var CreateChatButton: UIButton!
    @IBOutlet weak var Table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        CreateChatButton.layer.cornerRadius = 17
        NameChatField.addBorder()
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CreateChatСontactCell", for: indexPath) as? CreateChatСontactCell {
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
    
    private func Load(_ b:Bool=true) {
        if(b) {
            cArray.removeAll()
            let _Array = VSMAPI.Data.getContacts(type: VSMContact.ContactType.Cont)
            for a in _Array{
                cArray.append(VSMCheckedContact(a,false))
            }
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    @IBAction func createChat(_ sender: UIButton) {
        let newConv = VSMAPI.Data.newConversation(NameChatField.text!)
        
        let nCells = Table.numberOfRows(inSection: 0)
        for i in 0..<nCells{
            if cArray[i].Checked{
                newConv?.Users.append(cArray[i].Contact)
            }
        }
        if newConv!.sendMembers(){
            VSMAPI.Data.loadAll()
        }
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    override func setColors(){
        MainView.backgroundColor         = UIColor.VSMMainViewBackground
        NewChatView.backgroundColor      = UIColor.VSMContentViewBackground
        NameChatField.textColor          = UIColor.VSMBlackWhite
        CreateChatButton.backgroundColor = UIColor.VSMButton
    }
}
