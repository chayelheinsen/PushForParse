//
//  ExtensionDelegate.swift
//  PushForParseWatchApp Extension
//
//  Created by Chayel Heinsen on 10/18/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    // WCSessionDelegate
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        
        if let apps = applicationContext["context"] as? [[String : AnyObject]] {
            
            if apps.count > 0 {
                App.deleteAllApps()
            }
            
            for app in apps {
                
                if let appInfo = app["app"] as? [String : AnyObject] {
                    let app = App(name: appInfo["name"] as! String, apiKey: appInfo["apiKey"] as! String, appId: appInfo["appId"] as! String)
                    
                    if (appInfo["created"] as? NSDate != nil) {
                        app.created = appInfo["created"] as? NSDate
                    }
                    
                    app.save()
                }
            }
        }
    }

    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        
        if let appName = userInfo["deleteApp"] as? String {
            let deleteApp = App.appWithName(appName)
            deleteApp?.delete()
        }
        
        if let appInfo = userInfo["app"] as? [String : AnyObject] {
            let app = App(name: appInfo["name"] as! String, apiKey: appInfo["apiKey"] as! String, appId: appInfo["appId"] as! String)
            
            if (appInfo["created"] as? NSDate != nil) {
                app.created = appInfo["created"] as? NSDate
            }
            
            app.save()
        }
    }
    
}
