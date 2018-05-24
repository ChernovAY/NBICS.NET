//
//  SettingsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Александр  Волков on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITabBarDelegate {
    let servers = ["https://nbics.net", "http://sc.gov39.ru", "http://sc.miroland.su", "http://10.10.10.11:8083"]
    var server:String = "https://nbics.net"
    @IBOutlet weak var TabBar: MainTabBar!
    @IBOutlet weak var ServersPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TabBar.delegate = self
        TabBar.selectedItem = TabBar.items?[2]
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
    */
    public func numberOfComponents(in ServersPickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ ServersPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servers.count
    }
    
    func pickerView(_ ServersPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servers[row]
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
        case 2:
            let targetStoryboard = UIStoryboard(name: "ConfigurationsStoryboard", bundle: nil)
            if let configViewController = targetStoryboard.instantiateViewController(withIdentifier: "ConfigurationsViewController") as? ConfigurationsViewController{
                self.present(configViewController, animated: true, completion: nil)
            }
            break
        default: break
        }
        
    }

}
