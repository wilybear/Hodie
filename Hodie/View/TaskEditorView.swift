//
//  TaskAdderView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI
import CoreData
import Combine

struct TaskEditorView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var scheduler: Scheduler
    @Environment(\.managedObjectContext) var context
    
    @State var draft: TodoTask
    @State var textData : TextData
    @State private var showingAlert = false
    @State private var taskEditError: EditorAlertMessage = .none
    @State private var inputText = ""
    
    private let taskNameLimit = 15
    private let memolimit = 50
    
    @Binding var isNewTask: Bool
    
    init(scheduler: Scheduler,task: TodoTask, isNewTask: Binding<Bool>){
        self.scheduler = scheduler
        _draft = State(wrappedValue: task)
        _isNewTask = isNewTask
        _textData = State(wrappedValue: TextData.init(taskName: task.name, taskMemo: task.memo))
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
                Section{
                    TextField("Task Name", text: $draft.name )
                        .onChange(of: draft.name, perform: { value in
                            if value.count > taskNameLimit {
                                draft.name 	= String(value.prefix(taskNameLimit))
                            }
                        })
                }
                Section{
                    // TODO: start time should always faster than end time
                    DatePicker("Start time", selection:$draft.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End time", selection:$draft.endTime, displayedComponents: .hourAndMinute)
                }
                Section(header: Text("Memo about the task")){
                    TextEditor(text: $textData.taskMemo)
                        .frame(minHeight: 100, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .onChange(of: textData.taskMemo, perform: { value in
                            if value.count > memolimit {
                                textData.taskMemo = String(value.prefix(memolimit))
                            }
                        })
                        
                }
                
                Section {
                    ColorSwatchView(draftColor: $draft.color)
                }
                
                
                // TODO: little memo for todotask
                if !isNewTask {
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
    }
    
    @discardableResult
    private func saveTask()->Bool{
        draft.memo = inputText
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


// ColorSwatch is worte by referring to https://medium.com/swlh/creating-a-curated-color-picker-in-swiftui-18a9a86f7721
struct ColorSwatchView: View {
    @Binding var draftColor: SerializableColor
    @State var selectedColor: SerializableColor
    let colors: [SerializableColor] = Color.BrightColors.map({SerializableColor(from: $0)})
    
    init(draftColor: Binding<SerializableColor>){
        self._draftColor = draftColor
        _selectedColor = State(wrappedValue: draftColor.wrappedValue)
    }
    
    var body: some View{
        let columns = [
            GridItem(.adaptive(minimum: 50))
        ]
        LazyVGrid(columns: columns, spacing:10){
            ForEach(colors, id: \.self){ color in
                ZStack{
                    Circle()
                        .fill(color.color)
                        .frame(width:50, height: 50)
                        .onTapGesture {
                            selectedColor = color
                            draftColor = color
                        }
                        .padding(10)
                    if selectedColor.color == color.color {
                        Circle()
                            .stroke(color.color, lineWidth: 5)
                            .frame(width:60, height: 60)
                    }
                }
            }
        }.padding()
    }
}

enum EditorAlertMessage: String{
    case none
    case time = "The end time is earlier than the start time."
    case exist = "The task already exists in that time interval. Are you sure you want to delete and register this task?"
    case nilValueInTask = "Enter a name for the task."
    case tooLongText = "Task is to long"
}

struct TextData{
    var taskName: String
    var taskMemo: String
}

