//
//  PlusButtonView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/22.
//

import SwiftUI

struct PlusButtonView: View {

    let onTap: () -> Void

    init(action: @escaping () -> Void) {
        onTap = action
    }

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button {
                   onTap()
                } label: {
                    Text("+")
                           .font(.system(.largeTitle))
                           .frame(width: 66, height: 60)
                           .foregroundColor(Color.white)
                           .padding(.bottom, 7)
                }
                .background(LinearGradient(gradient: Gradient(colors: Color.BackgroundColors), startPoint: .leading/*@END_MENU_TOKEN@*/, endPoint: .trailing/*@END_MENU_TOKEN@*/))
                .cornerRadius(38.5)
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            }
        }
    }
}
