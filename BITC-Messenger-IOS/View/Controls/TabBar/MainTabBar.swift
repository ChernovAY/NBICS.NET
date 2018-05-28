//
//  MainTabBar.swift
//  NBICS-Messenger-IOS
//
//  Created by АООО "КИЦ ТЦ" on 08.09.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import Foundation
import UIKit

public class MainTabBar : UITabBar {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        InitItems()
    }
    
    private func InitItems() {
        let chatItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "InactiveChat"), selectedImage: UIImage(named: "ActiveChat"))
        
        let contactsItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "InactiveContacts"), selectedImage: UIImage(named: "ActiveContacts"))
        
        /*let iotItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "InactiveIoT"), selectedImage: UIImage(named: "ActiveIoT"))*/
        
        let configItem: UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "InactiveConfig"), selectedImage: UIImage(named: "ActiveConfig"))
        
        chatItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        contactsItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        /*iotItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)*/
        configItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        chatItem.selectedImage = UIImage(named: "ActiveChat")?.withRenderingMode(.alwaysOriginal)
        contactsItem.selectedImage = UIImage(named: "ActiveContacts")?.withRenderingMode(.alwaysOriginal)
        /*iotItem.selectedImage = UIImage(named: "ActiveIoT")?.withRenderingMode(.alwaysOriginal)*/
        configItem.selectedImage = UIImage(named: "ActiveConfig")?.withRenderingMode(.alwaysOriginal)
        
        chatItem.tag = 0
        contactsItem.tag = 1
        /*iotItem.tag = 2*/
        configItem.tag = 3
        
        self.barStyle = .black
        
        self.items?.append(chatItem)
        self.items?.append(contactsItem)
        /*self.items?.append(iotItem)*/
        self.items?.append(configItem)
    }
    
}
