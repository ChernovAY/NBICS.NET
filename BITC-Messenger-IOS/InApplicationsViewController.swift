//
//  InApplicationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 11.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class InApplicationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Table: UITableView!
    
    private var aArray   = [VSMContact]()
    
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
        return aArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath) as? ApplicationCell {
            var contact: VSMContact!
            contact = aArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
    }*/
    
    private func Load(_ b:Bool=true) {
        if(b){
            aArray = VSMAPI.Data.getContacts(type: VSMContact.ContactType.Cont)
        }
        else{
            aArray.removeAll()
        }
        self.Table.reloadData()
    }

}
