//
//  TaskAdderView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI
import CoreData

struct TaskEditorView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var scheduler: Scheduler
    @Environment(\.managedObjectContext) var context
    @State private var draft: TodoTask
    @State private var color: Color
    
    init(task: TodoTask){
        _draft = State(wrappedValue: task)
        _color = State(wrappedValue: _draft.wrappedValue.color.color)
        print("init of Task Editor View is called")
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Cancel")
                }
                .padding()
                Spacer()
                Button(action: {
                    saveTask()
                    presentationMode.wrappedValue.dismiss()
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
                    // TODO: start time should always faster than end time
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
    private func saveTask()->Bool{
        draft.color = SerializableColor(from: color)
        scheduler.todoTasks.update(with: draft)
    
        do {
            try context.save()
        }catch{
            print("vvs: \(error)")
            return false
        }
        return true
    }
}

