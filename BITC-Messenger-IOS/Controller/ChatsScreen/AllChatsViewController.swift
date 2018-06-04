//
//  AllChatsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class AllChatsViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var TabBar: MainTabBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tabBarIndex = item.tag
        switch tabBarIndex {
            case 1:
                let targetStoryboard = UIStoryboard(name: "ContactsStoryboard", bundle: nil)
                if let contactsViewController = targetStoryboard.instantiateViewController(withIdentifier:
                    "ContactsViewController") as? ContactsViewController {
                    self.present(contactsViewController, animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
