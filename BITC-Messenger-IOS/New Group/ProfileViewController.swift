//
//  ProfileViewController.swift
//  BITC-Messenger-IOS
//
//  Created by bender on 05.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

extension UITextField {
    func deleteBorder() {
        self.layer.sublayers?.forEach {
            if $0.value(forKey: "Delete THIS") != nil {
                $0.removeFromSuperlayer()
            }
        }
        self.isEnabled = false
    }
    
    func addBorder() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        border.setValue(true, forKey: "Delete THIS")
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.isEnabled = true
    }
}

class ProfileViewController: VSMUIViewController{
    
    
    @IBOutlet weak var UserPhoto: UIImageView!
    @IBOutlet weak var NameField: UITextField!
    @IBOutlet weak var FamilyField: UITextField!
    @IBOutlet weak var PatronymicField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var BirthdayButton: UIButton!
    @IBOutlet weak var SkypeField: UITextField!
    @IBOutlet weak var NewTextField: UITextField!
    
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var ExitButton: UIButton!
    @IBOutlet weak var PhotoView: UIView!
    @IBOutlet weak var InformationView: UIView!
    @IBOutlet weak var ContactsView: UIView!
    @IBOutlet weak var NavigationBarButton: UIBarButtonItem!
    @IBOutlet weak var InformaionLabel: UILabel!
    @IBOutlet weak var ContactsLabel: UILabel!
    
    
    var effect:UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let usr = VSMAPI.Data.Profile{
            UserPhoto.image = usr.Icon
            NameField.text = "\(usr.Name)"
            FamilyField.text = "\(usr.FamilyName)"
            PatronymicField.text = "\(usr.Patronymic)"
            EmailField.text = "\(usr.Email)"
            SkypeField.text = "\(usr.Skype)"
            VSMAPI.VSMChatsCommunication.BDayDelegate = setBDateButton
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        UserPhoto.isUserInteractionEnabled = true
        UserPhoto.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        if (EditButton.title == "Сохранить") {
            //Загрузить новое фото
            performSegue(withIdentifier: "showPhotoEditor", sender: self)
        }
    }
    
    public func setBDateButton(){
        BirthdayButton.setTitle("\((VSMAPI.Data.Profile?.BirthDay.toString())!)", for: .normal)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        BirthdayButton.setTitle("\((VSMAPI.Data.Profile?.BirthDay.toString())!)", for: .normal)
        if let usr = VSMAPI.Data.Profile{
            UserPhoto.image = usr.Icon
            NameField.text = "\(usr.Name)"
            FamilyField.text = "\(usr.FamilyName)"
            PatronymicField.text = "\(usr.Patronymic)"
            EmailField.text = "\(usr.Email)"
            SkypeField.text = "\(usr.Skype)"
            VSMAPI.VSMChatsCommunication.BDayDelegate = setBDateButton
        }
    }
    
    @IBAction func EditProfile(_ sender: UIBarButtonItem) {
        if (EditButton.title == "Редактировать") {
            EditButton.title = "Сохранить"
            NameField.addBorder()
            FamilyField.addBorder()
            PatronymicField.addBorder()
            SkypeField.addBorder()
            BirthdayButton.isEnabled = true
        } else {
            EditButton.title = "Редактировать"
            NameField.deleteBorder()
            FamilyField.deleteBorder()
            PatronymicField.deleteBorder()
            SkypeField.deleteBorder()
            VSMAPI.Data.Profile?.Name = NameField.text!
            VSMAPI.Data.Profile?.FamilyName = FamilyField.text!
            VSMAPI.Data.Profile?.Patronymic = PatronymicField.text!
            VSMAPI.Data.Profile?.Skype = SkypeField.text!
            if VSMAPI.Data.Profile!.setChanges(){
                VSMAPI.Data.loadAll()
            }
            BirthdayButton.isEnabled = false
        }
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        VSMAPI.Settings.logOut()
        self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
    }
    override func setColors(){
        NavigationBarButton.tintColor = UIColor.VSMNavigationBarTitle
        
        MainView.backgroundColor = UIColor.VSMMainViewBackground
 
        PhotoView.backgroundColor = UIColor.VSMContentViewBackground
        
        InformationView.backgroundColor = UIColor.VSMContentViewBackground
        NameField.textColor = UIColor.VSMBlackWhite
        PatronymicField.textColor = UIColor.VSMBlackWhite
        FamilyField.textColor = UIColor.VSMBlackWhite
        BirthdayButton.setTitleColor(UIColor.VSMBlackWhite, for: .normal)
        InformaionLabel.textColor = UIColor.VSMButton
        
        ContactsView.backgroundColor = UIColor.VSMContentViewBackground
        EmailField.textColor = UIColor.VSMBlackWhite
        SkypeField.textColor = UIColor.VSMBlackWhite
        ContactsLabel.textColor = UIColor.VSMButton
        
        ExitButton.backgroundColor = UIColor.VSMButton
    }
}
