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
        get{
            color_ ?? .init(from: Color.blue)
        }
        set{
            color_ = newValue
        }
    }
    
    // Date to time string, time string to Date
    var startTime: Date{
        get{
            formatter.date(from: startTime_!)!
        }
        set{
            startTime_ = formatter.string(from: newValue)
        }
    }
    var endTime: Date{
        get{
            formatter.date(from: endTime_!)!
        }
        set{
            endTime_ = formatter.string(from: newValue)
        }
    }
    
    private var formatter : DateFormatter{
        get{
            let format = DateFormatter()
            format.locale = Locale(identifier:"ko_KR" )
            format.dateFormat = "HH:mm:ss"
            return format
        }
    }
}
