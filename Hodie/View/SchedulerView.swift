//
//  SchedulerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/12.
//

import SwiftUI
import CoreData

struct SchedulerView: View {
    @Environment(\.managedObjectContext) var context
    @State private var selelctedTask: TodoTask?
    @State private var tappedTask: TodoTask?
    @State var isNewTask: Bool = false
    @EnvironmentObject var editMode: EditTask
    @ObservedObject var scheduler: Scheduler
    @ObservedObject var taskInfoModel: TasKInfoModel

    init(scheduler: Scheduler, context: NSManagedObjectContext) {
        self.scheduler = scheduler
        _tappedTask = State(wrappedValue: nil)
        taskInfoModel = TasKInfoModel(scheduler: scheduler, context: context)
    }

    var body : some View {
        VStack {
//            TaskInfoView(task: Binding<TodoTask?>(get: {
//                if tappedTask != nil {
//                    return tappedTask
//                } else {
//                    return currentTask
//                }
//            }, set: {_ in }))
            TaskInfoView(taskInfoModel: taskInfoModel)

            ZStack {
                ClockView(scheduler, longPressAction: { todoTask in
                            isNewTask = false
                            selelctedTask = todoTask
                }, tapAction: { todoTask in
                    withAnimation {
                        taskInfoModel.task = todoTask
                    }
                })
                .padding()

                PlusButtonView {
                    isNewTask = true
                    selelctedTask = TodoTask(context: context)
                }
            }

        }
        .sheet(item: $selelctedTask, onDismiss: {
            selelctedTask = nil
            context.rollback()  // if adding new Tasks is canceled
        }, content: { TaskEditorView(scheduler: scheduler, task: $0, isNewTask: $isNewTask) })

    }
}

class TasKInfoModel: ObservableObject {
    @Published var task: TodoTask?
    var scheduler: Scheduler
    var context: NSManagedObjectContext

    init(scheduler: Scheduler, context: NSManagedObjectContext) {
        self.scheduler = scheduler
        self.context = context
        let current = DateFormatter.timeFormatter.date(from: Date.stringOfCurrentTime)!
        let currentRange = current..<current.addingTimeInterval(1)
        let request = TodoTask.fetchRequest(scheduler: scheduler, time: Date())
        let tasks = (try? context.fetch(request))
        task = tasks!.filter {
            for suspect in $0.startTime.divideTimeBasedOnMidnight(end: $0.endTime) {
                if currentRange.overlaps(suspect) {
                        return true
                    }
                }
                return false
         }.first ?? nil
    }
}

struct TaskInfoView: View {
    @EnvironmentObject var editMode: EditTask
    @ObservedObject var taskInfoModel: TasKInfoModel

    var body: some View {
        VStack(alignment: .center) {
            if editMode.isEditMode {
                Text(LocalizedStringKey("Edit_mode_guide"))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.3)
            } else {
                Text(taskInfoModel.task?.name ?? "" )
                    .font(.title)
                    .fontWeight(.bold)
                    .padding([.bottom])

                Text(taskInfoModel.task?.memo ?? "")
                    .font(.body)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding()

    }
}
