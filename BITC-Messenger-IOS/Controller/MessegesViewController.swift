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
        print(VSMAPI.VSMChatsCommunication.conversetionId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
