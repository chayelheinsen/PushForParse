//
//  Parse.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 11/1/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import UIKit
import Alamofire
import Mercury

class Parse: NSObject {
    static func pushWithApp(app: App, channels: Array<String>, alert: String, badge: String, category: String, completion: (success: Bool) -> ()) {
        let headers = [
            "X-Parse-Application-Id": app.appId!,
            "X-Parse-REST-API-Key": app.apiKey!
        ]
        
        let params: [String : AnyObject] = [
            "channels" : channels,
            "data" : [
                "alert" : alert,
                "badge" : badge,
                "category" : category
            ]
            ] as [String : AnyObject]
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.POST, "https://api.parse.com/1/push", headers: headers, parameters: params, encoding: .JSON)
            .responseJSON { response in
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if response.result.isSuccess {
                    // SUCCESS
                    
                    let mercury = Mercury.sharedInstance
                    
                    let notification = MercuryNotification()
                    notification.text = "Sent Push Notification"
                    notification.color = UIColor.emeraldColor()
                    notification.image = Ionicons.imageWithIcon(Ionicon.CheckmarkRound, size: 20, color: UIColor.emeraldColor())
                    
                    mercury.postNotification(notification)
                    
                    completion(success: true)
                } else {
                    // FAILURE
                    print("Some error occured.")
                    
                    let mercury = Mercury.sharedInstance
                    
                    let notification = MercuryNotification()
                    notification.text = "Something went wrong"
                    notification.color = UIColor.pomergranateColor()
                    notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
                    
                    mercury.postNotification(notification)
                    completion(success: false)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    static func apps(account: ParseAccount, completion: (apps: [App]?) -> ()) {
        let headers = [
            "X-Parse-Email": account.email!,
            "X-Parse-Password": account.password!
        ]
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, "https://api.parse.com/1/apps", headers: headers, parameters: nil, encoding: .JSON)
            .responseJSON { response in
                
                if response.result.isSuccess {
                    // SUCCESS
                    // print(response.result.value)   // result of response serialization
                    if let array = response.result.value!["results"] as? [[String : AnyObject]] {
                        App.deleteAllApps()
                        let apps = App.appsFromDictionary(array)
                        completion(apps: apps)
                    } else {
                        let mercury = Mercury.sharedInstance
                        
                        let notification = MercuryNotification()
                        notification.text = "Please check your account."
                        notification.color = UIColor.pomergranateColor()
                        notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
                        
                        mercury.postNotification(notification)
                        
                        completion(apps: nil)
                    }
                } else {
                    // FAILURE
                    print("Some error occured.")
                    let mercury = Mercury.sharedInstance
                    
                    let notification = MercuryNotification()
                    notification.text = "Couldn't download your apps for some reason. Make sure you are connected to internet."
                    notification.color = UIColor.pomergranateColor()
                    notification.image = Ionicons.imageWithIcon(Ionicon.CloseRound, size: 20, color: UIColor.pomergranateColor())
                    
                    mercury.postNotification(notification)
                    
                    completion(apps: nil)
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}
