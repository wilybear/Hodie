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
    @State private var newName = ""
    @State private var isPresent = false
    @State private var isUpdatePresent = false
    @State private var newTask: TodoTask
    
    init (context: NSManagedObjectContext){
        _newTask = State(wrappedValue: TodoTask(context: context))
    }
    
    var body : some View {
        NavigationView{
            List{
                ForEach(scheduler.todoTasks.sorted(), id: \.self){ todoTask in
                    VStack{
                        Text("\(todoTask.name)")
                        Text("\(DateFormatter.timeFormatter.string(from: todoTask.startTime) ) ~ \(DateFormatter.timeFormatter.string(from: todoTask.endTime))")
                    }.foregroundColor(todoTask.color.color)
                    .onLongPressGesture {
                        isPresent = true
                    }
                    .sheet(isPresented: $isUpdatePresent){
                        TaskEditorView(task: Binding<TodoTask>(
                                        get:{
                                            scheduler.todoTasks.getObject(matching: todoTask)
                                        },
                                        set:{
                                            scheduler.todoTasks.update(with: $0)
                                        }
                        ),isPresent: $isPresent)
                    }
                }
            } .navigationBarItems(leading: Button(action: {
                isPresent = true
            }, label: {
                Image(systemName: "plus.circle")
            }),trailing: EditButton())
            .sheet(isPresented: $isPresent){
                TaskEditorView(task: $newTask,isPresent: $isPresent)
            }
        }
    }
}
