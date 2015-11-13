//
//  ParseLoginTableViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 11/1/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import Mercury

class ParseLoginTableViewController: UITableViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let account = ParseAccount.account() {
            email.text = account.email!
            password.text = account.password!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            email.becomeFirstResponder()
        case 1:
            password.becomeFirstResponder()
        case 2:
            loginToParse()
        default:
            break
        }
    }
    
    func loginToParse() {
        ParseAccount.deleteAllAccounts()
        
        let account: ParseAccount = ParseAccount(email: email.text!, password: password.text!)
        account.save()
        
        Parse.apps(account) { (apps) -> () in
            
            if let apps = apps {
                
                if apps.count > 0 {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    let mercury = Mercury.sharedInstance
                    
                    let notification = MercuryNotification()
                    notification.text = "Didn't find any apps for that account. This could be caused by having the wrong email or password."
                    notification.color = UIColor.pomergranateColor()
                    notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
                    
                    mercury.postNotification(notification)
                }
            } else {
                let mercury = Mercury.sharedInstance
                
                let notification = MercuryNotification()
                notification.text = "Didn't find any apps for that account. This could be caused by having the wrong email or password."
                notification.color = UIColor.pomergranateColor()
                notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
                
                mercury.postNotification(notification)
            }
        }
    }
}
