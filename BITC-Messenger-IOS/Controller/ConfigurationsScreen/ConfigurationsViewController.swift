//
//  ConfigurationsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class ConfigurationsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private var isScrolling = false
    private var isNowOpen   = true
    
    private var EInitHandler: Disposable?
    private var EMessageHandler: Disposable?
    private var Conversation: VSMConversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
    
    private let Screen = UIScreen.main.scale
    private let ScreenHeight = UIScreen.main.bounds.height
    private var MoveDistance = -203
    private var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var MessageField: UITextField!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var NameChat: UINavigationItem!
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if !VSMAPI.Connectivity.isConn {return}
        if let mt = MessageField.text{
            if mt == ""{return}//Сделать проверку на пустую строку и строку из пробелов !!!!!!!!!!!!!!!!!!!!!!!!!!!
            //Врееееменно!!!! пока нет файлов
            //для файлов сделать контрол!!!!
            Conversation.Draft.Text = mt
            if VSMAPI.Connectivity.isConn{
                self.isNowOpen = true
                Conversation.sendMessage()
                MessageField.text = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.separatorStyle = UITableViewCellSeparatorStyle.none
        Table.delegate = self
        Table.dataSource = self
        Table.rowHeight = UITableViewAutomaticDimension
        Table.estimatedRowHeight = 300
        
        if EInitHandler     == nil{EInitHandler     = VSMAPI.Data.EInit.addHandler(target: self, handler: ConfigurationsViewController.Load)}
        if EMessageHandler  == nil{EMessageHandler  = VSMAPI.Data.EMessages.addHandler(target: self, handler: ConfigurationsViewController.MessagesRecieved)}

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
        refreshControl.addTarget(self, action: #selector(getOldMessages), for: .valueChanged)
        Table.refreshControl = refreshControl
        Load()
        NameChat.title = Conversation.Name == "" ? Conversation.Users.first(where: ({!$0.isOwnContact}))!.Name : Conversation.Name
        
    }
    deinit {
        EInitHandler?.dispose()
        EMessageHandler?.dispose()
    }
    
    @objc func getOldMessages(refreshControl: UIRefreshControl) {
        self.Conversation.Messages.getData(isAfter:false, jamp: false)
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximumOffset = Int(scrollView.contentSize.height - scrollView.frame.size.height)
        let deltaOffset = maximumOffset - Int(scrollView.contentOffset.y)
        
        if !isScrolling && maximumOffset > 0 && deltaOffset <= -60 {
            isScrolling = true
            //Conversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
            self.Conversation.Messages.getData(isAfter:true, jamp: self.jamp(true))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func jamp(_ isAfter:Bool)->Bool{
        if(isAfter){
            if let lastVisibleMSG = self.Table.visibleCells.last as? MessageCell{
                if isNowOpen || self.Conversation.NotReadedMessagesCount > 0 || (self.Conversation.Messages.array.count > 0 && lastVisibleMSG.mMessage.Id == self.Conversation.Messages.array.last?.Id && self.Conversation.Messages.array.last?.part == self.Conversation.Messages.lastPArt) {
                    return true
                }
                else{
                    return false
                }
            }
            else {
                return true
            }
        }
        else{
            return false
        }
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
        return (Conversation.Messages.array.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            var message: VSMMessage!
           
            if indexPath.row < Conversation.Messages.array.count{
                message = Conversation.Messages.array[indexPath.row]
                cell.ConfigureCell(message: message)
            }
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    func MessagesRecieved(_ parm: (String, Int)){
        if parm.0 != self.Conversation.Id {return}
        self.Table.reloadData()
        if parm.1>=0{
            DispatchQueue.main.async {
                
                    if self.Conversation.Messages.array.count > parm.1 {
                        let indexPath = IndexPath(row: parm.1, section: 0)
                        self.Table.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        self.isScrolling = false
                        self.Table.isHidden = false
                        self.ActivityIndicator.isHidden = true
                    }
            }
        }
        else{
            Table.isHidden = false
            ActivityIndicator.isHidden = true
            self.isScrolling = false
        }
    }
    func Load(_ b:Bool = true){
        if b {
                Conversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
                isScrolling = false
                //MessageField.text = self.Conversation.Draft.Text
                
                if jamp(true){
                            self.Conversation.Messages.getData(isAfter:true, jamp: true)
                            isNowOpen = false
                            self.Conversation.markReaded()
                }
                else{
                    //self.Table.reloadData()
                }
            }
    }
}
