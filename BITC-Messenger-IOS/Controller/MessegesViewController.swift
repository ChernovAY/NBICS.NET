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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC: AllChatsViewController = segue.destination as! AllChatsViewController
        print(destinationVC.conversetionId)
        print("asdasd")
        //let messeges = VSMMessages(ConversationId: conv.Id, loadingDelegate: {(t) in print(t) })
        //messeges.load()
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
