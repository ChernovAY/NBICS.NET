//
//  ConfigurationsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ConfigurationsViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var TabBar: MainTabBar!
    @IBOutlet weak var BackItem: UIBarButtonItem!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var MessageField: UITextField!
    
    @IBAction func BackItem(_ sender: Any) {
        let targetStoryboard = UIStoryboard(name: "ContactsStoryboard", bundle: nil)
        if let contactsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "ContactsViewController") as? ContactsViewController {
            self.present(contactsViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[2]
    }
    @IBAction func BackButton(_ sender: Any) {
        let targetStoryboard = UIStoryboard(name: "ChatsStoryboard", bundle: nil)
        if let chatsViewController = targetStoryboard.instantiateViewController(withIdentifier:
            "AllChatsViewController") as? AllChatsViewController {
            self.present(chatsViewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
        case 1:
            let targetStoryboard = UIStoryboard(name: "ContactsStoryboard", bundle: nil)
            if let contactsViewController = targetStoryboard.instantiateViewController(withIdentifier:
                "ContactsViewController") as? ContactsViewController {
                self.present(contactsViewController, animated: true, completion: nil)
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
    */
}
