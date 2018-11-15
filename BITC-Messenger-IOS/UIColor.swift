//
//  UIColor.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 03.09.2018.
//  Copyright © 2018 riktus. All rights reserved.
//

import Foundation
import UIKit
import _SwiftUIKitOverlayShims

extension UIColor{
    open class var VSMSenderMessageViewBackground:   UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#EAECEC":"#EAECEC")}}
    open class var VSMReceiverMessageViewBackground: UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#E8F4FF":"#3FD1B3")}}
    open class var VSMMainViewBackground:            UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#FFFFFF":"#000000")}}
    open class var VSMButton:                        UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#4AAAFF":"#26B89A")}}
    open class var VSMSearchBarBackground:           UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#FFFFFF":"#393939")}}
    open class var VSMSearchBarText:                 UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#4AAAFF":"#3FD1B3")}}
    open class var VSMContentViewBackground:         UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#EAECEC":"#393939")}}
    open class var VSMWhiteBlack:                    UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#FFFFFF":"#000000")}}
    open class var VSMBlackWhite:                    UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#000000":"#FFFFFF")}}
    open class var VSMNavigationBarBackground:       UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#EAECEC":"#393939")}}
    open class var VSMNavigationBarTitle:            UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#000000":"#FFFFFF")}}
    open class var VSMNavigationTabBarBackground:    UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#EAECEC":"#393939")}}
    open class var VSMNavigationTabBarItem:          UIColor {get{return UIColor(hexString: VSMAPI.Settings.darkSchreme ? "#000000":"#FFFFFF")}}
}
