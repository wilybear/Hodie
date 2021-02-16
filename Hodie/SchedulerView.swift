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

    // TODO: Linear Calendar should be added
    var body : some View {
        NavigationView{
            ClockView(longPressAction: { todoTask in
                selelctedTask = todoTask
                showingEditorView = true
            })
            .padding()
            .sheet(item: $selelctedTask, onDismiss: {
                selelctedTask = nil
                context.rollback()  //if adding new Tasks is canceled
            }){
                TaskEditorView(task: $0)
            }
            .navigationBarItems(leading: Button(action: {
                // TodoTask(context: context) create TodoTask instance in context, if adding newTask is canceled by user, the instance in context will be rollback
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
    
    
//    private delete(){
//        indexSet.forEach{ context.delete(scheduler.todoTasks.sorted()[$0])}
//        context.saveWithTry()
//    }
}
