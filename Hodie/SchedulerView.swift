//
//  SchedulerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI
import CoreData
import PartialSheet

struct SchedulerView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var showingEditorView = false
    @State private var selelctedTask: TodoTask?
    @State private var confirmDeletePresent = false
    //@Binding var selectedDate: Date
    
    var schedulerRequest: FetchRequest<Scheduler>
    var result: FetchedResults<Scheduler> { schedulerRequest.wrappedValue }
    var scheduler : Scheduler{
        if result.isEmpty {
            let scheduler = Scheduler(context: context)
            scheduler.date = Date()
            scheduler.name = "untitled"
            context.saveWithTry()
            return scheduler
        }else{
            return result.first!
        }
    }
    
    init(selectedDate: Date){
        schedulerRequest = FetchRequest<Scheduler>(fetchRequest: Scheduler.fetchRequest(Scheduler.predicateDate(at: selectedDate)))
    }
    
    
    // TODO: Linear Calendar should be added
    var body : some View {
        NavigationView{
            ClockView(scheduler: scheduler,longPressAction: { todoTask in
                        selelctedTask = todoTask
                        showingEditorView = true
                    })
                    .padding()
                    .sheet(item: $selelctedTask, onDismiss: {
                        selelctedTask = nil
                        context.rollback()  //if adding new Tasks is canceled
                    }){
                        TaskEditorView(scheduler: scheduler,task: $0)
                    }
                    .navigationBarItems(leading: Button(action: {
                        // TodoTask(context: context) create TodoTask instance in context, if adding newTask is canceled by user, the instance in context will be rollback
                        selelctedTask = TodoTask(context: context)
                        showingEditorView = true
                    }, label: {
                        Image(systemName: "plus.circle")
                    }),trailing: EditButton())
            
//            .background(LinearGradient(gradient: Gradient(colors: Color.BackgroundColors), startPoint: .top, endPoint: .bottom))
        }
        
    }
    
//    private delete(){
//        indexSet.forEach{ context.delete(scheduler.todoTasks.sorted()[$0])}
//        context.saveWithTry()
//    }
}
