//
//  CheckBox.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class LockButton: UIButton {
    public var checkdelegate:((Bool)->())?
    // Images
    let checkedImage = #imageLiteral(resourceName: "lockOpen")
    let uncheckedImage = #imageLiteral(resourceName: "lockClose")
    // Bool property
    public var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            if let d = checkdelegate{
                d(isChecked)
            }
        }
    }
}
