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
    @State private var tappedTask: TodoTask?
    @State var isNewTask: Bool = false
    @EnvironmentObject var editMode: EditTask
    @ObservedObject var scheduler: Scheduler
    @FetchRequest var tasks: FetchedResults<TodoTask>

    var currentTask: TodoTask? {
        let current = DateFormatter.timeFormatter.date(from: Date.stringOfCurrentTime)!
        let currentRange = current..<current.addingTimeInterval(1)
        return tasks.filter {
            for suspect in $0.startTime.divideTimeBasedOnMidnight(end: $0.endTime) {
                if currentRange.overlaps(suspect) {
                    return true
                }
            }
            return false
        }.first ?? nil
    }

    init(scheduler: Scheduler) {
        self.scheduler = scheduler
        let request = TodoTask.fetchRequest(scheduler: scheduler, time: Date())
        _tasks = FetchRequest(fetchRequest: request)
    }

    var body : some View {
        VStack {
            TaskInfoView(task: Binding<TodoTask?>(get: {
                if tappedTask != nil {
                    return tappedTask
                } else {
                    return currentTask
                }
            }, set: {_ in }))

            ZStack {
                ClockView(scheduler, longPressAction: { todoTask in
                            isNewTask = false
                            selelctedTask = todoTask
                }, tapAction: { todoTask in
                    withAnimation {
                        tappedTask = todoTask
                    }
                })
                .padding()

                PlusButtonView {
                    isNewTask = true
                    selelctedTask = TodoTask(context: context)
                }
            }

        }
        .onAppear {
            tappedTask = nil
        }
        .sheet(item: $selelctedTask, onDismiss: {
            selelctedTask = nil
            context.rollback()  // if adding new Tasks is canceled
        }, content: { TaskEditorView(scheduler: scheduler, task: $0, isNewTask: $isNewTask) })

    }
}

struct TaskInfoView: View {
    @EnvironmentObject var editMode: EditTask
    @Binding var task: TodoTask?

    var body: some View {
        VStack(alignment: .center) {
            if editMode.isEditMode {
                Text("You can modify task by long press and dragging it.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            } else {
                Text(task?.name ?? "" )
                    .font(.title)
                    .fontWeight(.bold)
                    .padding([.bottom])

                Text(task?.memo ?? "")
                    .font(.body)
            }
        }
        .padding()

    }
}
