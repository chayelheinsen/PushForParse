//
//  App+CoreDataProperties.swift
//  PushForParse
//
//  Created by Chayel Heinsen on 10/16/15.
//  Copyright © 2015 Chayel Heinsen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension App {

    @NSManaged var name: String?
    @NSManaged var apiKey: String?
    @NSManaged var appId: String?
    @NSManaged var created: NSDate?

}
