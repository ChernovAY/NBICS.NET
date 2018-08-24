//
//  CommonConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class CommonConfigurationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var cArray = [VSMSimpleTree]()
    private var Tree: VSMSimpleTree!
    @IBOutlet weak var Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.dataSource = self
        Table.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Load()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Load(false)
    }
    deinit {
        Load(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonConfigurationCell", for: indexPath) as? CommonConfigurationCell {
            var tree: VSMSimpleTree!
            tree = cArray[indexPath.row]
            cell.ConfigureCell(treenode: tree)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        let conf = cArray[indexPath.row]
        if (conf.children?.count)!>0{
            if conf.isExpanded{
                conf.collapse(show)
            } else {
                conf.expandAll(show)
            }
        }
 
        var configuration: VSMSimpleTree!
        configuration = cArray[indexPath.row]
        print(configuration)
        */
        //Здесь следует проверить, конфигурация это или папка и в первом случае менять переменную configurationURL и
        //переходить в конфигурацию 'ConfigurationViewController'
        performSegue(withIdentifier: "showCommonConfiguration", sender: self)
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
            Tree.fillTreee(root: Tree, from: VSMAPI.Data.PublicConfigurations.values.sorted(by: {$0.npp < $1.npp}))
            Tree.expand(show)
        } else {
            cArray.removeAll()
            Tree = nil
        }
    }
    
}
