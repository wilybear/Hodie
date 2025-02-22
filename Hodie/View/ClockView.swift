//
//  ClockView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct ClockView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var scheduler: Scheduler
    @State var raidus: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var editMode: EditTask

    var onLongPress: (TodoTask) -> Void
    var onTap: (TodoTask) -> Void

    @State private var textViewRect: CGRect = CGRect()

    init(_ scheduler: Scheduler, longPressAction: @escaping (TodoTask) -> Void, tapAction: @escaping (TodoTask) -> Void) {
        self.scheduler = scheduler
        onLongPress = longPressAction
        onTap = tapAction
    }

    var body: some View {
        GeometryReader { geometry in

            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: geometry.size.width * 0.02, height: geometry.size.height * 0.02, alignment: .center)
                    .zIndex(1)

                Circle()
                    .fill(colorScheme == .dark ? Color.black : Color.brightWhite )
                    .padding()

                Circle()
                    .stroke(Color.lightGray)
                    .padding(clockFontSize(for: geometry.size) * 1.3)

                Arrow(radius: raidus)
                    .rotationEffect(.init(radians: Date().asRadians))
                    .foregroundColor(.red)
                    .zIndex(1)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: -2, y: -2)
                    .onAppear {
                        withAnimation(.spring()) {
                            raidus = min(geometry.size.width, geometry.size.height) / 5
                        }
                    }

                ForEach(scheduler.todoTasks.sorted(), id: \.self) { todoTask in
                    let task = Binding<TodoTask>(
                        get: { todoTask },
                        set: { scheduler.todoTasks.update(with: $0)})
                    SectorFormView(todoTask: task, delay: Double.random(in: 0..<0.7))
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: -2, y: -2)
                        .conditionalIf(!editMode.isEditMode) {
                            $0.gesture( tapGesture(task: todoTask), including: GestureMask.gesture)
                        }
                }
                .frame(width: minSize(for: geometry.size) - clockFontSize(for: geometry.size) * 2.7,
                       height: minSize(for: geometry.size) - clockFontSize(for: geometry.size) * 2.7, alignment: .center)

                ZStack {
                    ForEach( 0..<24, id: \.self) { idx in
                        Text("\(idx)")
                            .frame(maxWidth: minSize(for: geometry.size), maxHeight: minSize(for: geometry.size), alignment: .top)
                            .rotationEffect(.degrees( 15 * Double(idx)))
                            .font(clockFont(for: geometry.size, index: idx))
                            .background(GeometryGetter(rect: $textViewRect))
                    }
                }
            }
        }
    }

    private func tapGesture(task: TodoTask) -> some Gesture {
        TapGesture().onEnded {
            onTap(task)
        }.simultaneously(with: LongPressGesture().onEnded {_ in
            onLongPress(task)
        })
    }

    private func minSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height)
    }

    private func clockFontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.03
    }

    private func clockFont(for size: CGSize, index: Int) -> Font {
        let time = [0, 6, 12, 18, 24]
        return Font.system(size: clockFontSize(for: size), weight: time.contains(index) ? .heavy : .light, design: .default )
    }

}

struct Arrow: Shape {

    var radius: CGFloat = 0
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let size = rect.width * 0.005
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        path.move(to: center)
        path.addLines( [
            CGPoint(x: center.x, y: center.y + size),
            CGPoint(x: center.x + radius * 0.9, y: center.y + size),
            CGPoint(x: center.x + radius * 0.9, y: center.y + size * 2.5),
            CGPoint(x: center.x + radius, y: center.y),
            CGPoint(x: center.x + radius * 0.9, y: center.y - size * 2.5),
            CGPoint(x: center.x + radius * 0.9, y: center.y - size),
            CGPoint(x: center.x, y: center.y - size)
        ])

        return path
    }
}

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { (g) -> Path in
            DispatchQueue.main.async { // avoids warning: 'Modifying state during view update.' Doesn't look very reliable, but works.
                self.rect = g.frame(in: .global)
            }
            return Path() // could be some other dummy view
        }
    }
}
