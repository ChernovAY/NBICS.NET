//
//  SearchBarBorderless.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 05.10.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit

class SearchBarBorderless : UISearchBar {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 0
    }
}
