//
//  ParseAccount+CoreDataProperties.swift
//  
//
//  Created by Chayel Heinsen on 11/1/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ParseAccount {

    @NSManaged var password: String?
    @NSManaged var email: String?

}
