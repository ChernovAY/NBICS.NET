//
//  CommonConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class CommonConfigurationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var cArray = [VSMConfiguration]()
    
    @IBOutlet weak var Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.dataSource = self
        Table.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonConfigurationCell", for: indexPath) as? CommonConfigurationCell {
            var configuration: VSMConfiguration!
            configuration = cArray[indexPath.row]
            cell.ConfigureCell(configuration: configuration)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    /*
    private func Load(_ b:Bool = true) {
        if b {
            cArray = VSMAPI.Data.get
            convs = VSMAPI.Data.getConversations()
            if VSMAPI.Settings.login{
                if let usr = VSMAPI.Data.Profile {
                    self.UserNameLabel.setTitle("\(usr.FamilyName) \(usr.Name) \(usr.Patronymic)", for: .normal)
                    self.UserPhoto.image = usr.Icon
                }
            }
        } else {
            convs.removeAll()
        }
        self.Table.reloadData()
    }
    */
}
