//
//  CommonConfigurationsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class CommonConfigurationsViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {

    private var cArray = [VSMSimpleTree]()
    private var Tree: VSMSimpleTree!
    private var configurationURL: String!
    
    @IBOutlet var MainView: UIView!
    
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonConfigurationCell", for: indexPath) as? CommonConfigurationCell {
            var tree: VSMSimpleTree!
            tree = cArray[indexPath.row]
            cell.ConfigureCell(treenode: tree, delegate: show)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let u = cArray[indexPath.row].content as? VSMConfiguration{
            if u.CType == "Configuration"{
                configurationURL = VSMAPI.Settings.caddress + "/#ru/"+u.Code
                performSegue(withIdentifier: "showCommonConfiguration", sender: self)
            }
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationViewController{
            destination.configurationURL = configurationURL
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
    
    override func setColors(){
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        
        navigationController?.navigationBar.barTintColor        = UIColor.VSMNavigationBarBackground
        navigationController?.navigationBar.tintColor           = UIColor.VSMNavigationBarTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.VSMNavigationBarTitle]
    }
    
}
