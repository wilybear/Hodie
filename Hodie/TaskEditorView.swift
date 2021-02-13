//
//  TaskAdderView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI

struct TaskEditorView: View {
    
    @EnvironmentObject var scheduler: Scheduler
    @Environment(\.managedObjectContext) var context
    @Binding var task: TodoTask

    @State private var draft: TodoTask
    @State private var color: Color
    @Binding var isPresent:Bool
    
    init(task: Binding<TodoTask>,isPresent: Binding<Bool>){
        _task = task
        _isPresent = isPresent
        _draft = State(wrappedValue: task.wrappedValue)
        _color = State(wrappedValue: task.wrappedValue.color.color)
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    isPresent = false
                }){
                    Text("Cancel")
                }
                .padding()
                Spacer()
                Button(action: {
                    addTask()
                    isPresent = false      
                }){
                    Text("Done")
                }
                .padding()
            }
            Form{
                Section(header: Text("Task")){
                    TextField("task", text: $draft.name )
                }
                Section(header: Text("Time")){
                    DatePicker("start time", selection:$draft.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("end time", selection:$draft.endTime, displayedComponents: .hourAndMinute)
                }
                Section(header: Text("Color")){
                    ColorPicker("Color", selection: $color)
                }
            }
        }
    }
    
    @discardableResult
    private func addTask()->Bool{
        draft.color = SerializableColor(from: color)
        scheduler.todoTasks.insert(draft)
    
        do {
            try context.save()
        }catch{
            print("vvs: \(error)")
            return false
        }
        return true
    }
}

