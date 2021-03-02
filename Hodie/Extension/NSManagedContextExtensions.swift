//
//  NSManagedContextExtensions.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func saveWithTry() {
        do {
            try self.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
