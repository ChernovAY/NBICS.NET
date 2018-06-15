//
//  ContactsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var Search: UISearchBar!
    
    
    //tst-->
    private func say(_ c:Bool){
        if(c){
            print(self.mess!)
        }
    }
    private var conv =  VSMConversations()
    private var mess : VSMMessages?
    //tst--<

    private var cArray   = [VSMContact]()
    var refreshControl:UIRefreshControl!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Table.delegate = self
        Table.dataSource = self
        
        Search.delegate = self
        Search.returnKeyType = UIReturnKeyType.done
        LoadContacts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       if Search.text == nil || Search.text == "" {
            view.endEditing(true)
        }
       else{

        }
        self.cArray = VSMAPI.UserContacts.getContacts(searchBar.text)
        
        Table.reloadData()
    }

    private func LoadContacts() {
            VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{
                VSMAPI.UserContacts = l
                VSMConversation.contacts.addIfNotExists(from: l.array)
                self.cArray = l.getContacts()
                self.Table.reloadData()
            }()})
    }
}
