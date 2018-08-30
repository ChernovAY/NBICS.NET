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
    
    private var isHidden    = true
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
    @IBOutlet weak var ConfigurationButton: UIButton!
    @IBOutlet weak var ConfigurationView: UIView!
    @IBOutlet weak var FilesView: UIView!
    @IBOutlet weak var HeightConstraintFilesView: NSLayoutConstraint!
    @IBOutlet weak var CountFilesLabel: UILabel!
    @IBOutlet weak var HeightConstraintConfigurationsView: NSLayoutConstraint!
    @IBOutlet weak var CountConfigurationsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Table.separatorStyle = UITableViewCellSeparatorStyle.none
        MessageTextView?.layer.cornerRadius = 15
        ConfigurationButton.layer.cornerRadius = 17
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
        isHidden = false
        Load()
    }
    
    deinit {
        EInitHandler?.dispose()
        EMessageHandler?.dispose()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let countFiles = Conversation.Draft.AttachedFiles.count
        let countConfigurations = Conversation.Draft.AttachedConfs.count
        if (Conversation.Name != ""){
            SettingChatButton.isEnabled = true
        } else {
            SettingChatButton.isEnabled = false
        }
        
        //Количество прикрепленных файлов
        HeightConstraintFilesView.constant = CGFloat(20)
        FilesView.isHidden = false
        
        //Количество прикрепленных конфигураций
        HeightConstraintConfigurationsView.constant = CGFloat(20)
        ConfigurationView.isHidden = false
        
        if (countConfigurations == 0){
            HeightConstraintConfigurationsView.constant = CGFloat(0)
            ConfigurationView.isHidden = true
        } else if (countFiles == 1){
            CountConfigurationsLabel.text = String(countConfigurations) + " конфигурация"
        } else if ((countFiles <= 4) && (countFiles != 1)){
            CountConfigurationsLabel.text = String(countConfigurations) + " конфигурации"
        } else if (countFiles >= 5){
            CountConfigurationsLabel.text = String(countConfigurations) + " файлов"
        }
        
        if (countFiles == 0){
            HeightConstraintFilesView.constant = CGFloat(0)
            FilesView.isHidden = true
        } else if (countFiles == 1){
            CountFilesLabel.text = String(countFiles) + " файл"
        } else if ((countFiles <= 4) && (countFiles != 1)){
            CountFilesLabel.text = String(countFiles) + " файла"
        } else if (countFiles >= 5){
            CountFilesLabel.text = String(countFiles) + " файлов"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isHidden = true
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
    
    @IBAction func sendMessageButton(_ sender: Any){
        HeightConstraintFilesView.constant = CGFloat(0)
        FilesView.isHidden = true
        HeightConstraintConfigurationsView.constant = CGFloat(0)
        ConfigurationView.isHidden = true
        if (!VSMAPI.Connectivity.isConn){
            return
        }
        if let mt = MessageTextView.text{
            if (mt == "" && Conversation.Draft.AttachedFiles.count == 0){
                return
            }
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
        VSMAPI.VSMChatsCommunication.AttMessageId = "New"
        performSegue(withIdentifier: "attachmentsFilesSegue", sender: self)
    }
    
    @IBAction func attachConfigurations(_ sender: UIButton) {
        VSMAPI.VSMChatsCommunication.AttMessageId = "New"
        performSegue(withIdentifier: "attachmentsConfigurationsSegue", sender: self)
    }
    
    private func showAttachedFilesOrConfs(_ B:Bool = true){
        if B{
            performSegue(withIdentifier: "attachmentsFilesSegue", sender: self)
        }
        else{
            performSegue(withIdentifier: "attachmentsConfSegue", sender: self)
        }
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
    

    private func jamp(_ isAfter:Bool)->Bool{
        if (isAfter) {
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
                cell.ConfigureCell(message: message, AttchsDelegate: showAttachedFilesOrConfs)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func MessagesRecieved(_ parm: (String, Int)){
        if (parm.0 != self.Conversation.Id){
            return
        }
        self.Table.reloadData()
        if parm.1 >= 0 {
            DispatchQueue.main.async {
                if (self.Conversation.Messages.array.count > parm.1){
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
            if (jamp(true)){
                self.Conversation.Messages.getData(isAfter:true, jamp: true)
                isNowOpen = false
                if (!isHidden){
                    self.Conversation.markReaded()
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: MoveDistance, up: true)
    }
    
}

