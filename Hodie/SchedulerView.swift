//
//  SchedulerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI
import CoreData

struct SchedulerView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var scheduler: Scheduler
    
    @State private var showingEditorView = false
    @State private var selelctedTask: TodoTask?
    @State private var confirmDeletePresent = false


    var body : some View {
        NavigationView{
            List{
                ForEach(scheduler.todoTasks.sorted(), id: \.self){ todoTask in
                    VStack{
                        Text("\(todoTask.name)")
                        Text("\(DateFormatter.timeFormatter.string(from: todoTask.startTime) ) ~ \(DateFormatter.timeFormatter.string(from: todoTask.endTime))")
                    }.foregroundColor(todoTask.color.color)
                    .onLongPressGesture {
                        selelctedTask = todoTask
                        showingEditorView = true
                    }
                }
            }
            .sheet(item: $selelctedTask, onDismiss: {
                selelctedTask = nil
                context.rollback()  //if adding new Tasks is canceled
            }){
                TaskEditorView(task: $0)
            }
            .navigationBarItems(leading: Button(action: {
                selelctedTask = TodoTask(context: context)
                showingEditorView = true
            }, label: {
                Image(systemName: "plus.circle")
            }),trailing: EditButton())
           /*
             .sheet(isPresented: $showingEditorView, content: {
                 TaskEditorView(task: selelctedTask ?? TodoTask(context: context), context: context)
             })
             **/
        }
    }
}
