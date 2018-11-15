//
//  PrivateConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 31.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class PrivateConfigurationsViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray = [VSMSimpleTree]()
    private var Tree: VSMSimpleTree!
    private var configurationURL: String!
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var EmptyContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.dataSource = self
        Table.delegate = self
    }
    deinit {
        Load(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Load()
        if (cArray.count > 0){
            EmptyContentLabel.isHidden = true
        } else {
            EmptyContentLabel.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Load(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateConfigurationCell", for: indexPath) as? PrivateConfigurationCell {
            var tree: VSMSimpleTree!
            tree = cArray[indexPath.row]
            cell.ConfigureCell(treenode: tree, delegate: show)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (inet.isConn) {
            if let u = cArray[indexPath.row].content as? VSMConfiguration{
                if u.CType == "Configuration"{
                    configurationURL = VSMAPI.Settings.caddress + "/#ru/"+u.Code
                    performSegue(withIdentifier: "showPrivateConfiguration", sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationViewController{
            destination.configurationURL = configurationURL
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, completion) in
            let c = self.cArray[indexPath.row]
            if let conf = c.content as? VSMConfiguration
            {
                if conf.DeleteConfiguration() {
                    c.delete(self.show)
                    VSMAPI.Data.loadAll()
                }
            }
        }
        action.image = #imageLiteral(resourceName: "delete")
        action.backgroundColor = .red
        return action
    }
    
    private func show(_ a:[VSMSimpleTree]?){
        self.cArray = a!
        self.Table.reloadData()
    }
    
    private func Load(_ b:Bool = true) {
        if b {
            Tree = VSMSimpleTree()
            Tree.fillTreee(root: Tree, from: VSMAPI.Data.Configurations.values.sorted(by: {$0.npp < $1.npp}))// gеределать на паблик
            Tree.expand(show)
        } else {
            cArray.removeAll()
            Tree = nil
        }
        if (cArray.count > 0){
            EmptyContentLabel.isHidden = true
        } else {
            EmptyContentLabel.isHidden = false
        }
    }
    
    override func setColors(){
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.VSMNavigationBarTitle]
    }
}
