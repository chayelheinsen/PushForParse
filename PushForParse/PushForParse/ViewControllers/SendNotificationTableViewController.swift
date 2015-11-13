//
//  SendNotificationTableViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/17/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import Alamofire
import Mercury

class SendNotificationTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    private(set) var alertText: String = ""
    private(set) var categoryText: String = ""
    private(set) var badgeText: String = ""
    private(set) var channelText: String = ""
    
    private(set) var alertComposer: UITextView = UITextView()
    private(set) var channelSwitchView: UISwitch = UISwitch()
    private(set) var badgeSwitchView: UISwitch = UISwitch()
    private(set) var categorySwitchView: UISwitch = UISwitch()
    private(set) var channelTextField: UITextField = UITextField()
    private(set) var badgeTextField: UITextField = UITextField()
    private(set) var categoryTextField: UITextField = UITextField()
    private(set) var channelSwitch: Bool = false
    private(set) var badgeSwitch: Bool = true
    private(set) var categorySwitch: Bool = false
    
    var app: App?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let send: UIBarButtonItem = UIBarButtonItem(image: Ionicons.imageWithIcon(Ionicon.Ios7CloudUploadOutline, size: 26, color: UIColor.whiteColor()), style: .Plain, target: self, action: "sendNotification")
        self.navigationItem.rightBarButtonItem = send;
        
        self.title = "Send Notificiation"
        
        self.tableView.separatorStyle = .SingleLine
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(dismissKeyboard)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                
                if channelSwitch {
                    return 2
                } else {
                    return 1
                }
            case 2:
                
                if !badgeSwitch {
                    return 2
                } else {
                    return 1
                }
            case 3:
                
                if categorySwitch {
                    return 2
                } else {
                    return 1
                }
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return "COMPOSE ALERT                                      "
            case 1:
                return "Manage Channels"
            case 2:
                return "Badge Numbers"
            case 3:
                return "Category"
            default:
                return ""
        }
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
            case 0:
                return ""
            case 1:
                
                if channelSwitch {
                    return "To enter mulitple channels, spererate each channel with a comma."
                } else {
                    return "If you don't use custom channels, you must subscribe to channel \"\" on all devices."
                }
            case 2:
                
                if badgeSwitch {
                    return "Badges are incremented by default. Turn off to enter a custom badge number."
                } else {
                    return "Enter your desired badge number above."
                }
            default:
                return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      
        if indexPath.section == 0 && indexPath.row == 0 {
            return 140
        }
        
        return 46
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.tintColor = UIColor.peterRiverColor()
        cell.selectionStyle = .None;
        
        switch indexPath.section {
        case 0:
           
            if indexPath.row == 0 {
                alertComposer = UITextView(frame: CGRectMake(0, 0, view.frame.width - 20, 140))
                alertComposer.delegate = self
                alertComposer.backgroundColor = UIColor.clearColor()
                alertComposer.editable = true
                alertComposer.scrollEnabled = false;
                alertComposer.autocorrectionType = .No;
                alertComposer.keyboardAppearance = .Dark;
                alertComposer.text = alertText;
                alertComposer.tintColor = UIColor.peterRiverColor()
                
                if self.channelSwitch {
                    alertComposer.returnKeyType = .Next
                } else {
                    alertComposer.returnKeyType = .Done
                }
                
                alertComposer.font = UIFont.systemFontOfSize(15)
                
                cell.accessoryView = alertComposer;
            }
        case 1:
            switch indexPath.row {
            case 0:
                channelSwitchView = UISwitch(frame: CGRectZero)
                
                channelSwitchView.onTintColor = UIColor.peterRiverColor()
                
                cell.accessoryView = channelSwitchView;
                
                if (self.channelSwitch) {
                    channelSwitchView.setOn(true, animated: false)
                } else {
                   channelSwitchView.setOn(false, animated: false);
                }
                
                channelSwitchView.addTarget(self, action: "channelSwitchChanged:", forControlEvents: .ValueChanged)
                
                cell.textLabel?.text = "Custom Channels"
                cell.selectionStyle = .None;
            case 1:
                channelTextField = UITextField(frame: CGRectMake(15, 12, cell.bounds.size.width, 21))
                channelTextField.addTarget(self, action: "channelTextChanged", forControlEvents: .EditingChanged)
                channelTextField.delegate = self;
                channelTextField.text = channelText
                channelTextField.placeholder = "Channel1, Channel2"
                channelTextField.font = UIFont.boldSystemFontOfSize(17)
                channelTextField.returnKeyType = .Done;
                channelTextField.autocorrectionType = .No;
                channelTextField.clearButtonMode = .WhileEditing
                channelTextField.keyboardAppearance = .Dark
                channelTextField.tintColor = UIColor.peterRiverColor()
                
                cell.addSubview(channelTextField)
            default:
                break;
            }
        case 2:
            switch indexPath.row {
            case 0:
                badgeSwitchView = UISwitch(frame: CGRectZero)
                badgeSwitchView.onTintColor = UIColor.peterRiverColor()
                
                cell.accessoryView = badgeSwitchView
                
                if badgeSwitch {
                    badgeSwitchView.setOn(true, animated: false)
                } else {
                    badgeSwitchView.setOn(false, animated: false)
                }
                
                badgeSwitchView.addTarget(self, action:"badgeSwitchChanged:", forControlEvents:.ValueChanged)
                
                cell.textLabel?.text = "Increment Badge"
                cell.selectionStyle = .None
            case 1:
                cell.textLabel?.text = ""
                
                badgeTextField = UITextField(frame: CGRectMake(15, 12, cell.bounds.size.width, 21))
                badgeTextField.addTarget(self, action: "badgeTextChanged", forControlEvents: .EditingChanged)
                badgeTextField.delegate = self
                badgeTextField.text = badgeText
                badgeTextField.placeholder = "Number to show for the badge i.e: 2"
                badgeTextField.font = UIFont.boldSystemFontOfSize(17)
                badgeTextField.returnKeyType = .Done;
                badgeTextField.keyboardType = .NumberPad;
                badgeTextField.autocorrectionType = .No;
                badgeTextField.clearButtonMode = .WhileEditing
                badgeTextField.keyboardAppearance = .Dark;
                badgeTextField.tintColor = UIColor.peterRiverColor()
                
                cell.addSubview(badgeTextField)
            default:
                break;
            }
        case 3:
            switch indexPath.row {
            case 0:
                categorySwitchView = UISwitch(frame: CGRectZero)
                categorySwitchView.onTintColor = UIColor.peterRiverColor()
                
                cell.accessoryView = categorySwitchView
                
                if categorySwitch {
                    categorySwitchView.setOn(true, animated: false)
                } else {
                    categorySwitchView.setOn(false, animated: false)
                }
                
                categorySwitchView.addTarget(self, action:"categorySwitchChanged:", forControlEvents:.ValueChanged)
                
                cell.textLabel?.text = "Category"
                cell.selectionStyle = .None
            case 1:
                cell.textLabel?.text = ""
                
                categoryTextField = UITextField(frame: CGRectMake(15, 12, cell.bounds.size.width, 21))
                categoryTextField.addTarget(self, action: "categoryTextChanged", forControlEvents: .EditingChanged)
                categoryTextField.delegate = self
                categoryTextField.text = categoryText
                categoryTextField.placeholder = "Category Name"
                categoryTextField.font = UIFont.boldSystemFontOfSize(17)
                categoryTextField.returnKeyType = .Done;
                categoryTextField.autocorrectionType = .No;
                categoryTextField.clearButtonMode = .WhileEditing
                categoryTextField.keyboardAppearance = .Dark;
                categoryTextField.tintColor = UIColor.peterRiverColor()
                
                cell.addSubview(categoryTextField)
            default:
                break;
            }
        default:
            break;
        }

        return cell
    }

    // MARK: - UITextFieldDelgate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == channelTextField {
            self.view.endEditing(true)
        }
        
        return false
    }
    
    func channelTextChanged() {
        
        if let text = channelTextField.text {
            channelText = text
        }
    }
    
    func badgeTextChanged() {
        
        if let text = badgeTextField.text {
            badgeText = text
        }
    }
    
    func categoryTextChanged() {
        
        if let text = categoryTextField.text {
            categoryText = text
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        
        if textView == alertComposer {
            alertText = alertComposer.text
            
            if alertText.characters.count == 1 {
                tableView.headerViewForSection(0)?.textLabel?.text = "COMPOSE ALERT - \(alertText.characters.count) CHARACTER"
            } else if alertText.characters.count == 0 {
                tableView.headerViewForSection(0)?.textLabel?.text = "COMPOSE ALERT"
            } else  {
                tableView.headerViewForSection(0)?.textLabel?.text = "COMPOSE ALERT - \(alertText.characters.count) CHARACTERS"
            }
            
            tableView.headerViewForSection(0)?.textLabel?.font = UIFont.systemFontOfSize(14)
            
            if (textView.text.characters.count > 180) {
                alertText = alertComposer.text;
                
                tableView.headerViewForSection(0)?.textLabel?.text = "COMPOSE ALERT - \(alertText.characters.count) CHARACTER"
                tableView.headerViewForSection(0)?.textLabel?.font = UIFont.boldSystemFontOfSize(14)
            } else {
                tableView.headerViewForSection(0)?.textLabel?.textColor = UIColor.grayColor()
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        alertText = alertComposer.text
        
        if textView == alertComposer {
            
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Helpers
    
    func channelSwitchChanged(sender: AnyObject) {
        
        guard let channelSwitchView = sender as? UISwitch else {
            print("Not a UISwitch")
            return
        }
        
        if channelSwitchView.on {
            channelSwitch = true
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            channelTextField.becomeFirstResponder()
        } else {
            channelSwitch = false
            channelTextField.text = ""
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
            self.view.endEditing(true)
        }
        
    }
    
    func badgeSwitchChanged(sender: AnyObject) {
        
        guard let badgeSwitchView = sender as? UISwitch else {
            print("Not a UISwitch")
            return
        }
        
        if !badgeSwitchView.on {
            badgeSwitch = false
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
            badgeTextField.becomeFirstResponder()
        } else {
            badgeSwitch = true
            badgeTextField.text = ""
            tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
            self.view.endEditing(true)
        }
    }
    
    func categorySwitchChanged(sender: AnyObject) {
        
        guard let categorySwitchView = sender as? UISwitch else {
            print("Not a UISwitch")
            return
        }
        
        if categorySwitchView.on {
            categorySwitch = true
            tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
            categoryTextField.becomeFirstResponder()
        } else {
            categorySwitch = false
            categoryTextField.text = ""
            tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
            self.view.endEditing(true)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func sendNotificationToServerWithMessage(message: String, badge: String, var channels: String) {
        
        guard let app = app else {
            print("We need an app to make the push notification request")
            return
        }
        
        channels = channels.stringByReplacingOccurrencesOfString(" ", withString: "")
        let channelsArray: [String] = channels.componentsSeparatedByString(",")
        
        var category = ""
        
        if categorySwitch {
            category = categoryText
        }
        
        Parse.pushWithApp(app, channels: channelsArray, alert: message, badge: badge, category: category) { (success) -> () in
            
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    func sendNotification() {
        
        alertText = alertText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        guard alertText.characters.count > 0 else {
            print("Message must contain characters to send a notifiaction.")
            
            let mercury = Mercury.sharedInstance
            
            let notification = MercuryNotification()
            notification.text = "Message must contain characters to send a notifiaction"
            notification.color = UIColor.pomergranateColor()
            notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
            
            mercury.postNotification(notification)
            
            return
        }
        
        if channelSwitch && badgeSwitch {
            guard channelTextField.text?.characters.count > 0 else {
                print("Channels must contain characters to send a notifiaction.")
                channelTextField.becomeFirstResponder()
                return
            }
            
            self.view.endEditing(true)
            
            sendNotificationToServerWithMessage(alertText, badge: "Increment", channels: channelTextField.text!)
        } else if channelSwitch && !badgeSwitch {
            
            if channelTextField.text?.characters.count == 0 && badgeTextField.text?.characters.count != 0 {
                //[SVProgressHUD showErrorWithStatus:"Channels!"];
                channelTextField.becomeFirstResponder()
            } else if channelTextField.text?.characters.count != 0 && badgeTextField.text?.characters.count == 0 {
                //[SVProgressHUD showErrorWithStatus:@"Badges!"];
                badgeTextField.becomeFirstResponder()
            } else if channelTextField.text?.characters.count == 0 && badgeTextField.text?.characters.count == 0 {
                //[SVProgressHUD showErrorWithStatus:@"Complete Fields!"];
                channelTextField.becomeFirstResponder()
            } else if channelTextField.text?.characters.count != 0 && self.badgeTextField.text?.characters.count != 0 {
                self.view.endEditing(true)
                //[SVProgressHUD showWithStatus:@"Pushing..."];
                sendNotificationToServerWithMessage(alertText, badge: badgeTextField.text!, channels: channelTextField.text!)
            }
        } else if !channelSwitch && badgeSwitch {
            self.view.endEditing(true)
            //[SVProgressHUD showWithStatus:@"Pushing..."];
            sendNotificationToServerWithMessage(alertText, badge: "Increment", channels: " ")
        } else if !channelSwitch && !badgeSwitch {
            
            if badgeTextField.text?.characters.count == 0 {
                //[SVProgressHUD showErrorWithStatus:@"Badges!"];
                badgeTextField.becomeFirstResponder()
            } else if badgeTextField.text?.characters.count != 0 {
                self.view.endEditing(true)
                //[SVProgressHUD showWithStatus:@"Pushing..."];
                sendNotificationToServerWithMessage(alertText, badge: badgeTextField.text!, channels: " ")
            }
        }
        
    }
}
