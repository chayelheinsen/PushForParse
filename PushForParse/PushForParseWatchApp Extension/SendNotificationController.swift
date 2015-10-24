//
//  SendNotificationController.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/18/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class SendNotificationController: WKInterfaceController {

    @IBOutlet var messageText: WKInterfaceLabel!
    var messageString: String?
    var app: App?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let touchedApp = context as? App {
            app = touchedApp
        } else {
            print("We don't have an app here.")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func message() {
        self.presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain, completion: { [weak self] (results) -> Void in
            
            if let results = results {
                
                if let text = results[0] as? String {
                   
                    if let weakSelf = self {
                        weakSelf.messageText.setText(text)
                        weakSelf.messageString = text
                    }
                }
            }
        })
    }
    
    @IBAction func pushNotification() {
        
        guard let messageString = messageString else {
            print("Need a message")
            return
        }
        
        sendNotificationToServerWithMessage(messageString)
    }
    
    func sendNotificationToServerWithMessage(message: String) {
        
        guard let app = app else {
            print("We need an app to make the push notification request")
            return
        }
        
        let headers = [
            "X-Parse-Application-Id": app.appId!,
            "X-Parse-REST-API-Key": app.apiKey!
        ]
        
        let params: [String : AnyObject] = [
            "channels" : [""],
            "data" : [
                "alert" : message,
                "badge" : "Increment"
            ]
            ] as [String : AnyObject]
        
        Alamofire.request(.POST, "https://api.parse.com/1/push", headers: headers, parameters: params, encoding: .JSON)
            .responseJSON { response in
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if response.result.isSuccess {
                    // SUCCESS
                    self.popController()
                } else {
                    // FAILURE
                    print("Some error occured.")
                }
        }
        
    }

    
}
