//
//  ClockView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct ClockView: View {
    @EnvironmentObject var scheduler: Scheduler
    var longPressHandler: (TodoTask) -> (Void)
    
    init(longPressAction: @escaping (TodoTask) -> (Void)){
        longPressHandler = longPressAction
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Circle().fill(Color.gray)
                    .padding()
                ForEach(scheduler.todoTasks.sorted(), id: \.self){ todoTask in
                    SectorFormView(todoTask: todoTask)
                    .onLongPressGesture {
                        longPressHandler(todoTask)
                    }
                }
                .padding()
                ZStack{
                    ForEach( 0..<24, id: \.self){ idx in
                        Text("\(idx)")
                            .frame(
                                maxWidth: minSize(for: geometry.size), maxHeight: minSize(for: geometry.size) , alignment: .top)
                            .rotationEffect(.degrees(  15 * Double(idx)))
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
