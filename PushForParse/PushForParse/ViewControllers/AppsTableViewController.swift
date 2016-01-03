//
//  AppsTableViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/16/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import WatchConnectivity
import DGElasticPullToRefresh
import TransitionTreasury

class AppsTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, ModalViewControllerDelegate {

    // MARK: - ModalViewControllerDelegate
    var tr_transition: TRViewControllerTransitionDelegate?
    
    var apps: [App] = [App]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addApplicationSegue")
        
        let edit: UIBarButtonItem = UIBarButtonItem(image: Ionicons.imageWithIcon(Ionicon.Ios7CogOutline, size: 26, color: UIColor.whiteColor()), style: .Plain, target: self, action: "goToSettings")
        
        navigationItem.rightBarButtonItem = add
        navigationItem.leftBarButtonItem = edit
        
        navigationItem.title = "Apps"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addApplicationSegue", name: "segueNewApp", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: "RefreshApps", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetApp", name: "AppReset", object: nil)
        
        if UIApplication.sharedApplication().keyWindow?.traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
        
        removeNavigationBarHairline(self.navigationController!.navigationBar)
        self.navigationController?.navigationBar.translucent = false
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.refreshAccount({ () -> () in
                self?.tableView.dg_stopLoading()
            })
        }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor.turquoiseColor())
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        let footer: UIView = UIView()
        tableView.tableFooterView = footer
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
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
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if apps.count > 0 {
            let sendNotification = SendNotificationTableViewController(style: .Grouped)
            sendNotification.app = apps[tableView.indexPathForSelectedRow!.row]
            self.navigationController?.pushViewController(sendNotification, animated: true)
        }
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if apps.count > 0 {
            let indexPath = tableView.indexPathForRowAtPoint(location)
            
            if let indexPath = indexPath {
                let app = apps[indexPath.row]
                let appInfo = storyboard!.instantiateViewControllerWithIdentifier("AddAppTableViewController") as! AddAppTableViewController
                appInfo.app = app
                appInfo.preferredContentSize = CGSize(width: 0.0, height: 300)
                
                return appInfo
            }
        }
        
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    // MARK: - Helpers
    
    func addApplicationSegue() {
        performSegueWithIdentifier("AddAppSegue", sender: self)
    }
    
    func goToSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    func refreshData() {
        apps = App.allApps()
        tableView.reloadData()
    }
    
    func refreshAccount(completion: () -> ()) {
        
        if let account = ParseAccount.account() {
            Parse.apps(account) { (apps) -> () in
                
                if let apps = apps {
                    
                    if WCSession.defaultSession().watchAppInstalled {
                        var array = [[String : AnyObject]]()
                        
                        for app in apps {
                            let data: [String : AnyObject] = app.serializeToDictionary()
                            let appData: [String : AnyObject] = ["app" : data]
                            array.append(appData)
                        }
                        
                        do {
                            try WCSession.defaultSession().updateApplicationContext(["context" : array])
                        } catch {
                            
                        }
                    }
                }
                
                completion()
            }
        } else {
            completion()
        }
    }
    
    func resetApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        tr_presentViewController(vc, method: .Twitter)
    }
}
