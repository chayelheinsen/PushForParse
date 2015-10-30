//
//  InterfaceController.swift
//  PushForParseWatchApp Extension
//
//  Created by Chayel Heinsen on 10/18/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var noAppsLabel: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    var apps: [App] = [App]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        apps = App.allApps()
        reloadTable()
        
        if WCSession.defaultSession().reachable {
         
            WCSession.defaultSession().sendMessage(["AllApps" : 1], replyHandler: { [weak self] (userInfo) -> Void in
                
                if let weakSelf = self {
                    weakSelf.apps.removeAll(keepCapacity: false)
                }
                
                if let dict = (userInfo as [String : AnyObject])["response"] as? [[String : AnyObject]] {
                    
                    for appObj in dict {
                        
                        let checkApp = App.appWithName(appObj["name"] as! String)
                        
                        if checkApp != nil {
                            
                            if let weakSelf = self {
                                weakSelf.apps.append(checkApp!)
                            }
                            
                        } else {
                            let app = App(name: appObj["name"] as! String, apiKey: appObj["apiKey"] as! String, appId: appObj["appId"] as! String)
                            
                            app.save()
                            
                            if let weakSelf = self {
                                weakSelf.apps.append(app)
                            }
                        }
                        
                    }
                    
                    if let weakSelf = self {
                        weakSelf.reloadTable()
                    }
                }
                
                }) { (error) -> Void in
                    print("Error: \(error)")
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadTable() {
        
        if apps.count == 0 {
            noAppsLabel.setHidden(false)
            table.setHidden(true)
        } else {
            noAppsLabel.setHidden(true)
            table.setHidden(false)
            
            table.setNumberOfRows(apps.count, withRowType: "AppCell")
            
            for var index = 0; index < apps.count; index++ {
                
                let app = apps[index]
                
                if let cell = table.rowControllerAtIndex(index) as? AppCell {
                    cell.name.setText(app.name)
                }
            }

        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
        if segueIdentifier == "PushToSendNotificicationSegue" {
            return apps[rowIndex]
        }
        
        return nil
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        pushControllerWithName("SendNotificationController", context: apps[rowIndex])
    }
    
}
