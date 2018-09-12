//
//  MessageAttachmentsViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 25.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit
import MobileCoreServices

class MessageAttachmentsViewController: VSMUIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIDocumentInteractionControllerDelegate, UIDocumentPickerDelegate {
   
    private var docController:UIDocumentInteractionController!
    private var cArray = [VSMAttachedFile]()
    
    @IBOutlet var MainView: UIView!
    
    @IBOutlet weak var Table: UICollectionView!
    @IBOutlet weak var AttachFileButton: UIButton!
    @IBOutlet weak var NavigationTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Table.delegate = self
        Table.dataSource = self
        Load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {swichNavigationBar(state: true);}
        if let MSG = VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft{
            for f in urls{
                var isDirectory = ObjCBool(false)
                let isExists = FileManager.default.fileExists(atPath: f.path, isDirectory: &isDirectory)
                if !isDirectory.boolValue && isExists{
                    MSG.attachFile(fileURL: f)
                }
            }
            Load()
        }
    }
   
  
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageAttachmentsCell", for: indexPath) as? MessageAttachmentsCell {
            var file: VSMAttachedFile!
            file = cArray[indexPath.row]
            cell.ConfigureCell(file: file, previewDelegate: preview, stateDelegate: swichNavigationBar)
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    public func preview(url:URL){
        docController = UIDocumentInteractionController(url: url)
        docController.name = url.lastPathComponent
        docController.delegate = self
        docController.presentPreview(animated: true)
    }
    
    func Load(_ b:Bool = true){
        if b {
            if VSMAPI.VSMChatsCommunication.AttMessageId == "New"{
                cArray =  (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Draft.AttachedFiles)!
                AttachFileButton.isHidden = false
            }
            else{    cArray =  (VSMAPI.Data.Conversations[VSMAPI.VSMChatsCommunication.conversetionId]?.Messages.array.first(where: {$0.Id == VSMAPI.VSMChatsCommunication.AttMessageId})!.AttachedFiles)!
            }
        }
        else{
            cArray.removeAll()
        }
        self.Table.reloadData()
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    public func swichNavigationBar(state: Bool){
        if (state == true){
            navigationItem.hidesBackButton = true
            NavigationTitle.title = "Подождите..."
            
        } else {
            navigationItem.hidesBackButton = false
            NavigationTitle.title = ""
            Load()
        }
    }
    
    @IBAction func attachFile(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content","public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .pageSheet
        documentPicker.allowsMultipleSelection = true
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    override func setColors(){
        MainView.backgroundColor = UIColor.VSMMainViewBackground
        AttachFileButton.backgroundColor = UIColor.VSMButton
    }
}
