//
//  AppsTableViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/16/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import WatchConnectivity

class AppsTableViewController: UITableViewController {

    var apps: Array<App> = Array<App>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addApplicationSegue")
        
        let edit: UIBarButtonItem = UIBarButtonItem(image: Ionicons.imageWithIcon(Ionicon.Ios7CogOutline, size: 26, color: UIColor.whiteColor()), style: .Plain, target: self, action: "goToSettings")
        
        navigationItem.rightBarButtonItem = add
        navigationItem.leftBarButtonItem = edit
        
        navigationItem.title = "Apps"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        apps = App.allApps()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.editing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: String = "AppCell"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell?.textLabel?.text = apps[indexPath.row].name
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            let app: App = apps[indexPath.row]
            
            if WCSession.defaultSession().watchAppInstalled {
                WCSession.defaultSession().transferUserInfo(["deleteApp" : app.name!])
            }
            
            app.delete()
            
            apps.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if apps.count == 0 {
                tableView.editing = false
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String)
        
        if let version = version {
            
            if let build = build {
                return "Push For Parse : Version \(version) : Build \(build)"

            }
        }
        
        return "Push For Parse"
        
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sendNotification = SendNotificationTableViewController(style: .Grouped)
        sendNotification.app = apps[tableView.indexPathForSelectedRow!.row]
        self.navigationController?.pushViewController(sendNotification, animated: true)
    }
    
    // MARK: - Helpers
    
    func addApplicationSegue() {
        performSegueWithIdentifier("AddAppSegue", sender: self)
    }
    
    func goToSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

}
