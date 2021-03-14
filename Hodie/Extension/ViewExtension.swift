//
//  ViewExtension.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/22.
//

import SwiftUI

extension View {

    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    func `conditionalIf`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
    if condition {
        transform(self)
    } else {
        self
        }
    }

}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
