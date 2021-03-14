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
    @State var textData: TextData
    @State private var showingAlert = false
    @State private var alertType: EditorAlertType = .none
    @Binding var isNewTask: Bool

    init(scheduler: Scheduler, task: TodoTask, isNewTask: Binding<Bool>) {
        self.scheduler = scheduler
        _draft = State(wrappedValue: task)
        _isNewTask = isNewTask
        _textData = State(wrappedValue: TextData.init(taskName: task.name, taskMemo: task.memo))
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: { Text(LocalizedStringKey("Cancel")) }
                .padding()

                Spacer()

                Button {
                    alertType = saveTask()
                    if saveTask() == .none {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        showingAlert = true
                    }
                } label: { Text(LocalizedStringKey("Done"))}
                .padding()
                .alert(isPresented: $showingAlert) {
                    if alertType == .overlapped {
                        return Alert(title: Text(LocalizedStringKey("Alert")), message: Text(LocalizedStringKey(alertType.rawValue)), primaryButton: .destructive(Text(LocalizedStringKey("OK")), action: {
                            scheduler.forceInsert(task: draft, context: context)
                            presentationMode.wrappedValue.dismiss()
                        }), secondaryButton: .cancel())
                    } else {
                        return Alert(title: Text(LocalizedStringKey("Alert")), message: Text(LocalizedStringKey(alertType.rawValue)), dismissButton: .default(Text(LocalizedStringKey("OK"))))
                    }
                }
            }

            Form {
                Section {
                    TextField(LocalizedStringKey("Task Name"), text: $textData.taskName )
                        .onChange(of: textData.taskName) { value in
                            textData.taskName = limitedText(value: value, limit: Scheduler.taskNameLimit)
                        }
                }

                Section {
                    DatePicker(LocalizedStringKey("Start time"), selection: $draft.startTime, displayedComponents: .hourAndMinute)
                    DatePicker(LocalizedStringKey("End time"), selection: $draft.endTime, displayedComponents: .hourAndMinute)
                }

                Section(header: Text(LocalizedStringKey("Memo about the task"))) {
                    TextEditor(text: $textData.taskMemo)
                        .frame(minHeight: 100, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .onChange(of: textData.taskMemo) { value in
                            textData.taskMemo = limitedText(value: value, limit: Scheduler.memolimit)
                        }
                }

                Section {
                    Toggle(isOn: $draft.notification) { Text(LocalizedStringKey("Notification")) }
                        .onReceive([self.draft.notification].publisher.first()) { value in
                            if value {
                                let manager = LocalNotificationManager()
                                manager.requestPermission()
                            }
                        }
                }

                Section {
                    ColorSwatchView(draftColor: $draft.color)
                }

                if !isNewTask {
                    Section {
                        Button {
                            context.delete(draft)
                            context.saveWithTry()
                            presentationMode.wrappedValue.dismiss()
                        } label: { Text(LocalizedStringKey("Delete")) }
                    }
                }
            }
        }
        .onTapGesture {
            endEditing()
        }

    }
    private func endEditing() {
            UIApplication.shared.endEditing()
    }

    @discardableResult
    private func saveTask() -> EditorAlertType {
        draft.name = textData.taskName
        draft.memo = textData.taskMemo
        let result = scheduler.checkValidation(task: draft)
        if result == .none {
            scheduler.todoTasks.update(with: draft)
            do {
                try context.save()
            } catch {
                return .coredataError
            }
        }
        return result
    }
}

private func limitedText(value: String, limit: Int) -> String {
    value.count > limit ? String(value.prefix(limit)) : value
}

// ColorSwatch is worte by referring to https://medium.com/swlh/creating-a-curated-color-picker-in-swiftui-18a9a86f7721
struct ColorSwatchView: View {
    @Binding var draftColor: SerializableColor
    @State var selectedColor: SerializableColor

    let colors: [SerializableColor] = Color.BrightColors.map({SerializableColor(from: $0)})

    init(draftColor: Binding<SerializableColor>) {
        self._draftColor = draftColor
        _selectedColor = State(wrappedValue: draftColor.wrappedValue)
    }

    var body: some View {

        let columns = [ GridItem(.adaptive(minimum: 50)) ]

        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(colors, id: \.self) { color in
                ZStack {
                    Circle()
                        .fill(color.color)
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            selectedColor = color
                            draftColor = color
                        }
                        .padding(10)

                    if selectedColor.color == color.color {
                        Circle()
                            .stroke(color.color, lineWidth: 5)
                            .frame(width: 60, height: 60)
                    }
                }
            }
        }.padding()
    }
}

struct TextData {
    var taskName: String
    var taskMemo: String
}
