//
//  ContactsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ContactsViewController: VSMUIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var EInitHandler: Disposable?
    private var cArray   = [VSMContact]()
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var SearchContactButton: UIBarButtonItem!
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var Search: UISearchBar!
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Search.delegate = self
        Search.returnKeyType = UIReturnKeyType.done
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: ContactsViewController.Load)}
        Load()
    }
    deinit {
        EInitHandler?.dispose()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cont = cArray[indexPath.row]
        VSMAPI.VSMChatsCommunication.contactId = cont.Id
        performSegue(withIdentifier: "showContactProfile", sender: self)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completion) in
            let c = self.cArray[indexPath.row]
            if c.UserContactOperations(VSMAPI.WebAPIEntry.Op_DeleteUserFromContacts){
                VSMAPI.Data.loadAll()
            }
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return action
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       if Search.text == nil || Search.text == "" {
            view.endEditing(true)
        }
        self.cArray = VSMAPI.Data.getContacts(type: VSMContact.ContactType.Cont, filter: searchBar.text ?? "")
        Table.reloadData()
    }

    private func Load(_ b:Bool=true) {
        if(b) {
            cArray = VSMAPI.Data.getContacts(type: VSMContact.ContactType.Cont)
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    override func setColors(){
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.VSMNavigationBarTitle]
        
        tabBarController?.tabBar.barTintColor                   = UIColor.VSMNavigationTabBarBackground
        tabBarController?.tabBar.tintColor                      = UIColor.VSMNavigationTabBarItem
        
        MainView.backgroundColor                                = UIColor.VSMMainViewBackground
        
        SearchContactButton.tintColor                           = UIColor.VSMNavigationBarTitle
        
        Search.backgroundColor                                  = UIColor.VSMSearchBarBackground
        
        Load()
    }
}
