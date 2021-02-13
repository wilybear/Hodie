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
