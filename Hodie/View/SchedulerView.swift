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
    @State var isNewTask: Bool = false

    @ObservedObject var scheduler: Scheduler

    var body : some View {
        VStack {
           TaskInfoView(scheduler: scheduler)

            ZStack {
                ClockView(scheduler) { todoTask in
                            isNewTask = false
                            selelctedTask = todoTask
                }
                .padding()

                PlusButtonView {
                    isNewTask = true
                    selelctedTask = TodoTask(context: context)
                }
            }

        }.sheet(item: $selelctedTask, onDismiss: {
            selelctedTask = nil
            context.rollback()  // if adding new Tasks is canceled
        }, content: { TaskEditorView(scheduler: scheduler, task: $0, isNewTask: $isNewTask) })

    }
}

struct TaskInfoView: View {
    @Environment(\.managedObjectContext) var context
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
        let request = TodoTask.fetchRequest(scheduler: scheduler, time: Date())
        _tasks = FetchRequest(fetchRequest: request)
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(currentTask?.name ?? "" )
                .font(.title)
                .fontWeight(.bold)

            Text(currentTask?.memo ?? "")
                .font(.body)
        }
        .onAppear {
            print("onAppear called")
        }

    }
}
