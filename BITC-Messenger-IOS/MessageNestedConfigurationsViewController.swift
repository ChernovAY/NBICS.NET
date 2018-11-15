//
//  MessageNestedConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 23.08.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class MessageNestedConfigurationsViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray = [VSMConfiguration]()
    private var configurationURL:String?
    
    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var Table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageConfigurationCell", for: indexPath) as? MessageConfigurationCell {
            var conf: VSMConfiguration!
            conf = cArray[indexPath.row]
            cell.ConfigureCell(configuration: conf)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let u = cArray[indexPath.row]
        configurationURL = VSMAPI.Settings.caddress + "/#ru/"+u.Code
        performSegue(withIdentifier: "showNestedConfiguration", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationViewController{
            destination.configurationURL = configurationURL
        }
    }
    
    private func Load(_ b:Bool=true) {
        if(b) {
            cArray =  (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Messages.array.first(where: {$0.Id == VSMAPI.VSMChatsCommunication.AttMessageId})!.AttachedConfs)!
        } else {
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    
    override func setColors(){
        MainView.backgroundColor = UIColor.VSMMainViewBackground
    }
}
