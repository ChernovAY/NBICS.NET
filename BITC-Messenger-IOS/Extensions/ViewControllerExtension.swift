//
//  ViewControllerExtension.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 05.10.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
