//
//  ConfigurationsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ConfigurationsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    private var Messages: VSMMessages?
    private let ConversetionId = VSMAPI.VSMChatsCommunication.conversetionId
    private let Screen = UIScreen.main.scale
    private let ScreenHeight = UIScreen.main.bounds.height
    private var MoveDistance = -203
    private var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var MessageField: UITextField!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if let mt = MessageField.text{
            if mt == ""{return}//Сделать проверку на пустую строку и строку из пробелов !!!!!!!!!!!!!!!!!!!!!!!!!!!
            let TextMessage: String = MessageField.text!
            VSMMessage(ConversationId: ConversetionId, Draft: false, Id: nil, Sender: VSMAPI.Contact!, Text: TextMessage, Time: Date()).sendMessage(Messages: self.Messages!, sendDelegate:{(b) in
            {
                if b {
                    self.MessageField.text! = ""
                }
            }()})
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.separatorStyle = UITableViewCellSeparatorStyle.none
        Table.delegate = self
        Table.dataSource = self
        Table.rowHeight = UITableViewAutomaticDimension
        Table.estimatedRowHeight = 300
        Messages = VSMMessages(ConversationId: ConversetionId, loadingDelegate: loadedMesseges)
        Messages!.load()
        if (Screen == 2){
            if (ScreenHeight == 667){
                MoveDistance = -209
            }
        }
        else if (Screen == 3){
            MoveDistance = -222
            if (ScreenHeight == 812){
                MoveDistance = -250
            }
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(doSomething), for: .valueChanged)
        Table.refreshControl = refreshControl
    }
    
    
    @objc func doSomething(refreshControl: UIRefreshControl) {
        Messages!.load()
       
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadedMesseges (b: Bool) {
        self.Table.reloadData()
        if b {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: (self.Messages?.array.count)!-1, section: 0)
                self.Table.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        Table.isHidden = false
        ActivityIndicator.isHidden = true
    }

    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: MoveDistance, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: MoveDistance, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Messages?.getMessages().count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            
            var message: VSMMessage!
            
            message = Messages!.array[indexPath.row]
            cell.ConfigureCell(message: message)
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
}
