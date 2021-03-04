//
//  Scheduler.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/11.
//

import Foundation
import CoreData

extension Scheduler: Comparable {
    private static let defaultScheduler = "default"
    public static func < (lhs: Scheduler, rhs: Scheduler) -> Bool {
        lhs.date < rhs.date
    }

    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Scheduler> {
        let request = NSFetchRequest<Scheduler>(entityName: "Scheduler")
        request.sortDescriptors = [NSSortDescriptor(key: "date_", ascending: true)]
        request.predicate = predicate
        return request
    }

    static func fetchDefaultScheduler(context: NSManagedObjectContext) -> Scheduler {
        let request = NSFetchRequest<Scheduler>(entityName: "Scheduler")
        request.sortDescriptors = [NSSortDescriptor(key: "date_", ascending: true)]
        request.predicate =  NSPredicate(format: "name = %@", defaultScheduler)
        let schedulers = (try? context.fetch(request)) ?? []
        if let scheduler = schedulers.first {
            return scheduler
        } else {
            let scheduler = Scheduler(context: context)
            scheduler.name = defaultScheduler
            var dateComponents = DateComponents()
            dateComponents.year = 1900
            dateComponents.month = 1
            dateComponents.day = 1
            scheduler.date = Calendar.current.date(from: dateComponents)!
            context.saveWithTry()
            return scheduler
        }
    }

    static func fetchScheduler(at date: Date, context: NSManagedObjectContext) -> Scheduler {
        let request = fetchRequest(predicateDate(at: date))
        let schedulers = (try? context.fetch(request)) ?? []
        if let scheduler = schedulers.first {
            return scheduler
        } else {
            let scheduler = Scheduler(context: context)
            scheduler.date = date
            scheduler.name = "untitled"
            context.saveWithTry()
            return scheduler
        }
    }

    func copyDefaultScheduler(context: NSManagedObjectContext) {
        let defaultScheduler = Scheduler.fetchDefaultScheduler(context: context)
        self.reset(context: context)
        for task in defaultScheduler.todoTasks {
            let newTask = TodoTask(context: context)
            newTask.color_ = task.color_
            newTask.endTime_ = task.endTime_
            newTask.memo_ = task.memo_
            newTask.name_ = task.name_
            newTask.startTime_ = task.startTime_
            newTask.notification = task.notification
            self.addToTodoTasks_(newTask)
        }
        context.saveWithTry()
    }

    var todoTasks: Set<TodoTask> {
        get { todoTasks_ as? Set<TodoTask> ?? [] }
        set {
            todoTasks_ = newValue as NSSet}
    }

    var date: Date {
        get {DateFormatter.dateOnlyFormatter.date(from: date_!)!}
        set { date_ = DateFormatter.dateOnlyFormatter.string(from: newValue)}
    }

    static func predicateDate(at date: Date) -> NSPredicate {
        let stringDate = DateFormatter.dateOnlyFormatter.string(from: date)
        return NSPredicate(format: "date_ = %@", stringDate)
    }

    // get tasks in schduler that are overlapping task
    func tasksInScheduler (task: TodoTask) -> [TodoTask] {
        var tasks: [TodoTask] = []
        for interval in task.startTime.divideTimeBasedOnMidnight(end: task.endTime) {
            tasks.append(contentsOf: todoTasks.filter {
                for suspect in $0.startTime.divideTimeBasedOnMidnight(end: $0.endTime) {
                    if interval.overlaps(suspect) && task.objectID != $0.objectID {
                        return true
                    }
                }
                return false
            })
        }
        return tasks
    }

    func currentTask() -> TodoTask? {
        let current = DateFormatter.timeFormatter.date(from: Date.stringOfCurrentTime)!
        let currentRange = current..<current.addingTimeInterval(1)
        return todoTasks.filter {
            for suspect in $0.startTime.divideTimeBasedOnMidnight(end: $0.endTime) {
                if currentRange.overlaps(suspect) {
                    return true
                }
            }
            return false
        }.first ?? nil
    }

    func reset(context: NSManagedObjectContext) {
        for task in todoTasks {
            context.delete(task)
        }
        todoTasks.removeAll()
        context.saveWithTry()
    }

    func forceInsert(task: TodoTask, context: NSManagedObjectContext) {
        for overlappedTask in tasksInScheduler(task: task) {
            todoTasks.remove(overlappedTask)
        }
        todoTasks.update(with: task)
        context.saveWithTry()
    }

    static let taskNameLimit = 15
    static let memolimit = 50

    func checkValidation(task: TodoTask) -> EditorAlertType {
        if task.name == "" {
            return .nilValueInTask
        }
        if task.name.count > Scheduler.taskNameLimit {
            return .tooLongText
        }
        if task.memo.count > Scheduler.memolimit {
            return .tooLongMemo
        }

        if task.startTime == task.endTime {
            return .same
        }
        if !tasksInScheduler(task: task).isEmpty {
            return .overlapped
        }
        return .none
    }
}
