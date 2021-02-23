//
//  ContentView.swift
//  hodie
//
//  Created by 김현식 on 2021/02/10.
//

import SwiftUI
import PartialSheet
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    @State private var selectedDate: Date = Date()
    @State private var showingDefaultSetting = false
    @State private var showingClearActionSheet = false
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    // TODO: multiple scheduler is added
    var body: some View {
        VStack{
            HStack{
                
                Button {
                    withAnimation{
                        selectedDate = Calendar.current.date(byAdding: .day,value: -1, to: selectedDate)!
                    }
                } label: {
                    Image(systemName: "arrowtriangle.left")
                }
                .padding([.leading])
                
                Text(DateFormatter.dateOnlyFormatter.string(from: selectedDate))
                    .transition(.opacity)
                    .id("\(selectedDate)")
                    .onTapGesture {
                        partialSheetManager.showPartialSheet(content:{ DatePickerView(selectedDate: $selectedDate)})
                    }
                
                Button {
                    withAnimation{
                        selectedDate = Calendar.current.date(byAdding: .day,value: 1, to: selectedDate)!
                    }
                } label: {
                    Image(systemName: "arrowtriangle.right")
                }
                
                Spacer()
                
                Button {
                    showingClearActionSheet = true
                } label: {
                    Image(systemName: "trash").imageScale(.large)
                }
                .actionSheet(isPresented: $showingClearActionSheet){
                    ActionSheet(title: Text("Reset"), message: Text("Do you want to reset Scheduler? "), buttons: [
                        .default(Text("Reset to default")) {
                            withAnimation(.spring()){
                                context.delete( Scheduler.fetchScheduler(at: selectedDate, context: context))
                            }
                        },
                        .default(Text("Clear Scheduler")){
                            withAnimation(.spring()){
                                Scheduler.fetchScheduler(at: selectedDate, context: context).reset(context: context)
                            }
                        },
                        .cancel()
                    ])
                }
                
                Button {
                  //  showingDefaultSetting = true
                } label: {
                    Text("Menu")
                }
                .sheet(isPresented: $showingDefaultSetting){
                    DefaultSchedulerView(scheduler: Scheduler.fetchDefaultScheduler(context: context))
                }
            }
            .padding()
            
            SchedulerView(scheduler: Scheduler.fetchScheduler(at: selectedDate, context: context))
            .onAppear{
                whereIsMySQLite()
                setNotification(context: context)
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

private func setNotification(context: NSManagedObjectContext){
    let scheduler = Scheduler.fetchScheduler(at: Date(), context: context)
    let manager = LocalNotificationManager()
    manager.requestPermission()
    for task in scheduler.todoTasks.filter({$0.notification}) {
        manager.addNotification(task: task)
    }
    manager.scheduleNotifications()
}
