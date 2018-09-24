//
//  CropView.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.09.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import UIKit

class CropView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override func point(inside point: CGPoint, with event:   UIEvent?) -> Bool {
        return false
    }
}
