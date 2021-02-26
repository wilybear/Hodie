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
        let availableRange = todoTask.availableRadians().0
        var result: Double
        let movedAmount = dragState.radians.0
        if movedAmount == .zero{
            return todoTask.startTime.asRadians
        }
        if availableRange.contains( movedAmount){
            result =  todoTask.startTime.asRadians + movedAmount
        }else{
            if availableRange.upperBound < movedAmount {
                result = todoTask.startTime.asRadians + availableRange.upperBound
                
            }else{
                result = todoTask.startTime.asRadians + availableRange.lowerBound
                
            }
        }
        
        return result
    }
    
    var endRadians: Double{
        let availableRange = todoTask.availableRadians().1
        var result: Double
        let movedAmount = dragState.radians.1
        if movedAmount == .zero{
            return todoTask.endTime.asRadians
        }
        print("drag end radians \( movedAmount)")
        if availableRange.contains(movedAmount){
            print(availableRange)
            result = todoTask.endTime.asRadians + movedAmount
        }else{
            if availableRange.upperBound < movedAmount{
                
                result = todoTask.endTime.asRadians + availableRange.upperBound
                print("upper radians \(result)")
            }else{
                result = todoTask.endTime.asRadians + availableRange.lowerBound
                print("lower radians \(result)")
            }
        }
        print("start radians \(result)")
        return result.truncatingRemainder(dividingBy: .radianRound)
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
                            //if task.timeNearStartOrEnd(radian: radianAtPoint, size: size){
                              //  state = .dragging(start:angle(between: dragV.startLocation, ending: dragV.location, coord: size) ,end: .zero)
                            // }else{
                            print("hello:\(dragV.location) startLocation:\(dragV.startLocation) size:\( angle(between: dragV.startLocation, ending: dragV.location, coord: size))")
                                state = .dragging(start: .zero ,end: angle(between: dragV.startLocation, ending: dragV.location, coord: size))
                            //}
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

func angle(between starting: CGPoint, ending: CGPoint, coord: CGSize) -> Double {
    let v1 = CGVector(dx: starting.x - coord.width/2, dy: starting.y - coord.height/2)
    let v2 = CGVector(dx: ending.x - coord.width/2, dy: ending.y - coord.height/2)
    let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
    return Double(angle > 0 ? angle : angle + .pi * 2)
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
            y: center.y + radius * sin(CGFloat(start))
        )
        var path = Path()
        
        path.move(to: center)
        path.addLine(to: startPoint)
        path.addArc(center: center, radius: radius, startAngle: Angle(radians: start), endAngle: Angle(radians: end), clockwise: false)
        path.addLine(to: center)
        
        return path
    }
}
