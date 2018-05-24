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
    
    ///private var mContactsViewModel: ContactsViewModel!
    ///private var mUserDefaults: IUserDefaultsStringsRead!
    
    private var contacts: VSMContacts = VSMContacts()///
    
    ///private var mContacts: [Contact] = [Contact]()
    ///private var mFilteredContacts: [Contact] = [Contact]()
    
    ///private var mInSearchMode: Bool = false
    
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
            
            //if mInSearchMode {
            //    contact = mFilteredContacts[indexPath.row]
            //} else {
            //    contact = mContacts[indexPath.row]
            //}
            contact = contacts.SArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ///if mInSearchMode {
        ///    return mFilteredContacts.count
        ///} else {
            return contacts.SArray.count
        ///}
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       /* if Search.text == nil || Search.text == "" {
            mInSearchMode = false
            view.endEditing(true)
        } else {
            mInSearchMode = true
            let lower = searchBar.text?.lowercased()
            mFilteredContacts = mContacts.filter({ $0.name!.range(of: lower!) != nil })
        }
        
        Table.reloadData()*/
    }

    private func LoadContacts() {
        //mContactsViewModel.SaveContactsFromWeb(email: mUserDefaults.GetUserEmail()!, passwordHash: mUserDefaults.GetUserPasswordHash()!) { result in
        //   self.mContacts = result
        //    self.Table.reloadData()
        //}
        VSMContacts.VSMContactsAssync(loadingDelegate:{(l) in{
            
            self.contacts = l
            self.Table.reloadData()
            
            }()}, ImageLoadedDelegate: {(o) in {print(o.Name)}()})
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
