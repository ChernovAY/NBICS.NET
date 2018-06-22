//
//  StartScreenViewController.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 22.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit

class StartScreenViewController: UIViewController{
    
    private var EInitHandler: Disposable?
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if EInitHandler == nil{EInitHandler = VSMAPI.Data.EInit.addHandler(target: self, handler: StartScreenViewController.NavigateToChats)}
    }
    deinit {
        EInitHandler?.dispose()
    }
    override func viewDidAppear(_ animated: Bool) {
        if !VSMAPI.Settings.login{
            performSegue(withIdentifier: "showAuthorizationScreen", sender: self)
        }
        else {
            VSMAPI.Settings.logIn(user: VSMAPI.Settings.user, hash: VSMAPI.Settings.hash)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    public func NavigateToChats(_ b:Bool=true) {
        EInitHandler?.dispose()
        if b{performSegue(withIdentifier: "showChatsScreen", sender: self)}
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }

}
