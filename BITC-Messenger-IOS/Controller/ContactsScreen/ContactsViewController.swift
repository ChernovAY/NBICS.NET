//
//  ContactsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var TabBar: MainTabBar!
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
        
        //TabBar.delegate = self
        //TabBar.selectedItem = TabBar.items?[1]
        
        Table.delegate = self
        Table.dataSource = self
        
        Search.delegate = self
        Search.returnKeyType = UIReturnKeyType.done
        //tst-->
        mess = VSMMessages(ConversationId: "-9223372036854755343", loadingDelegate:self.say)
        //tst--<
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
        //потом может и убрать?
            VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{
                VSMAPI.UserContacts = l
                VSMConversation.contacts.addIfNotExists(from: l.array)
                self.cArray = l.getContacts()
                self.Table.reloadData()
            }()})
    }

    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tabBarIndex = item.tag
        switch tabBarIndex {
        case 0:
            let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
            if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
                "AllChatsViewController") as? AllChatsViewController {
                self.present(chatsViewController, animated: true, completion: nil)
            }
            break
        /*
        case 2:
            let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
            if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
                self.present(configViewController, animated: true, completion: nil)
            }
            break
        */
        case 3:
            let targetStoryboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
            if let settingsControler = targetStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController{
                self.present(settingsControler, animated: true, completion: nil)
            }
            break
        default: break
        }
    }
}
