//
//  App.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/16/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//

import Foundation
import CoreData

class App: NSManagedObject {

    convenience init(name: String, apiKey: String, appId: String) {
        let entity = NSEntityDescription.entityForName("App", inManagedObjectContext: CoreDataController.sharedManager.managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: CoreDataController.sharedManager.managedObjectContext)
        self.name = name
        self.apiKey = apiKey
        self.appId = appId
        self.created = NSDate()
    }
    
    static func allApps() -> Array<App> {
        var apps: Array<App> = Array<App>()
        let fetchRequest = NSFetchRequest(entityName: "App")
        
        do {
            apps = try CoreDataController.sharedManager.managedObjectContext.executeFetchRequest(fetchRequest) as! [App]
        } catch {
            print("Could not retrieve apps.")
        }
        
        return apps
    }
    
    static func appWithName(name: String) -> App? {
        var app: App?
        let fetchRequest = NSFetchRequest(entityName: "App")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let apps = try CoreDataController.sharedManager.managedObjectContext.executeFetchRequest(fetchRequest) as! [App]
            
            if let a = apps.first {
                app = a
            }
            
        } catch {
            print("Could not retrieve apps.")
        }
        
        return app
    }
    
    static func deleteAllApps() {
        let apps: Array<App> = App.allApps()
        
        for app in apps {
            app.delete()
        }
    }
    
    static func appsFromDictionary(apps: [[String : AnyObject]]) -> [App] {
        var array: [App] = [App]()
        
        for a in apps {
            let app: App = App(name: a["appName"]! as! String, apiKey: a["restKey"]! as! String, appId: a["applicationId"]! as! String)
            app.save()
            array.append(app)
        }
        
        return array
    }
    
    func save() {
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            print("Could not save app \(name).")
        }
    }
    
    func delete() {
        
        do {
            self.managedObjectContext?.deleteObject(self)
            try self.managedObjectContext?.save()
        } catch {
            print("Could not delete app \(name).")
        }
    }
    
    func serializeToDictionary() -> [String : AnyObject] {
        return [
            "appId" : appId!,
            "apiKey" : apiKey!,
            "name" : name!,
            "created" : created!
        ]
    }
}
