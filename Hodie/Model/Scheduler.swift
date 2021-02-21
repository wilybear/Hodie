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
    
    func tasksInScheduler (task: TodoTask) -> [TodoTask] {
        todoTasks.filter{ (task.startTime...task.endTime).overlaps($0.startTime...$0.endTime ) && task.objectID != $0.objectID}
    }
    
    func forceInsert(task: TodoTask, context: NSManagedObjectContext){
        for overlappedTask in tasksInScheduler(task: task){
            todoTasks.remove(overlappedTask)
        }
        todoTasks.update(with: task)
        context.saveWithTry()
    }
    
    static let taskNameLimit = 15
    static let memolimit = 50
    
    func checkValidation(task: TodoTask) -> EditorAlertType{
        if task.name == "" {
            return .nilValueInTask
        }
        if task.name.count > Scheduler.taskNameLimit {
            return .tooLongText
        }
        if task.memo.count > Scheduler.memolimit {
            return .tooLongMemo
        }
        if !tasksInScheduler(task: task).isEmpty{
            return .overlapped
        }
        return .none
    }
    

}
