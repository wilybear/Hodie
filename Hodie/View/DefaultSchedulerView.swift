//
//  DefaultSchedulerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/22.
//

import SwiftUI

struct DefaultSchedulerView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var scheduler: Scheduler
    @Environment(\.managedObjectContext) var context
    @State private var selelctedTask: TodoTask?
    @State var isCreating: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    VStack(alignment: .leading) {
                        ForEach(scheduler.todoTasks.sorted(), id: \.self) { todoTask in
                            HStack {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .fill(todoTask.color.color)
                                    .frame(width: 40, height: 40)
                                    .padding([.leading, .trailing])

                                VStack(alignment: .leading) {
                                    Text(todoTask.name).font(.title2)
                                    Text("\(todoTask.startTime_!) ~ \(todoTask.endTime_!)").font(.caption)

                                }
                                Spacer()
                            }.onTapGesture {
                                isCreating = false
                                selelctedTask = todoTask
                            }
                            Divider()
                        }.sheet(item: $selelctedTask, onDismiss: {
                            selelctedTask = nil
                            context.rollback()  // if adding new Tasks is canceled
                        }, content: { TaskEditorView(scheduler: scheduler, task: $0, isNewTask: $isCreating) })
                    }

                }

                PlusButtonView {
                    isCreating = true
                    selelctedTask = TodoTask(context: context)
                }
            }
            .navigationTitle(Text("Saved Tasks"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button { presentationMode.wrappedValue.dismiss() } label: { Text("Close") })

        }
    }
}
