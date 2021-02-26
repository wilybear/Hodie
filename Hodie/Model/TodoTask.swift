//
//  Task.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/11.
//

import Foundation
import SwiftUI
import CoreData

extension TodoTask: Comparable{

    // initialize default value
    public override func awakeFromInsert() {
        startTime_ = DateFormatter.timeFormatter.string(from: Date())
        endTime_ = DateFormatter.timeFormatter.string(from: Date().addingTimeInterval(3600))
        color_ = SerializableColor.init(from: Color.brightRed)
        print("awake from insert is called")
    }
    
    public static func < (lhs: TodoTask, rhs: TodoTask) -> Bool {
        lhs.startTime < rhs.startTime
    }
    
    var color: SerializableColor {
        get{ color_ ?? SerializableColor(from:Color.brightRed) }
        set{ color_ = newValue}
    }
    
    // Date to time string, time string to Date
    var startTime: Date{
        get{DateFormatter.timeFormatter.date(from: startTime_ ?? Date.stringOfCurrentTime)!}
        set{
            startTime_ = DateFormatter.timeFormatter.string(from: newValue)}
    }
    var endTime: Date{
        get{ DateFormatter.timeFormatter.date(from: endTime_ ?? Date.stringOfCurrentTime)!}
        set{
            endTime_ = DateFormatter.timeFormatter.string(from: newValue)
        }
    }
    
    var name:String{
        get{ name_ ?? "" }
        set{ name_ = newValue }
    }
    
    var memo:String{
        get{ memo_ ?? "" }
        set{ memo_ = newValue}
    }
    
    static func fetchRequest(scheduler: Scheduler, time: Date) -> NSFetchRequest<TodoTask> {
        let request = NSFetchRequest<TodoTask>(entityName: "TodoTask")
        request.sortDescriptors = [NSSortDescriptor(key:"startTime_", ascending: true)]
        request.predicate = predicateWithDate(of: scheduler, at: time)
        return request
    }
    
    // wrong
    private static func predicateWithDate(of scheduler: Scheduler, at time: Date) -> NSPredicate {
        let format = "scheduler = %@ "
        //let currentTime = DateFormatter.timeFormatter.string(from: time)
        let args: [Any] = [scheduler]
        return NSPredicate(format: format, argumentArray: args)
    }
    
    // true for start, false for end
    func timeNearStartOrEnd(radian: Double, size: CGSize) -> Bool {
        let radius = min(size.width, size.height) / 2
        let center = CGPoint(x:size.width/2, y: size.height/2)
        let startPoint = CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
           y: center.y + radius * sin(CGFloat(startAngle.radians)))
        let endPoint = CGPoint(
           x: center.x + radius * cos(CGFloat(endAngle.radians)),
           y: center.y + radius * sin(CGFloat(endAngle.radians)))
        let currentPoint = CGPoint(
           x: center.x + radius * cos(CGFloat(radian)),
           y: center.y + radius * sin(CGFloat(radian)))
        let toStart = CGPointDistance(from: currentPoint, to: startPoint)
        let toEnd = CGPointDistance(from: currentPoint, to: endPoint)
        return toStart < toEnd
    }
    
    func availableRadians() -> (ClosedRange<Double>, ClosedRange<Double>){
        let index = scheduler!.todoTasks.sorted().firstIndex(of: self)!
        let nextIndex = index == scheduler!.todoTasks.count - 1 ? 0 : index + 1
        let beforeIndex = index == 0 ? scheduler!.todoTasks.count - 1 : index - 1
        var nextStartRadians = scheduler!.todoTasks.sorted()[nextIndex].startTime.asRadians
        let beforeEndRadians = scheduler!.todoTasks.sorted()[beforeIndex].endTime.asRadians
        
        var endTimeRadians = self.endTime.addingTimeInterval(-10 * 60).asRadians
        let startTimeRadians = self.startTime.addingTimeInterval(-10 * 60).asRadians
        
        let startPivot = beforeEndRadians > startTime.asRadians ? startTime.asRadians + .radianRound : startTime.asRadians
        if startTime.asRadians > endTimeRadians{
            endTimeRadians += .radianRound
        }
        
        let endPivot = startTimeRadians > endTime.asRadians ? endTime.asRadians + .radianRound : endTime.asRadians
        
        if endTime.asRadians > nextStartRadians{
            nextStartRadians += .radianRound
        }
        
        return ((beforeEndRadians - startPivot)...(endTimeRadians - startTime.asRadians), (startTimeRadians - endPivot)...(nextStartRadians - endTime.asRadians))
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    func dragTimeValue(value: Double, isStart: Bool, context: NSManagedObjectContext){
        let amount = value.asMinuteAmount
        let availableRange = self.availableRadians()
        if isStart{
            if availableRange.0.contains(value){
                startTime = startTime.addingTimeInterval(TimeInterval(amount * -60))
            }
        }else{
            if availableRange.1.contains(value){
                endTime = endTime.addingTimeInterval(TimeInterval(amount * -60))
            }
        }
        context.saveWithTry()
    }
}


