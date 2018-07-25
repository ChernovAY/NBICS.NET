//
//  ConfigurationsViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 19.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit
import QuartzCore
import FileProvider

class ConfigurationsViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    private var isScrolling = false
    private var isNowOpen   = true
    
    private var EInitHandler: Disposable?
    private var EMessageHandler: Disposable?
    private var Conversation: VSMConversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
    
    private let Screen = UIScreen.main.scale
    private let ScreenHeight = UIScreen.main.bounds.height
    private var MoveDistance = -253
    private var refreshControl:UIRefreshControl!    
    
    @IBOutlet weak var SettingChatButton: UIBarButtonItem!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var NameChat: UINavigationItem!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var FileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Table.separatorStyle = UITableViewCellSeparatorStyle.none
        MessageTextView?.layer.cornerRadius = 15
        FileButton.layer.cornerRadius = 17
        SendButton.layer.cornerRadius = 17
        MessageTextView?.delegate = self
        
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: ConfigurationsViewController.Load)}
        if EMessageHandler == nil{EMessageHandler = VSMAPI.Data.EMessages.addHandler(target: self, handler: ConfigurationsViewController.MessagesRecieved)}

        if (Screen == 2) {
            if (ScreenHeight == 667){
                MoveDistance = -258
            }
        }
        else if (Screen == 3) {
            MoveDistance = -272
            if (ScreenHeight == 812) {
                MoveDistance = -299
            }
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getOldMessages), for: .valueChanged)
        Table.refreshControl = refreshControl
        Load()
    }
    deinit {
        EInitHandler?.dispose()
        EMessageHandler?.dispose()
    }

    override func viewWillAppear(_ animated: Bool) {
        if (Conversation.Name != ""){
            SettingChatButton.isEnabled = true
        } else {
            SettingChatButton.isEnabled = false
        }
    }
    
    func moveTextView(_ textView: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if !VSMAPI.Connectivity.isConn {return}
        if let mt = MessageTextView.text{
            if mt == ""{return}//Сделать проверку на пустую строку и строку из пробелов !!!!!!!!!!!!!!!!!!!!!!!!!!!
            //Врееееменно!!!! пока нет файлов
            //для файлов сделать контрол!!!!
            Conversation.Draft.Text = mt
            if VSMAPI.Connectivity.isConn{
                self.isNowOpen = true
                Conversation.sendMessage()
                MessageTextView.text = ""
            }
        }
    }
    
    @IBAction func settingChat(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "settingChatSegue", sender: self)
    }
    
    @IBAction func attachFile(_ sender: UIButton) {

    }
    
    @objc func getOldMessages(refreshControl: UIRefreshControl) {
        self.Conversation.Messages.getData(isAfter:false, jamp: false)
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximumOffset = Int(scrollView.contentSize.height - scrollView.frame.size.height)
        let deltaOffset = maximumOffset - Int(scrollView.contentOffset.y)
        
        if let lastVisibleMSG = self.Table.visibleCells.last as? MessageCell{
            if self.Conversation.Messages.array.last?.Id != self.Conversation.LastMessage?.Id && lastVisibleMSG.mMessage.Id == self.Conversation.Messages.array.last?.Id && !isScrolling && maximumOffset > 0 && deltaOffset <= -30 {
                isScrolling = true
                self.Conversation.Messages.getData(isAfter:true, jamp: self.jamp(true))
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func jamp(_ isAfter:Bool)->Bool{
        if(isAfter) {
            if let lastVisibleMSG = self.Table.visibleCells.last as? MessageCell{
                if isNowOpen || self.Conversation.NotReadedMessagesCount > 0 || (self.Conversation.Messages.array.count > 0 && lastVisibleMSG.mMessage.Id == self.Conversation.Messages.array.last?.Id && self.Conversation.Messages.array.last?.part == self.Conversation.Messages.lastPArt) {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        if parm.1>=0 {
            DispatchQueue.main.async {
                if self.Conversation.Messages.array.count > parm.1 {
                    let indexPath = IndexPath(row: parm.1, section: 0)
                    self.Table.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    self.isScrolling = false
                    self.Table.isHidden = false
                    self.ActivityIndicator.isHidden = true
                }
            }
        } else {
            Table.isHidden = false
            ActivityIndicator.isHidden = true
            self.isScrolling = false
        }
    }
    func Load(_ b:Bool = true){
        if b {
            Conversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
            NameChat.title = Conversation.Name == "" ? Conversation.Users.first(where: ({!$0.isOwnContact}))!.Name : Conversation.Name
            isScrolling = false
            if jamp(true) {
                self.Conversation.Messages.getData(isAfter:true, jamp: true)
                isNowOpen = false
                self.Conversation.markReaded()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: MoveDistance, up: true)
    }
    
}

