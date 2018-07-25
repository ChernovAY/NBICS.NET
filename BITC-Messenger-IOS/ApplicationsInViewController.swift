//
//  ApplicationsInViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 12.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ApplicationsInViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var Table: UITableView!
    private var cArray   = [VSMContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as? ContactCell {
            
            var contact: VSMContact!
            
            contact = cArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
        }
    }
    
    private func Load(_ b:Bool=true) {
        if(b){
            cArray = VSMAPI.Data.getContacts(type: VSMContact.ContactType.In)
        }
        else{
            cArray.removeAll()
        }
        self.Table.reloadData()
    }

}
