//
//  StartScreenViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 22.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController{
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    deinit {
    }
    override func viewDidAppear(_ animated: Bool) {
        if !VSMAPI.Settings.login{
            performSegue(withIdentifier: "showAuthorizationScreen", sender: self)
        }
        else {
            VSMAPI.Settings.logIn(user: VSMAPI.Settings.user, hash: VSMAPI.Settings.hash, delegate: self.NavigateToChats)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func NavigateToChats() {
        performSegue(withIdentifier: "showChatsScreen", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

}
