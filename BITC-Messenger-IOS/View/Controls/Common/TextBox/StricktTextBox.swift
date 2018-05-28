//
//  StricktTextBox.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 23.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit

public class StrickTextBox : UITextField {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.LightGreyColor.cgColor
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 0))
        self.leftViewMode = .always
        
        self.keyboardAppearance = .alert
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = Colors.LightGreyColor.cgColor
    }
    
}
