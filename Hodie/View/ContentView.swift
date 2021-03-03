//
//  ContentView.swift
//  hodie
//
//  Created by 김현식 on 2021/02/10.
//

import SwiftUI
import PartialSheet
import CoreData
import HalfModal

struct ContentView: View {

    @Environment(\.managedObjectContext) var context
    @State private var selectedDate: Date = Date()
    @State private var yearAndMonth: Date = Date()
    @State private var showingDefaultSetting = false
    @State private var showingClearActionSheet = false

    @EnvironmentObject var partialSheetManager: PartialSheetManager

    var body: some View {
        ZStack {
        VStack {
            HStack(alignment: .center) {

                Button {
                    withAnimation {
                        yearAndMonth = Calendar.current.date(byAdding: .month, value: -1, to: yearAndMonth)!
                    }
                } label: {
                    Image(systemName: "arrowtriangle.left.fill")
                        .imageScale(.small)
                }
                .padding([.leading])

                Text("\(String(Calendar.current.component(.year, from: yearAndMonth))) . \(Calendar.current.component(.month, from: yearAndMonth))")
                    .font(.body)
                    .fontWeight(.heavy)
                    .transition(.opacity)
                    .id("\(yearAndMonth)")
                    .onTapGesture {
                        withAnimation {
                            partialSheetManager.showPartialSheet({
                                yearAndMonth = selectedDate
                            }, content: { DatePickerView(selectedDate: $selectedDate)})
                        }
                    }

                Button {
                    withAnimation {
                        yearAndMonth = Calendar.current.date(byAdding: .month, value: 1, to: yearAndMonth)!
                    }
                } label: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .imageScale(.small)
                }

                Spacer()

                Button {
                    showingClearActionSheet = true
                } label: {
                    Image(systemName: "trash").imageScale(.medium)
                }
                .actionSheet(isPresented: $showingClearActionSheet) {
                    ActionSheet(title: Text("Reset"), message: Text("Do you want to reset Scheduler? "), buttons: [
                        .default(Text("Reset to default")) {
                            withAnimation(.spring()) {
                                context.delete( Scheduler.fetchScheduler(at: selectedDate, context: context))
                            }
                        },
                        .default(Text("Clear Scheduler")) {
                            withAnimation(.spring()) {
                                Scheduler.fetchScheduler(at: selectedDate, context: context).reset(context: context)
                            }
                        },
                        .cancel()
                    ])
                }
                .padding()

                Button {
                    showingDefaultSetting = true
                } label: {
                    Image(systemName: "t.circle.fill")
                }
                .sheet(isPresented: $showingDefaultSetting) {
                    DefaultSchedulerView(scheduler: Scheduler.fetchDefaultScheduler(context: context))
                }
                .padding()
            }

            HListCalendarView(date: $selectedDate, yearAndMonth: $yearAndMonth)
                .padding([.top, .bottom])

            SchedulerView(scheduler: Scheduler.fetchScheduler(at: selectedDate, context: context))
            .onAppear {
                whereIsMySQLite()
                setNotification(context: context)
            }
        }
        }
        .addPartialSheet()
    }
}

func whereIsMySQLite() {
    let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding

    print("check out lLLL\(path ?? "Not found")")
}

private func setNotification(context: NSManagedObjectContext) {
    let scheduler = Scheduler.fetchScheduler(at: Date(), context: context)
    let manager = LocalNotificationManager()
    manager.requestPermission()
    for task in scheduler.todoTasks.filter({$0.notification}) {
        manager.addNotification(task: task)
    }
    manager.scheduleNotifications()
}
