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
    @EnvironmentObject var isEditMode: EditTask

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(alignment: .center) {

                    Button {
                        withAnimation {
                            yearAndMonth = Calendar.current.date(byAdding: .month, value: -1, to: yearAndMonth)!
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.left.fill")
                            .imageScale(.medium)
                    }
                    .padding([.leading])

                    Text("\(String(Calendar.current.component(.year, from: yearAndMonth))) . \(Calendar.current.component(.month, from: yearAndMonth))")
                        .font(.body)
                        .fontWeight(.heavy)
                        .transition(.opacity)
                        .id("\(yearAndMonth)")
                        .onTapGesture {
                            withAnimation {
                  //            showingDatePicker = true
                            }
                        }
    //                    .sheet(isPresented: $showingDatePicker, onDismiss: {
    //                        yearAndMonth = selectedDate
    //                    }, content: {
    //                        DatePickerView(selectedDate: $selectedDate)
    //                    })

                    Button {
                        withAnimation {
                            yearAndMonth = Calendar.current.date(byAdding: .month, value: 1, to: yearAndMonth)!
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.right.fill")
                            .imageScale(.medium)
                    }

                    Spacer()

                    Button {
                        withAnimation {
                            isEditMode.isEditMode.toggle()
                        }
                    } label: {
                        if isEditMode.isEditMode {
                            GradientIcon(size: iconSize(size: geometry.size), systemName: "lock.open.fill")
                        } else {
                            GradientIcon(size: iconSize(size: geometry.size), systemName: "lock.fill")
                        }
                    }
                    .padding([.top, .bottom, .leading])

                    Button {
                        showingClearActionSheet = true
                    } label: {
                        GradientIcon(size: iconSize(size: geometry.size), systemName: "tray.2.fill")
                    }
                    .actionSheet(isPresented: $showingClearActionSheet) {
                        ActionSheet(title: Text(LocalizedStringKey("Management")), message: Text("Management options"), buttons: [
                            .default(Text(LocalizedStringKey("Management_bring"))) {
                                withAnimation(.spring()) {
                                    Scheduler.fetchScheduler(at: selectedDate, context: context).copyDefaultScheduler(context: context)
                                }
                            },
                            .default(Text(LocalizedStringKey("Management_clear"))) {
                                withAnimation(.spring()) {
                                    Scheduler.fetchScheduler(at: selectedDate, context: context).reset(context: context)
                                }
                            },
                            .cancel()
                        ])
                    }
                    .padding([.top, .bottom])
                    .padding([.leading], 10)

                    Button {
                        showingDefaultSetting = true
                    } label: {
                        GradientIcon(size: iconSize(size: geometry.size), systemName: "list.dash")
                    }
                    .sheet(isPresented: $showingDefaultSetting) {
                        DefaultSchedulerView(scheduler: Scheduler.fetchDefaultScheduler(context: context))
                    }
                    .padding([.top, .bottom, .trailing])
                    .padding([.leading], 10)
                }

                HListCalendarView(date: $selectedDate, yearAndMonth: $yearAndMonth)
                    .padding([.top, .bottom])

                SchedulerView(scheduler: Scheduler.fetchScheduler(at: selectedDate, context: context), context: context)
                    .environmentObject(isEditMode)

                }
                .onAppear {
                    whereIsMySQLite()
                    setNotification(context: context)
                }
            .onDisappear {
                setNotification(context: context)
            }

        }
    }

    private func iconSize(size: CGSize) -> CGFloat {
        size.width / 15
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

struct GradientIcon: View {

    var size: CGFloat
    var systemName: String

    var body: some View {
        Color.iconGradient
            .mask(Image(systemName: systemName)
                    .imageScale(.large)
            ).frame(width: size, height: size)
    }
}
