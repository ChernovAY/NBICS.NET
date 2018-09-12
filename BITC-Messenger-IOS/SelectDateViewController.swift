//
//  SelectDateViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 23.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class SelectDateViewController: VSMUIViewController {

    @IBOutlet weak var BirthdayDatePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        BirthdayDatePicker.date = (VSMAPI.Data.Profile?.BirthDay)!
    }
    
    @IBAction func selectDate(_ sender: Any) {
        VSMAPI.Data.Profile?.BirthDay = BirthdayDatePicker.date
        VSMAPI.VSMChatsCommunication.BDayDelegate()
        dismiss(animated: true)
    }
}
