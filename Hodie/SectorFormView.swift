//
//  SectorFormView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct SectorFormView : View {
    @Binding var todoTask: TodoTask
    var body: some View{
        //TODO: Animation
        GeometryReader{ geometry in
            ZStack{
                SectorFormShape(todoTask: $todoTask).fill(todoTask.color.color)
                AngledText(todoTask: $todoTask, radius: min(geometry.size.width, geometry.size.height) / 2)
                    .bold()
                    .foregroundColor(todoTask.color.isDarkColor ? .white : .black)
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
        Angle(radians: startTime.asRadians + (endTime.asRadians - startTime.asRadians)/2 )
    }
}

struct SectorFormShape: Shape {
    @Binding var todoTask: TodoTask

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
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


//extension Ring.Wedge {
//    var startColor: Color {
//        return Color(hue: hue, saturation: 0.4, brightness: 0.8)
//    }
//
//    var endColor: Color {
//        return Color(hue: hue, saturation: 0.7, brightness: 0.9)
//    }
//
//    var backgroundColor: Color {
//        Color(hue: hue, saturation: 0.5, brightness: 0.8, opacity: 0.1)
//    }
//
//    var foregroundGradient: AngularGradient {
//        AngularGradient(
//            gradient: Gradient(colors: [startColor, endColor]),
//            center: .center,
//            startAngle: .radians(start),
//            endAngle: .radians(end)
//        )
//    }
//}
