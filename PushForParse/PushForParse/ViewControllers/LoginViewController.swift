//
//  LoginViewController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 1/2/16.
//  Copyright © 2016 Chayel Heinsen. All rights reserved.
//

import UIKit
import QuartzCore
import Mercury
import TransitionTreasury

class LoginViewController: UIViewController, UITextFieldDelegate, ModalViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet var mainTitle: UILabel!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var login: UIButton!
    @IBOutlet var signUpText: UILabel!
    @IBOutlet var signUp: UIButton!
    
    // MARK: - ModalViewControllerDelegate
    var tr_transition: TRViewControllerTransitionDelegate?
    
    // MARK: - Overides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateIn()
        
        // Notifiying for Changes in the textFields
        usernameField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        passwordField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        let backgroundTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "backgroundTapped")
        self.view.addGestureRecognizer(backgroundTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            login(login)
        }
        
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func login(sender: UIButton) {
        backgroundTapped()
        login.enabled = false
        ParseAccount.deleteAllAccounts()
        
        func displayError() {
            self.login.enabled = true
            
            let mercury = Mercury.sharedInstance
            
            let notification = MercuryNotification()
            notification.text = "Didn't find any apps for that account. This could be caused by having the wrong email or password."
            notification.color = UIColor.pomergranateColor()
            notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
            
            mercury.postNotification(notification)
            
            ParseAccount.deleteAllAccounts()
        }
        
        let account: ParseAccount = ParseAccount(email: usernameField.text!, password: passwordField.text!)
        account.save()
        
        Parse.apps(account) { (apps) -> () in
            
            if let apps = apps {
                
                if apps.count > 0 {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("AppNavigationController") as! UINavigationController
                    
                    self.tr_presentViewController(vc, method: .Twitter)
                } else {
                    displayError()
                }
            } else {
                displayError()
            }
        }
    }
    
    @IBAction func signUp(sender: UIButton) {
        backgroundTapped()
    }
    
    // MARK: - Helpers
    
    func backgroundTapped() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    private func animateIn() {
        // Hide all the subviews.
        mainTitle.alpha = 0
        subTitle.alpha = 0
        usernameField.alpha = 0
        passwordField.alpha = 0
        login.alpha = 0
        signUpText.alpha = 0
        signUp.alpha = 0
        
        // Animate everything back in
        
        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.mainTitle.alpha = 1
            self.subTitle.alpha = 1
            self.usernameField.alpha = 1
            self.passwordField.alpha = 1
            self.login.alpha = 1
            self.signUpText.alpha = 1
            self.signUp.alpha = 1
            }, completion: nil)
    }
    
    func textFieldDidChange() {
        guard let email = usernameField.text else {
            login.enabled = false
            return
        }
        
        guard let password = passwordField.text else {
            login.enabled = false
            return
        }
        
        if email.isEmpty || password.isEmpty {
            login.enabled = false
        } else {
            login.enabled = true
        }
    }
    
}
