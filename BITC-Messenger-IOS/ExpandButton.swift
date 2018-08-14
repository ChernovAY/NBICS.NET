//
//  CheckBox.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.07.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class ExpendButton: UIButton {
    public var checkdelegate:((Bool)->())?
    // Images
    let checkedImage = #imageLiteral(resourceName: "turn")
    let uncheckedImage = #imageLiteral(resourceName: "expand")
    // Bool property
    public var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
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
