//
//  ParseAccount.swift
//  
//
//  Created by Chayel Heinsen on 11/1/15.
//
//

import Foundation
import CoreData


class ParseAccount: NSManagedObject {
    
    convenience init(email: String, password: String) {
        let entity = NSEntityDescription.entityForName("ParseAccount", inManagedObjectContext: CoreDataController.sharedManager.managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: CoreDataController.sharedManager.managedObjectContext)
        self.email = email
        self.password = password
    }
    
    private static func accounts() -> Array<ParseAccount> {
        var accounts: Array<ParseAccount> = Array<ParseAccount>()
        let fetchRequest = NSFetchRequest(entityName: "ParseAccount")
        
        do {
            accounts = try CoreDataController.sharedManager.managedObjectContext.executeFetchRequest(fetchRequest) as! [ParseAccount]
        } catch {
            print("Could not retrieve accounts.")
        }
        
        return accounts
    }
    
    static func account() -> ParseAccount? {
        var account: ParseAccount?
        let fetchRequest = NSFetchRequest(entityName: "ParseAccount")
        do {
            let accounts = try CoreDataController.sharedManager.managedObjectContext.executeFetchRequest(fetchRequest) as! [ParseAccount]
            
            if let a = accounts.first {
                account = a
            }
            
        } catch {
            print("Could not retrieve accounts.")
        }
        
        return account
    }
    
    static func deleteAllAccounts() {
        let accounts: Array<ParseAccount> = ParseAccount.accounts()
        
        for account in accounts {
            account.delete()
        }
    }
    
    func save() {
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            print("Could not save account \(email).")
        }
    }
    
    func delete() {
        
        do {
            self.managedObjectContext?.deleteObject(self)
            try self.managedObjectContext?.save()
        } catch {
            print("Could not delete account \(email).")
        }
    }

}
