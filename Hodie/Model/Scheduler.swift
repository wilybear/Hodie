//
//  Scheduler.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/11.
//

import Foundation
import CoreData

extension Scheduler : Comparable{
    public static func < (lhs: Scheduler, rhs: Scheduler) -> Bool {
        lhs.date < rhs.date
    }

    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Scheduler> {
        let request = NSFetchRequest<Scheduler>(entityName: "Scheduler")
        request.sortDescriptors = [NSSortDescriptor(key:"date_", ascending: true)]
        request.predicate = predicate
        return request
    }

    var todoTasks: Set<TodoTask>{
        get{ todoTasks_ as? Set<TodoTask> ?? [] }
        set{ todoTasks_ = newValue as NSSet}
    }
    
    var date: Date {
        
        get{DateFormatter.dateOnlyFormatter.date(from: date_!)!}
        set{ date_ = DateFormatter.dateOnlyFormatter.string(from: newValue)}
    }
    
    static func predicateDate(at date: Date) -> NSPredicate {
        let stringDate = DateFormatter.dateOnlyFormatter.string(from: date)
        return NSPredicate(format: "date_ = %@", stringDate)
    }
}
