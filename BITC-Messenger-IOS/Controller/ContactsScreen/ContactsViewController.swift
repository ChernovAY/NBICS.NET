//
//  ContactsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var TabBar: MainTabBar!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var Search: UISearchBar!
    
    
    private var contacts = VSMContacts()
    private var cArray   = [VSMContact]()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ///mContactsViewModel = ContactsViewModel()
        ///mUserDefaults = NSUserDefaultsStrings()
        
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[1]
        
        Table.delegate = self
        Table.dataSource = self
        
        Search.delegate = self
        Search.returnKeyType = UIReturnKeyType.done
        
        /*Реализовать для обновления по прокрутке SER! https://habr.com/post/228881/
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)*/
        
        LoadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //func tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
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
        self.cArray = self.contacts.getContacts(searchBar.text)
        
        Table.reloadData()
    }

    private func LoadContacts() {
        VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{
            
            self.contacts = l
            self.cArray = self.contacts.getContacts()

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
        case 2:
            let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
            if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
                self.present(configViewController, animated: true, completion: nil)
            }
            break
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
