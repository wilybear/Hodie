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
    
    private var schedulerRequest: FetchRequest<Scheduler>
    
    private var result: FetchedResults<Scheduler> { schedulerRequest.wrappedValue }
    
    private var scheduler : Scheduler{
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
                
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            isCreating = true
                            selelctedTask = TodoTask(context: context)
                        }, label: {
                            Text("+")
                                   .font(.system(.largeTitle))
                                   .frame(width: 66, height: 60)
                                   .foregroundColor(Color.white)
                                   .padding(.bottom, 7)
                        })
                        .background(LinearGradient(gradient: Gradient(colors: Color.BackgroundColors), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    }
                }
            }
//            .background(LinearGradient(gradient: Gradient(colors: Color.BackgroundColors), startPoint: .top, endPoint: .bottom))
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
            Text(currentTask.first?.memo ?? "")
                .font(.body)
        }
        
    }
}
