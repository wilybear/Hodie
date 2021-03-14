//
//  HListCalendarView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/25.
//

import SwiftUI

struct HListCalendarView: View {
    @Binding var date: Date
    @Binding var yearAndMonth: Date

    var isCurrentMonth: Bool {
        yearAndMonth.datesOfMonth.contains(date.startOfDay)
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollview in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(yearAndMonth.datesOfMonth, id: \.self) { day in
                            DateView(date: day, selectedDate: $date)
                                .font(.caption)
                                .frame(width: UIScreen.main.bounds.width / 7)
                                .onAppear {
                                    withAnimation {
                                        if isCurrentMonth {
                                            if isSelectedDate(day) {
                                                scrollview.scrollTo(day, anchor: .center)
                                            }
                                        } else {
                                            if yearAndMonth.datesOfMonth.first == day {
                                                scrollview.scrollTo(day, anchor: .center)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }.animation(.spring())
            }
        }
    }

    func isSelectedDate(_ day: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: day)
    }

    struct DateView: View {
        @State var date: Date
        @Binding var selectedDate: Date
        @State private var degrees = 0.0
        @Environment(\.colorScheme) var colorScheme

        var textColor: Color {
            if colorScheme == .dark {
                return date.isToday() ? .blue : .white
            } else {
                return date.isToday() ? .blue : .black
            }
        }
        var body: some View {
            VStack {
                let dayData = DateType(date: date)
                Text("\(dayData.Day)")
                    .font(.caption)
                    .fontWeight(.bold)
                Divider()
                Text(dayData.Date)
                    .font(.body)
                    .padding(4)
                    .foregroundColor(textColor)
                    .overlay(
                        isSelectedDate(date) ? Circle().stroke(lineWidth: 1).foregroundColor(.blue)

                                    : Circle().stroke().foregroundColor(.clear)
                    )
                    .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))

            }
            .onTapGesture {
                withAnimation {
                    self.degrees += 360
                    selectedDate = date
                }
            }
        }

        func isSelectedDate(_ day: Date) -> Bool {
            Calendar.current.isDate(selectedDate, inSameDayAs: day)
        }
    }
}

struct DateType {
    var Day: String
    var Date: String
    var Year: String
    var Month: String
    var MonthNo: String

    init(date: Date) {
        let current = Calendar.current
        Date = String(current.component(.day, from: date))
        let monthNo = current.component(.month, from: date)
        MonthNo = String(monthNo)
        Month = String(current.monthSymbols[monthNo - 1])
        Year = String(current.component(.year, from: date))
        let weekNo = current.component(.weekday, from: date)
        Day = current.shortWeekdaySymbols [weekNo - 1]
    }
}
