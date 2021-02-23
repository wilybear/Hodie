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
    @Environment(\.managedObjectContext) var context
    @ObservedObject var scheduler: Scheduler
    
    @State var draft: TodoTask
    @State var textData : TextData
    @State private var showingAlert = false
    @State private var alertType: EditorAlertType = .none
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
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: { Text("Cancel") }
                .padding()
                
                Spacer()
                
                Button{
                    alertType = saveTask()
                    if saveTask() == .none{
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        showingAlert = true
                    }
                } label: { Text("Done")}
                .padding()
                .alert(isPresented: $showingAlert){
                    if alertType == .overlapped{
                        return Alert(title: Text("Alert") ,message: Text(alertType.rawValue), primaryButton: .destructive(Text("OK"), action: {
                            scheduler.forceInsert(task: draft, context: context)
                            presentationMode.wrappedValue.dismiss()
                        }), secondaryButton: .cancel())
                    }else{
                        return Alert(title: Text("Alert"), message: Text(alertType.rawValue), dismissButton: .default(Text("OK")))
                    }
                }
            }
            
            Form{
                Section{
                    TextField("Task Name", text: $textData.taskName )
                        .onChange(of: textData.taskName) { value in
                            textData.taskName = limitedText(value: value, limit: Scheduler.taskNameLimit)
                        }
                }
                
                Section{
                    DatePicker("Start time", selection:$draft.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End time", selection:$draft.endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Memo about the task")) {
                    TextEditor(text: $textData.taskMemo)
                        .frame(minHeight: 100, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .onChange(of: textData.taskMemo) { value in
                            textData.taskMemo = limitedText(value: value, limit: Scheduler.memolimit)
                        }
                        
                }

                Section{
                    Toggle(isOn: $draft.notification){ Text("Notification") }
                }
                
                Section {
                    ColorSwatchView(draftColor: $draft.color)
                }
            
                if !isNewTask {
                    Section{
                        Button {
                            context.delete(draft)
                            context.saveWithTry()
                            presentationMode.wrappedValue.dismiss()
                        } label: { Text("Delete") }
                    }
                }
            }
        }
        
    }
    
    @discardableResult
    private func saveTask()->EditorAlertType{
        draft.name = textData.taskName
        draft.memo = textData.taskMemo
        let result = scheduler.checkValidation(task: draft)
        if result == .none{
            scheduler.todoTasks.update(with: draft)
            do {
                try context.save()
            }catch{
                print("vvs: \(error)")
                return .coredataError
            }
        }
        setNotification(context: context)
        return result
    }
}

private func limitedText(value: String, limit: Int) -> String {
    value.count > limit ? String(value.prefix(limit)) : value
}

private func setNotification(context: NSManagedObjectContext){
    let scheduler = Scheduler.fetchScheduler(at: Date(), context: context)
    let manager = LocalNotificationManager()
    manager.requestPermission()
    for task in scheduler.todoTasks.filter({$0.notification}) {
        manager.addNotification(task: task)
    }
    manager.scheduleNotifications()
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
        
        let columns = [ GridItem(.adaptive(minimum: 50)) ]
        
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


struct TextData{
    var taskName: String
    var taskMemo: String
}

