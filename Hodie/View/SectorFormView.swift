//
//  SectorFormView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct SectorFormView : View {
    
    @Environment(\.managedObjectContext) var context
    @Binding var todoTask: TodoTask
    @State var delay: Double
    
    @State var radius: CGFloat = 0
    
    @GestureState var dragState = DragState.inactive
    
    var startRadians: Double{
        let radians = todoTask.startTime.asRadians - dragState.radians.0
        return radians
    }
    
    var endRadians: Double{
        let radians = todoTask.endTime.asRadians - dragState.radians.1
        return radians
    }

    var body: some View{
        GeometryReader{ geometry in
            ZStack{
                SectorFormShape(todoTask: $todoTask,radius: radius, start: startRadians,end: endRadians).fill(todoTask.color.color)
                
                AngledText(todoTask: $todoTask, radius: radius, start:todoTask.startTime.asRadians ,end:todoTask.endTime.asRadians )
                    .bold()
                    .foregroundColor(todoTask.color.isDarkColor ? .white : .black)
                    .font(.caption2)
            }
            .transition(.scaleAndFade)
            .scaleEffect(dragState.isActive ? 1.2 : 1)
            .gesture(sectorFormGesture(size: geometry.size, task: todoTask))
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                    withAnimation(.spring()){
                        radius =  min(geometry.size.width, geometry.size.height) / 2
                    }
                }
            }
        }
    }
    private let minimumLongPressDuration = 0.5
    
    @State var isStart: Bool?
    
    private func sectorFormGesture(size: CGSize,task: TodoTask)-> some Gesture{
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 4, coordinateSpace: .local))
            .updating($dragState) { value, state, transaction in
                withAnimation{
                    switch value {
                    // Long press begins.
                    case .first(true):
                        state = .pressing
                        
                    // Long press confirmed, dragging may begin.
                    case .second(true, let drag):
                        if let dragV = drag {
                            let radianAtPoint = pointToRadian(coordinate: size ,location: dragV.startLocation)
                            if task.timeNearStartOrEnd(radian: radianAtPoint, size: size){
                                state = .dragging(start:radianAtPoint - pointToRadian(coordinate: size, location: dragV.location) ,end: .zero)
                            }else{
                                state = .dragging(start: .zero ,end: radianAtPoint - pointToRadian(coordinate: size, location: dragV.location))
                            }
                        }else{
                            state = .dragging(start: .zero, end: .zero)
                        }
                   
                    // Dragging ended or the long press cancelled.
                    default:
                        state = .inactive
                    }
                }
            }
            .onEnded { value in
                withAnimation{
                    guard case .second(true, let drag?) = value else { return }
                    let radianAtPoint = pointToRadian(coordinate: size ,location: drag.startLocation)
                    task.dragTimeValue(value: radianAtPoint - pointToRadian(coordinate: size, location: drag.location), isStart: task.timeNearStartOrEnd(radian: radianAtPoint,size: size),context: context)
                }
            }
        return longPressDrag
        
    }
    
    enum DragState {
        case inactive
        case pressing
        case dragging(start:Double, end: Double)
        
        var radians: (Double , Double) {
            switch self {
            case .inactive, .pressing:
                return (.zero, .zero)
            case .dragging(let start, let end):
                return (start,end)
            }
        }
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }

}

private func pointToRadian(coordinate: CGSize, location: CGPoint) -> Double{
    let dx = location.x - coordinate.width/2
    let dy = location.y - coordinate.height/2
    let x = atan2(dy, dx)
    let radian = x > 0 ? x : 2 * .pi + x
    return Double(radian)
}

extension TodoTask{
    var startAngle: Angle{
        Angle(radians: startTime.asRadians)
    }
    var endAngle: Angle{
        Angle(radians: endTime.asRadians)
    }
    var midAngle: Angle{
        return Angle(radians: startTime.asRadians +  interval)
    }
    var interval: Double {
        return endTime > startTime ? (endTime.asRadians - startTime.asRadians)/2 : (endTime.asRadians - startTime.asRadians + 360 * .pi/180)/2
    }
}

struct SectorFormShape: Shape {
    @Binding var todoTask: TodoTask
    var radius: CGFloat
    var start: Double
    var end: Double
    var animatableData: CGFloat {
        get{ radius }
        set{ radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startPoint = CGPoint(
            x: center.x + radius * cos(CGFloat(start)),
            y: center.y + radius * sin(CGFloat(end))
        )
        var path = Path()
        
       // path.move(to: center)
        path.addLine(to: startPoint)
        path.addArc(center: center, radius: radius, startAngle: Angle(radians: start), endAngle: Angle(radians: end), clockwise: false)
        path.addLine(to: center)
        path.closeSubpath()
        
        return path
    }
}
