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
    
    @ObservedObject var scheduler: Scheduler
    @Environment(\.managedObjectContext) var context
    @State private var draft: TodoTask
    @State private var color: Color
    
    init(scheduler: Scheduler,task: TodoTask){
        self.scheduler = scheduler
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
                    ColorSwatchView(selection: $color)
                }
                // TODO: little memo for todotask
                Section{
                    Button(action: {
                        context.delete(draft)
                        context.saveWithTry()
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Delete")
                    })
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


struct ColorSwatchView: View {
    @Binding var selection: Color
    
    var body: some View{
        let columns = [
            GridItem(.adaptive(minimum: 60))
        ]
        LazyVGrid(columns: columns, spacing:10){
            ForEach(Color.BrightColors, id: \.self){ color in
                ZStack{
                    Circle()
                        .fill(color)
                        .frame(width:50, height: 50)
                        .onTapGesture {
                            selection = color
                        }
                        .padding(10)
                    if selection == color {
                        Circle()
                            .stroke(color, lineWidth: 5)
                            .frame(width:60, height: 60)
                    }
                }
            }
        }.padding()
    }
}
