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
        var tasks:[TodoTask] = []
        for interval in divideTimeBasedOnMidnight(start: task.startTime, end: task.endTime) {
            tasks.append(contentsOf: todoTasks.filter{
                var result = task.objectID != $0.objectID
                for suspect in divideTimeBasedOnMidnight(start: $0.startTime, end: $0.endTime){
                    result = interval.overlaps(suspect) && result
                }
                return result
            })
        }
        return tasks
    }
    
    func divideTimeBasedOnMidnight(start: Date, end: Date) -> [Range<Date>]{
        if start < end{
            return [(start.addingTimeInterval(60))..<end]
        }
        let midnightPM = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: start,direction: .backward)!
        let midnightAM = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: start,direction: .backward)!
        return [(start.addingTimeInterval(60))..<midnightPM,(midnightAM+1)..<(end)]
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
