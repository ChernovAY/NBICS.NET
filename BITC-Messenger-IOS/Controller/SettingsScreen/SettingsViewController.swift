//
//  SettingsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITabBarDelegate {
    
    let servers = ["https://nbics.net", "http://sc.gov39.ru", "http://sc.miroland.su", "http://10.10.10.11:8083"]
    var server:String = "https://nbics.net"
    
    @IBOutlet weak var ServersPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public func numberOfComponents(in ServersPickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ ServersPickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servers.count
    }
    
    func pickerView(_ ServersPickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servers[row]
    }

}
