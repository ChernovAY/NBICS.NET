
//
//  AppDelegate.swift
//  NBICS-Messenger-IOS
//
//  Created by ООО "КИЦ ТЦ" on 22.08.17.
//  Copyright © 2017 riktus. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
import Foundation
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        FirebaseApp.configure()
        Messaging.messaging().shouldEstablishDirectChannel = true
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        if VSMAPI.Settings.darkSchreme {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        } else {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        VSMAPI.Settings.logOut()
        self.saveContext()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BITC_Messenger_IOS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        VSMAPI.Data.timerFired()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        VSMAPI.Data.timerFired()
        VSMAPI.Settings.refreshFB(fcmToken: fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        VSMAPI.Data.timerFired()
        let json = JSON(response.notification.request.content.userInfo)
        if let cat = json["aps"].dictionary!["category"]!.string{
            if cat == "OPEN_CHAT"{
                let convId = json["ConversationId"].string!
                VSMAPI.VSMChatsCommunication.conversetionId = convId
                if let v = VSMAPI.Data.chat, let c = VSMAPI.Data.tabBarController{
                    if let cur = VSMAPI.Data.curConv{
                        cur.navigationController?.popViewController(animated: true)
                    }
                    c.selectedIndex = 0
                    v.performSegue(withIdentifier: "showChat", sender: v)
                }
            } else if cat == "OPEN_REQUESTS"{
                if let c = VSMAPI.Data.tabBarController{
                    c.selectedIndex = 2
                }
            }
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.sound)
        VSMAPI.Data.timerFired()
    }
 
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print ("убрать!!!")
        print(remoteMessage.appData)
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    @objc func refreshToken(notification: NSNotification){
        _ = InstanceID.instanceID().token()!
        FBHandler()
    }
    
    func FBHandler(){
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let DbContext = appDelegate.persistentContainer.newBackgroundContext()

