//
//  AddAppTableViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/17/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import WatchConnectivity
import Mercury
import SafariServices

class AddAppTableViewController: UITableViewController, UITextFieldDelegate, SFSafariViewControllerDelegate {

    @IBOutlet var applicationTitle: UITextField!
    @IBOutlet var apiKey: UITextField!
    @IBOutlet var appID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let cancel: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAddition")
        let save: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveApplicationInformation")
        
        //self.navigationItem.leftBarButtonItem = cancel;
        self.navigationItem.rightBarButtonItem = save;
        
        self.tableView.separatorStyle = .SingleLine;
        
        self.title = "New App";
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        applicationTitle.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UITableViewDelegate
    @available(iOS, deprecated=9.0) // To silence warning
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 3 {
            let svc = SFSafariViewController(URL: NSURL(string: "https://www.parse.com/apps")!)
            svc.view.tintColor = UIColor.emeraldColor()
            svc.delegate = self
            self.presentViewController(svc, animated: true, completion: nil)
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        if textField == applicationTitle {
            self.title = "New App"
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == applicationTitle {
            apiKey.becomeFirstResponder()
        } else if textField == apiKey {
            appID.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
            saveApplicationInformation()
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == applicationTitle {
            self.title = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        }
        
        return true
    }
    
    // MARK: - SFSafariViewControllerDelegate
    @available(iOS, deprecated=9.0) // To silence warning
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    // MARK: - Helpers
    
    func saveApplicationInformation() {
        
        guard applicationTitle.text?.characters.count > 0 && apiKey.text?.characters.count > 0 && appID.text?.characters.count > 0 else {
            
            let mercury = Mercury.sharedInstance
            
            let notification = MercuryNotification()
            notification.text = "Whoops! Something is missing"
            notification.color = UIColor.pomergranateColor()
            notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
            
            mercury.postNotification(notification)
            
            return
        }
        
        let checkApp = App.appWithName(applicationTitle.text!)
        
        if checkApp != nil {
            print("App already exists")
            
            let mercury = Mercury.sharedInstance
            
            let notification = MercuryNotification()
            notification.text = "App name already exists"
            notification.color = UIColor.pomergranateColor()
            notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
            
            mercury.postNotification(notification)
            
            return
        }
        
        let app: App = App(name: applicationTitle.text!, apiKey: apiKey.text!, appId: appID.text!)
        app.save()
        
        if WCSession.defaultSession().watchAppInstalled {
            let data: [String : AnyObject] = app.serializeToDictionary()
            let appData: [String : AnyObject] = ["app" : data]
            
            WCSession.defaultSession().transferUserInfo(appData)
            /*
            do {
                try WCSession.defaultSession().updateApplicationContext(appData)
            } catch {
                print("Cannot send data to watch: \(error)")
            }
            */
        }
        
        self.navigationController!.popViewControllerAnimated(true)
    }
}
