//
//  ScaleAndFade.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

import SwiftUI

struct ScaleAndFade: ViewModifier {
    // True when the transition is active
    var isEnabled: Bool
    
    func body(content: Content) -> some View{
        return content
            .scaleEffect(isEnabled ? 0.1 : 1)
            .opacity(isEnabled ? 0 : 1)
    }
}

extension AnyTransition{
    static let scaleAndFade = AnyTransition.modifier(
        active: ScaleAndFade(isEnabled: true),
        identity: ScaleAndFade(isEnabled: false)
    )
}
