//
//  AppDelegate.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/16/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var shortcut: UIApplicationShortcutItem?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var performShortcutDelegate = true
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if let launchOptions = launchOptions {
            
            if let shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                shortcut = shortcutItem
                performShortcutDelegate = false
            }
        }
        
        if let _ = ParseAccount.account() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("AppNavigationController") as! UINavigationController
            self.window?.rootViewController = vc
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.window?.rootViewController = vc
        }
        
        return performShortcutDelegate
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if NSUserDefaults.standardUserDefaults().boolForKey("reset_app") {
            ParseAccount.deleteAllAccounts()
            
            NSNotificationCenter.defaultCenter().postNotificationName("AppReset", object: nil)
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "reset_app")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            if shortcut != nil {
                handleShortcut(shortcut!, fromBackground: true)
                shortcut = nil
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //CoreDataController.sharedManager.saveContext()
    }
    
    // MARK: - Watch
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        var watchKitHandler: UIBackgroundTaskIdentifier?
        
        watchKitHandler = UIApplication.sharedApplication().beginBackgroundTaskWithName("BackgroundWatchTask") { () -> Void in
            watchKitHandler = UIBackgroundTaskInvalid
        }
        
        if message["AllApps"] != nil {
            
            let apps = App.allApps()
            var appsArray: [[String : AnyObject]] = [[String : AnyObject]]()
            
            for app in apps {
                let appDict = app.serializeToDictionary()
                appsArray.append(appDict)
            }
            
            replyHandler(["response" : appsArray])
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(watchKitHandler!)
            })
        }
    }
    
    // MARK: 3D Touch
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem, fromBackground: false))
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem, fromBackground: Bool) -> Bool {
        var handled = false
        
        if shortcutItem.type == "com.chayelheinsen.shortcut.new-app" {
            handled = true
            NSTimer.scheduledTimerWithTimeInterval(fromBackground ? 1.0 : 0, target: self, selector: "segueNewApp", userInfo: nil, repeats: false)
        }
        
        return handled
    }
    
    func segueNewApp() {
        NSNotificationCenter.defaultCenter().postNotificationName("segueNewApp", object: nil)
    }
    
}

