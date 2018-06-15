//
//  MessegesViewController.swift
//  BITC-Messenger-IOS
//
//  Created by bender on 06.06.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class MessegesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Получено")
        print(WebAPI.VSMChatsCommunication.conversetionId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
