//
//  Task.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/11.
//

import Foundation
import SwiftUI

extension TodoTask: Comparable{
    public static func < (lhs: TodoTask, rhs: TodoTask) -> Bool {
        lhs.startTime < rhs.startTime
    }
    
    var color: SerializableColor {
        get{ color_ ?? .init(from: Color.blue)}
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
        get{ name_ ?? " " }
        set{ name_ = newValue}
    }
    
}
