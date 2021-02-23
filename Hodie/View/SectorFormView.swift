//
//  SectorFormView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct SectorFormView : View {
    
    @Binding var todoTask: TodoTask
    @State var delay: Double
    
    @State var radius: CGFloat = 0

    var body: some View{
        //TODO: Animation
        GeometryReader{ geometry in
            ZStack{
                SectorFormShape(todoTask: $todoTask,radius: radius).fill(todoTask.color.color)
                
                AngledText(todoTask: $todoTask, radius: radius)
                    .bold()
                    .foregroundColor(todoTask.color.isDarkColor ? .white : .black)
            }.onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                    withAnimation(.spring()){
                        radius =  min(geometry.size.width, geometry.size.height) / 2
                    }
                }
            }
        }
    }
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
    var animatableData: CGFloat {
        get{ radius }
        set{ radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(
            x: center.x + radius * cos(CGFloat(todoTask.startAngle.radians)),
            y: center.y + radius * sin(CGFloat(todoTask.startAngle.radians))
        )
        var path = Path()
        
        path.move(to: center)
        path.addLine(to: start)
        path.addArc(center: center, radius: radius, startAngle: todoTask.startAngle, endAngle: todoTask.endAngle, clockwise: false)
        path.addLine(to: center)
        path.closeSubpath()
        
        return path
    }
}
