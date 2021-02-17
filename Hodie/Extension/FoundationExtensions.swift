//
//  FoundationExtensions.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import Foundation

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
}

extension Date{
    var asRadians: Double {
        let currentDateComponent = Calendar(identifier: .gregorian).dateComponents([.hour, .minute], from: self)
        let minutes = (currentDateComponent.hour! * 60) + currentDateComponent.minute!
        let ratio = Double(minutes) / Double(1440)
        return (ratio * 360 - 90) * .pi / Double(180)
    }
}
