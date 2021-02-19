//
//  ClockView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct ClockView: View {
    @ObservedObject var scheduler: Scheduler
    var longPressHandler: (TodoTask) -> (Void)
    
    init(_ scheduler: Scheduler,longPressAction: @escaping (TodoTask) -> (Void)){
        self.scheduler = scheduler
        longPressHandler = longPressAction
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Circle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width * 0.02, height: geometry.size.height * 0.02 ,alignment: .center)
                    
                
                Circle()
                    .stroke(Color.lightGray)
                    .padding()
                
                ForEach(scheduler.todoTasks.sorted(), id: \.self){ todoTask in
                    let task = Binding<TodoTask>(
                        get: { todoTask },
                        set: { scheduler.todoTasks.update(with: $0)})
                    
                    SectorFormView(todoTask: task)
                    .onLongPressGesture {
                        longPressHandler(todoTask)
                    }
                }
                .padding()
                
                Arrow()
                    .rotationEffect(.init(radians: Date().asRadians))
                
                ZStack{
                    ForEach( 0..<24, id: \.self){ idx in
                        Text("\(idx)")
                            .frame(maxWidth: minSize(for: geometry.size), maxHeight: minSize(for: geometry.size) , alignment: .top)
                            .rotationEffect(.degrees( 15 * Double(idx)))
                            .font(clockFont(for: geometry.size , index: idx))
                    }
                }
            }
        }
    }
    
    private func minSize(for size:CGSize) -> CGFloat{
        min(size.width, size.height)
    }
    
    private func clockFont(for size:CGSize, index:Int) -> Font{
        let time = [0, 6, 12, 18, 24]
        return Font.system(size: min(size.width, size.height) * 0.03 ,weight: time.contains(index) ? .heavy : .light ,design: .default )
    }
}

struct Arrow: Shape {
    
    func path(in rect: CGRect) -> Path {
   
        let size = rect.width * 0.005
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 5
        var path = Path()
        path.move(to: center)
//        path.addLines([
//            CGPoint(x:start.x + arrowSize, y: start.y + arrowSize/2),
//            CGPoint(x:start.x - arrowSize, y: start.y + arrowSize/2),
//            start
//        ])
        path.addLines( [
            CGPoint(x: center.x , y: center.y + size),
            CGPoint(x: center.x + radius * 0.9 , y: center.y + size),
            CGPoint(x: center.x + radius * 0.9, y:  center.y + size * 2.5),
            CGPoint(x: center.x + radius, y: center.y),
            CGPoint(x: center.x + radius * 0.9, y:  center.y - size * 2.5),
            CGPoint(x: center.x + radius * 0.9 , y: center.y - size),
            CGPoint(x: center.x , y: center.y - size)
        ])
        
        return path
    }
}
