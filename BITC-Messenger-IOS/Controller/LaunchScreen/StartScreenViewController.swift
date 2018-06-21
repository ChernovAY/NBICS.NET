//
//  StartScreenViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 22.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController{
    private var m = VSMData()
    /*private var s = VSMData()*///Delegate
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        m.loadAll()
        /*s.messLoaded[self] = {s in print(s)}*///Delegate
    }
    deinit {
        //s.messLoaded.removeValue(forKey: self)
    ///Delegate
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
        // Dispose of any resources that can be recreated.
    }
    private func NavigateToChats() {
        performSegue(withIdentifier: "showChatsScreen", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

}
