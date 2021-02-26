//
//  FoundationExtensions.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import Foundation
import SwiftUI

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

extension DateFormatter {
    static var timeFormatter : DateFormatter = {
            let format = DateFormatter()
            format.locale = Locale(identifier:"ko_KR" )
            format.dateFormat = "HH:mm"
            return format
    }()
    
    static var dateOnlyFormatter : DateFormatter = {
        let format = DateFormatter()
        format.locale = Locale(identifier:"ko_KR" )
        format.dateFormat = "yyyy-MM-dd"
        return format
    }()
    
    static var yearMonthFormatter : DateFormatter = {
        let format = DateFormatter()
        format.locale = Locale(identifier:"ko_KR" )
        format.dateFormat = "yyyy-MM"
        return format
    }()
}

extension Date{
    static var stringOfCurrentTime: String = {
        DateFormatter.timeFormatter.string(from: Date())
    }()

}

extension Set where Element: Identifiable{
    func getObject(matching element: Element) -> Element{
        let index = self.firstIndex(of: element)
        return self[index!]
    }
}
extension Double{
    var perimeter: Double{
        return self * 2 * .pi
    }
    
    static var radianRound: Double{
        360 * Double.pi / 180
    }
    
    var asTime: Date{
        let ratio = ((self * Double(180) / .pi) + 90)/360
        let minutes = ratio * Double(1440)
        let hour = Int(minutes) / 60
        let minute = Int(minutes) % 60
        var dateComponets = DateComponents()
        dateComponets.year = hour < 9 ? 1999 : 2000
        dateComponets.month = 1
        dateComponets.day = 1
        dateComponets.hour = hour
        dateComponets.minute = minute
        dateComponets.second = 0
        
        return Calendar.current.date(from: dateComponets)!
    }
    
    var asMinuteAmount: Int{
        let ratio = self / (360 * .pi / 180)
        return Int(1440 * ratio)
    }

}

extension Date{
    var asRadians: Double {
        let currentDateComponent = Calendar(identifier: .gregorian).dateComponents([.hour, .minute], from: self)
        let minutes = (currentDateComponent.hour! * 60) + currentDateComponent.minute!
        let ratio = Double(minutes) / Double(1440)
        var radians = (ratio * 360 - 90) * .pi / Double(180)
        if radians < 0 {
            radians += Double.radianRound
        }
        return radians
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    
    var datesOfMonth: [Date] {
        var currentDate = self.startOfMonth
        var dates = [Date]()
        
        while currentDate < self.endOfMonth {
            dates.append(currentDate)
            currentDate = nextDay(date: currentDate)
        }
        return dates
    }

    func nextDay(date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = 1
        return Calendar.current.date(byAdding: dateComponents, to: date)!
    }
    
    func isToday() -> Bool{
        Calendar.current.isDate(Date(), inSameDayAs: self)
    }
    
    func divideTimeBasedOnMidnight(end: Date) -> [Range<Date>]{
        if self < end{
            return [(self.addingTimeInterval(1))..<end]
        }
        let midnightPM = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self, direction: .forward)!
        let midnightAM = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: end, direction: .forward)!
        var result = [Range<Date>]()
        if self.addingTimeInterval(1) < midnightPM {
            result.append((self.addingTimeInterval(1))..<midnightPM)
        }
        
        if midnightAM.addingTimeInterval(86401)<end.addingTimeInterval(86400){
            result.append(midnightAM.addingTimeInterval(86401)..<end.addingTimeInterval(86400))
        }
        
        if midnightAM.addingTimeInterval(1)<end{
            result.append(midnightAM.addingTimeInterval(1)..<end)
        }
        
        return result
    }
    
}
