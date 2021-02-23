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
    @State private var selelctedTask: TodoTask?
    @State var isCreating: Bool = false
    
    @ObservedObject var scheduler: Scheduler
    
    var body : some View {
        VStack{
           TaskInfoView(scheduler: scheduler)
            .frame(height: 150, alignment: .center)
            
            ZStack {
                ClockView(scheduler, longPressAction: { todoTask in
                            isCreating = false
                            selelctedTask = todoTask
                        })
                        .padding()
                        .sheet(item: $selelctedTask, onDismiss: {
                            selelctedTask = nil
                            context.rollback()  //if adding new Tasks is canceled
                        }){
                            TaskEditorView(scheduler: scheduler,task: $0, isNewTask: $isCreating)
                        }
                PlusButtonView {
                    isCreating = true
                    selelctedTask = TodoTask(context: context)
                }       
            }

        }
        
    }
}

struct TaskInfoView : View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest var currentTask: FetchedResults<TodoTask>
    
    init(scheduler: Scheduler) {
        let request = TodoTask.fetchRequest(scheduler: scheduler, time: Date())
        _currentTask = FetchRequest(fetchRequest: request)
    }
    
    var body: some View{
        VStack(alignment: .center) {
            Text(currentTask.first?.name ?? "" )
                .font(.title)
                .fontWeight(.bold)
            Text(currentTask.first?.memo ?? "")
                .font(.body)
        }
        
    }
}
