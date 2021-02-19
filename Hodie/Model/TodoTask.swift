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
        set{ startTime_ = DateFormatter.timeFormatter.string(from: newValue)}
    }
    var endTime: Date{
        get{ DateFormatter.timeFormatter.date(from: endTime_ ?? Date.stringOfCurrentTime)!}
        set{ endTime_ = DateFormatter.timeFormatter.string(from: newValue)}
    }
    
    var name:String{
        get{ name_ ?? "" }
        set{ name_ = newValue }
    }
    
    var memo:String{
        get{ memo_ ?? "" }
        set{ memo_ = newValue}
    }
    
}


