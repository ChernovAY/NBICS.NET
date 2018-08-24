//
//  PrivateConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 31.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class PrivateConfigurationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray = [VSMSimpleTree]()
    private var Tree: VSMSimpleTree!
    private var configurationURL: String!
    @IBOutlet weak var Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.dataSource = self
        Table.delegate = self
    }
    deinit {
        Load(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
        //Здесь следует проверить, конфигурация это или папка и в первом случае менять переменную configurationURL и
        //переходить в конфигурацию 'ConfigurationViewController'
        performSegue(withIdentifier: "showPrivateConfiguration", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationViewController{
            //destination.configurationURL = configurationURL
            destination.configurationURL = "http://nbics.net/#!ru/SOSH-33-Solnechnaya-sistema"
        }
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
    }
}
