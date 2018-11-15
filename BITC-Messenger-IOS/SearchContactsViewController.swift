//
//  SearchContactsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 17.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class SearchContactsViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    private var cArray   = [VSMContact]()
    private var EInitHandler: Disposable?
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var EmptyContentLabel: UILabel!
    @IBOutlet weak var SearchTextField: UITextField!

    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        SearchBar.delegate = self
        SearchBar.returnKeyType = UIReturnKeyType.done
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: SearchContactsViewController.Load)}
        if (cArray.count > 0){
            EmptyContentLabel.isHidden = true
        }
        Load()
    }
    deinit {
        EInitHandler?.dispose()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchContactCell", for: indexPath) as? SearchContactCell {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cont = cArray[indexPath.row]
        VSMAPI.VSMChatsCommunication.contactId = cont.Id
        performSegue(withIdentifier: "showContactProfileFromSearchContact", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (inet.isConn) {
            let add = addAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [add])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func addAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Добавить") { (action, view, completion) in
            let c = self.cArray[indexPath.row]
            if c.UserContactOperations(VSMAPI.WebAPIEntry.Op_SendUserRequest){
                VSMAPI.Data.loadAll()
            }
        }
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = UIColor(red: 0.35, green: 0.77, blue: 0.23, alpha: 1.0)
        return action
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if SearchBar.text == nil || SearchBar.text == "" {
            view.endEditing(true)
        }
        self.cArray = VSMAPI.Data.searchContacts(SearchString: SearchBar.text ?? "")
        Table.reloadData()
    }
    
    private func Load(_ b:Bool=true) {
        if(b) {
            cArray = VSMAPI.Data.searchContacts(SearchString: "")
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    override func setColors(){
        navigationController?.navigationBar.barTintColor = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.VSMNavigationBarTitle]
        
        tabBarController?.tabBar.barTintColor = UIColor.VSMNavigationTabBarBackground
        tabBarController?.tabBar.tintColor = UIColor.VSMNavigationTabBarItem
        
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        
        SearchBar.backgroundColor = UIColor.VSMSearchBarBackground
        let textFieldInsideUISearchBar = SearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.VSMBlackWhite
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(12)
        
        Load()
    }
}
