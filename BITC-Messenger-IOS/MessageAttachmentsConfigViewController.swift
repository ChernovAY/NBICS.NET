//
//  MessageAttachmentsConfigViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 07.08.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class MessageAttachmentsConfigViewController: VSMUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var cArray = [VSMSimpleTree]()
    private var Tree: VSMSimpleTree!
    
    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var EmptyContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.dataSource = self
        Table.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Load()
        if (cArray.count > 0){
            EmptyContentLabel.isHidden = true
        }
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AttachConfigurationCell", for: indexPath) as? AttachConfigurationCell {
            var tree: VSMSimpleTree!
            tree = cArray[indexPath.row]
            cell.ConfigureCell(treenode: tree, delegate: show)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conf = cArray[indexPath.row]
        if (conf.children?.count)!>0{
            if conf.isExpanded{
                conf.collapse(show)
            } else {
                conf.expandAll(show)
            }
        }
    }
    
    private func show(_ a:[VSMSimpleTree]?){
        self.cArray = a!
        self.Table.reloadData()
    }
    
    private func Load(_ b:Bool = true) {
        if b {
            Tree = VSMSimpleTree()
            let _array = VSMAPI.Data.Configurations.values.sorted(by: {$0.npp < $1.npp})
            var _array2 = [VSMCheckedConfiguration]()
            for i in _array{
                let ccfg = VSMCheckedConfiguration(i)
                ccfg.msg = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft
                if let _ = ccfg.msg?.AttachedConfs.first(where: {$0 === ccfg.Conf}) {
                    ccfg.Checked = true
                } else {
                    ccfg.Checked = false
                }
                _array2.append(ccfg)
            }
            Tree.fillTreee(root: Tree, from: _array2)
            Tree.expandAll(show)
        } else {
            cArray.removeAll()
            Tree = nil
        }
    }
    
    override func setColors(){
        MainView.backgroundColor = UIColor.VSMMainViewBackground
    }
}
