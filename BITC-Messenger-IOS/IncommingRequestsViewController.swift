//
//  IncommingRequestsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 13.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class IncommingRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var EInitHandler: Disposable?
    
    @IBOutlet weak var Table: UITableView!
    private var fArray = [VSMContact]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: IncommingRequestsViewController.Load)}
        Load()
    }
    deinit {
        EInitHandler?.dispose()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "IncommingCell", for: indexPath) as? IncommingCell {
            var contact: VSMContact!
            contact = fArray[indexPath.row]
            cell.ConfigureCell(contact: contact)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let add = addAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, add])
    }
     
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Отклонить") { (action, view, completion) in
            let c = self.fArray[indexPath.row]
            if c.UserContactOperations(VSMAPI.WebAPIEntry.Op_CancelUserRequest){
                VSMAPI.Data.loadAll()
            }
        }
        action.backgroundColor = .red
        action.image = #imageLiteral(resourceName: "delete")
        return action
    }
    
    func addAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Принять") { (action, view, completion) in
            let c = self.fArray[indexPath.row]
            if c.UserContactOperations(VSMAPI.WebAPIEntry.Op_AcceptUserRequest){
                VSMAPI.Data.loadAll()
            }
        }
        action.backgroundColor = UIColor(red: 0.35, green: 0.77, blue: 0.23, alpha: 1.0)
        action.image = #imageLiteral(resourceName: "check")
        return action
    }
    
    private func Load(_ b:Bool=true) {
        if(b) {
            fArray = VSMAPI.Data.getContacts(type: VSMContact.ContactType.In)
        } else {
            fArray.removeAll()
        }
        self.Table.reloadData()
    }
}
