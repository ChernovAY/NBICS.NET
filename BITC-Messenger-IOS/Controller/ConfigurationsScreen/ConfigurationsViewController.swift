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
import ActiveLabel

public class ConfigurationsViewController: VSMUIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
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
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var NewMessageView:                      UIView!
    @IBOutlet weak var SettingChatButton:                   UIBarButtonItem!
    @IBOutlet weak var SendButton:                          UIButton!
    @IBOutlet weak var ActivityIndicator:                   UIActivityIndicatorView!
    @IBOutlet weak var Table:                               UITableView!
    @IBOutlet weak var collectionView:                      UICollectionView!
    @IBOutlet weak var NameChat:                            UINavigationItem!
    @IBOutlet weak var MessageTextView:                     UITextView!
    @IBOutlet weak var FileButton:                          UIButton!
    @IBOutlet weak var ConfigurationButton:                 UIButton!
    @IBOutlet weak var MessageTextViewHC:                   NSLayoutConstraint!
    
    @IBOutlet weak var FilesView:                           UIView!
    @IBOutlet weak var HeightConstraintFilesView:           NSLayoutConstraint!
    @IBOutlet weak var CountFilesLabel:                     UILabel!
    @IBOutlet weak var FilesImage:                          UIImageView!
    
    @IBOutlet weak var ConfigurationView:                   UIView!
    @IBOutlet weak var HeightConstraintConfigurationsView:  NSLayoutConstraint!
    @IBOutlet weak var CountConfigurationsLabel:            UILabel!
    @IBOutlet weak var ConfigurationImage:                  UIImageView!
    
    @IBOutlet weak var CopiedMessagesView:                  UIView!
    @IBOutlet weak var HeightConstraintCopiedMessageView:   NSLayoutConstraint!
    @IBOutlet weak var NameUserCopiedMessagesLabel:         UILabel!
    @IBOutlet weak var CountCopiedMessagesLabel:            UILabel!
    @IBOutlet weak var DeleteCopiedMessagesButton:          UIButton!
    @IBOutlet weak var CopiedMessagesImage:                 UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        VSMAPI.Data.curConv = self
        Table.separatorStyle = UITableViewCell.SeparatorStyle.none
        MessageTextView?.layer.cornerRadius = 15
        ConfigurationButton.layer.cornerRadius = 17
        FileButton.layer.cornerRadius = 17
        SendButton.layer.cornerRadius = 17
        MessageTextView?.delegate = self
        if (EInitHandler == nil) {
            EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: ConfigurationsViewController.Load)
        }
        if (EMessageHandler == nil) {
            EMessageHandler = VSMAPI.Data.EMessages.addHandler(target: self, handler: ConfigurationsViewController.MessagesRecieved)
        }
        if (Screen == 2) {
            if (ScreenHeight == 667) {
                MoveDistance = -258
            }
        } else if (Screen == 3) {
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
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        let countFiles = Conversation.Draft.AttachedFiles.count
        let countConfigurations = Conversation.Draft.AttachedConfs.count
        if (Conversation.Name != "") {
            SettingChatButton.image = #imageLiteral(resourceName: "ChatSettings")
            SettingChatButton.isEnabled = true
        } else {
            SettingChatButton.image = nil
            SettingChatButton.isEnabled = false
        }
        //Количество прикрепленных файлов
        HeightConstraintFilesView.constant = CGFloat(20)
        FilesView.isHidden = false
        //Количество прикрепленных конфигураций
        HeightConstraintConfigurationsView.constant = CGFloat(20)
        ConfigurationView.isHidden = false
        //Количество прикрепленных сообщений
        HeightConstraintCopiedMessageView.constant = CGFloat(40)
        CopiedMessagesView.isHidden = false
        if (VSMAPI.VSMChatsCommunication.copiedArrayMessages == nil) {
            HeightConstraintCopiedMessageView.constant = CGFloat(0)
            CopiedMessagesView.isHidden = true
        } else {
            FileButton.isHidden = true
            ConfigurationButton.isHidden = true
            NameUserCopiedMessagesLabel.text = VSMAPI.VSMChatsCommunication.copiedArrayMessages!.Sender!.Name
            Conversation.Draft.AttachedFiles.removeAll()
            Conversation.Draft.AttachedConfs.removeAll()
            HeightConstraintFilesView.constant = CGFloat(0)
            FilesView.isHidden = true
            HeightConstraintConfigurationsView.constant = CGFloat(0)
            ConfigurationView.isHidden = true
        }
        if (countConfigurations == 0) {
            HeightConstraintConfigurationsView.constant = CGFloat(0)
            ConfigurationView.isHidden = true
        } else if (countConfigurations == 1) {
            CountConfigurationsLabel.text = String(countConfigurations) + " конфигурация"
        } else if ((countConfigurations <= 4) && (countConfigurations != 1)) {
            CountConfigurationsLabel.text = String(countConfigurations) + " конфигурации"
        } else if (countConfigurations >= 5){
            CountConfigurationsLabel.text = String(countConfigurations) + " конфигураций"
        }
        if (countFiles == 0) {
            HeightConstraintFilesView.constant = CGFloat(0)
            FilesView.isHidden = true
        } else if (countFiles == 1) {
            CountFilesLabel.text = String(countFiles) + " файл"
        } else if ((countFiles <= 4) && (countFiles != 1)) {
            CountFilesLabel.text = String(countFiles) + " файла"
        } else if (countFiles >= 5) {
            CountFilesLabel.text = String(countFiles) + " файлов"
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        isHidden = true
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell {
            var message: VSMMessage!
            if (indexPath.row < Conversation.Messages.array.count) {
                message = Conversation.Messages.array[indexPath.row]
                cell.ConfigureCell(message: message, AttchsDelegate: showAttachedFilesOrConfs)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Conversation.Messages.array.count)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let message = Conversation.Messages.array[indexPath.row]
        let sender = message.Sender?.Name ?? "None"
        let countFiles = Conversation.Messages.array[indexPath.row].AttachedConfs.count
        let countConfigurations = Conversation.Messages.array[indexPath.row].AttachedFiles.count
        if (countFiles == 0 && countConfigurations == 0 && sender != "None") {
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }
        return UISwipeActionsConfiguration(actions: [])
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let currHeight = self.MessageTextView.contentSize.height + 3
        if (currHeight < 74) {
            MessageTextViewHC.constant = currHeight
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, completion) in
            VSMAPI.VSMChatsCommunication.copiedArrayMessages = self.Conversation.Messages.array[indexPath.row]
            self.HeightConstraintCopiedMessageView.constant = CGFloat(40)
            self.CopiedMessagesView.isHidden = false
            self.FileButton.isHidden = true
            self.ConfigurationButton.isHidden = true
            self.NameUserCopiedMessagesLabel.text = VSMAPI.VSMChatsCommunication.copiedArrayMessages!.Sender!.Name
            self.Conversation.Draft.AttachedFiles.removeAll()
            self.Conversation.Draft.AttachedConfs.removeAll()
            self.HeightConstraintFilesView.constant = CGFloat(0)
            self.FilesView.isHidden = true
            self.HeightConstraintConfigurationsView.constant = CGFloat(0)
            self.ConfigurationView.isHidden = true
        }
        action.backgroundColor = .gray
        action.image = UIImage(named: "CopyMessage.png")
        return action
    }
    
    @IBAction func sendMessageButton(_ sender: Any){
        if (inet.isConn) {
            let copiedArrayMessages = VSMAPI.VSMChatsCommunication.copiedArrayMessages
            HeightConstraintFilesView.constant = CGFloat(0)
            FilesView.isHidden = true
            HeightConstraintConfigurationsView.constant = CGFloat(0)
            ConfigurationView.isHidden = true
            HeightConstraintCopiedMessageView.constant = CGFloat(0)
            CopiedMessagesView.isHidden = true
            if var mt = MessageTextView.text {
                if (mt == "" && Conversation.Draft.AttachedFiles.count == 0 && Conversation.Draft.AttachedConfs.count == 0 && copiedArrayMessages == nil) {
                    return
                }
                if (copiedArrayMessages != nil) {
                    if mt != "" {
                       mt = mt + "\n"
                    }
                    Conversation.Draft.Text = mt + "  //Сообщение от " + copiedArrayMessages!.Sender!.FirstName + " " + copiedArrayMessages!.Sender!.SurName + "\n  //" + ((copiedArrayMessages?.Time.toTimeString())!)
                    Conversation.Draft.Text = Conversation.Draft.Text + "\n  " + copiedArrayMessages!.Text
                } else {
                    Conversation.Draft.Text = mt
                }
                self.isNowOpen = true
                Conversation.sendMessage()
                MessageTextView.text = ""
                VSMAPI.VSMChatsCommunication.copiedArrayMessages = nil
            }
            MessageTextViewHC.constant = 36
        } else {
            let alert = UIAlertController(title: "Не удалось отправить сообщение", message: "Нет соединения с интернетом", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func deleteCopiedMessages(_ sender: Any) {
        HeightConstraintCopiedMessageView.constant = CGFloat(0)
        CopiedMessagesView.isHidden = true
        FileButton.isHidden = false
        ConfigurationButton.isHidden = false
        VSMAPI.VSMChatsCommunication.copiedArrayMessages = nil
    }
    
    
    @objc func getOldMessages(refreshControl: UIRefreshControl) {
        self.Conversation.Messages.getData(isAfter:false, jamp: false)
        refreshControl.endRefreshing()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func jamp(_ isAfter:Bool)->Bool {
        if (isAfter) {
            if let lastVisibleMSG = self.Table.visibleCells.last as? MessageCell {
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximumOffset = Int(scrollView.contentSize.height - scrollView.frame.size.height)
        let deltaOffset = maximumOffset - Int(scrollView.contentOffset.y)
        if let lastVisibleMSG = self.Table.visibleCells.last as? MessageCell {
            if self.Conversation.Messages.array.last?.Id != self.Conversation.LastMessage?.Id && lastVisibleMSG.mMessage.Id == self.Conversation.Messages.array.last?.Id && !isScrolling && maximumOffset > 0 && deltaOffset <= -30 {
                isScrolling = true
                self.Conversation.Messages.getData(isAfter:true, jamp: self.jamp(true))
            }
        }
    }
    
    private func showAttachedFilesOrConfs(_ B:Bool = true) {
        if B {
            performSegue(withIdentifier: "attachmentsFilesSegue", sender: self)
        } else {
            performSegue(withIdentifier: "attachmentsConfSegue", sender: self)
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
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: MoveDistance, up: true)
    }
    
    func MessagesRecieved(_ parm: (String, Int)) {
        if (parm.0 != self.Conversation.Id) {
            return
        }
        self.Table.reloadData()
        if (parm.1 >= 0) {
            DispatchQueue.main.async {
                if (self.Conversation.Messages.array.count > parm.1) {
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
    
    func Load(_ b:Bool = true) {
        if b {
            if (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId] != nil) {
                Conversation = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]!
                NameChat.title = Conversation.Name == "" ? Conversation.Users.first(where: ({!$0.isOwnContact}))!.Name : Conversation.Name
                isScrolling = false
                if (jamp(true)) {
                    self.Conversation.Messages.getData(isAfter:true, jamp: true)
                    isNowOpen = false
                    if (!isHidden) {
                        self.Conversation.markReaded()
                    }
                }
            }
        }
    }
    
    override func setColors(){
        MainView.backgroundColor              = UIColor.VSMWhiteBlack
        Table.backgroundColor                 = UIColor.VSMWhiteBlack
        NewMessageView.backgroundColor        = UIColor.VSMContentViewBackground
        FileButton.backgroundColor            = UIColor.VSMButton
        ConfigurationButton.backgroundColor   = UIColor.VSMButton
        SendButton.backgroundColor            = UIColor.VSMButton
        SettingChatButton.tintColor           = UIColor.VSMBlackWhite
        ActivityIndicator.color               = UIColor.VSMBlackWhite
        
        FilesView.backgroundColor             = UIColor.VSMNavigationTabBarBackground
        CountFilesLabel.textColor             = UIColor.VSMBlackWhite
        
        ConfigurationView.backgroundColor     = UIColor.VSMNavigationTabBarBackground
        CountConfigurationsLabel.textColor    = UIColor.VSMBlackWhite

        CopiedMessagesView.backgroundColor    = UIColor.VSMNavigationTabBarBackground
        CountCopiedMessagesLabel.textColor    = UIColor.VSMBlackWhite
        
        NameUserCopiedMessagesLabel.textColor = UIColor.VSMButton
        
        if VSMAPI.Settings.darkSchreme {
            let textImage = UIImage(named: "delete.png")
            self.DeleteCopiedMessagesButton.setImage(textImage, for: .normal)
            CopiedMessagesImage.image = UIImage(named: "CopiedMessages.png")
            FilesImage.image = UIImage(named: "Clip.png")
            ConfigurationImage.image = UIImage(named: "Gears.png")
        } else {
            let textImage = UIImage(named: "whiteDelete.png")
            self.DeleteCopiedMessagesButton.setImage(textImage, for: .normal)
            CopiedMessagesImage.image = UIImage(named: "WhiteCopiedMessages.png")
            FilesImage.image = UIImage(named: "WhiteClip.png")
            ConfigurationImage.image = UIImage(named: "WhiteGears.png")
        }
        Load()
    }
    
}



