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

    var body: some View {

        VStack {
            ScrollViewReader { scrollView in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(yearAndMonth.datesOfMonth, id: \.self) { day in

                            ZStack {
                                DateView(date: day, selectedDate: $date)
                                .font(.caption)
                                .frame(width: UIScreen.main.bounds.width / 7)
                                .onAppear {
                                    if isSelectedDate(day) {
                                        withAnimation {
                                            scrollView.scrollTo(day, anchor: .center)
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
        var body: some View {
            VStack {
                let dayData = DateType(date: date)
                Text("\(dayData.Day)")
                Divider()
                Text(dayData.Date)
                    .padding(1.5)
                    .foregroundColor(date.isToday() ? .blue : .black)
                    .overlay(
                        isSelectedDate(date) ? Circle().stroke(lineWidth: 2).foregroundColor(.blue)
                                    : Circle().stroke().foregroundColor(.clear)
                    )
                    .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))

            } .onTapGesture {
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
