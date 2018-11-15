//
//  ViewControllerExtension.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 05.10.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController  {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

open class VSMUIViewController: UIViewController {
    var DarkScheme: Bool? = VSMAPI.Settings.darkSchreme
    open override func viewDidLoad() {
        super.viewDidLoad()
        setColors();
    }
    
    open override func viewWillAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if DarkScheme != VSMAPI.Settings.darkSchreme{
            setColors();
            DarkScheme = VSMAPI.Settings.darkSchreme
        }
    }
    
    func setColors(){
        
    }
}
