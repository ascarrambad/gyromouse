//
//  AppDelegate.swift
//  GyroMouse
//
//  Created by Matteo Riva on 07/08/15.
//  Copyright © 2015 Matteo Riva. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

let yellow = UIColor(red: 255.0/255.0, green: 223.0/255.0, blue: 17.0/255.0, alpha: 1)
let blue = UIColor(red: 41.0/255.0, green: 95.0/255.0, blue: 196.0/255.0, alpha: 1)
let minimumVersion = 0

let DidEnterBackgroundNotification = Notification.Name("DidEnterBackgroundNotification")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let client = ClientHandler()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        Fabric.with([Crashlytics.self()])
        
        if !UserDefaults.standard.bool(forKey: "firstBoot") {
            UserDefaults.standard.set(10, forKey: "moveVelocity")
            UserDefaults.standard.set(1, forKey: "scrollVelocity")
            UserDefaults.standard.set(true, forKey: "shakeToReset")
            UserDefaults.standard.set(true, forKey: "keepScreenActive")
        }
        
        application.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: "keepScreenActive")
        
        client.startBrowsing()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        client.stopBrowsing()
        NotificationCenter.default.post(name: DidEnterBackgroundNotification, object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        client.startBrowsing()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        client.startBrowsing()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

