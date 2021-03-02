//
//  CircleText.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//  AngledText was wrote by referring to https://git.kabellmunk.dk/prototyping-custom-ui-in-swiftui-talk/custom-ui-prototype-in-swiftui

import SwiftUI

private struct TextViewSizeKey: PreferenceKey {
    static var defaultValue: [CGSize] { [] }
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

private struct PropagateSize<V: View>: View {
    var content: () -> V
    var body: some View {
        content()
            .background(GeometryReader { proxy in
                Color.clear.preference(key: TextViewSizeKey.self, value: [proxy.size])
            })
    }
}

public struct AngledText: View {

    @Binding var todoTask: TodoTask
    var radius: CGFloat
    var start: Double
    var end: Double

    private var angle: Angle {
        Angle(radians: start + interval)
    }
    private var text: String {
        todoTask.name
    }

    private var interval: Double {
        return todoTask.endTime.asRadians > todoTask.startTime.asRadians ? (end - start)/2 :(end - start + .radianRound)/2
    }
    internal var textModifier: (Text) -> Text = { $0 }
    internal var spacing: CGFloat = 0

    @State private var size: CGSize = CGSize(width: 10000, height: 0)

    private var availableRadius: CGFloat {
        radius - unavailableRadius
    }

    // unavailable space for text using its height
    private var unavailableRadius: CGFloat {
        size.height / 2 / tan(CGFloat(todoTask.interval))
    }

    public var body: some View {
        VStack {
            PropagateSize {
                textModifier(Text(text))
            }
            .frame(width: abs(availableRadius), height: size.height, alignment: .center)
            .rotationEffect(rotationAngle())
            // Midpoint from possible space to end
            .offset(x: cos(CGFloat(angle.radians)) * (availableRadius/2 + unavailableRadius),
                    y: sin(CGFloat(angle.radians)) * (availableRadius/2 + unavailableRadius))

        }
        .frame(width: radius * 2, height: radius * 2)
        .onPreferenceChange(TextViewSizeKey.self) { sizes in
            self.size = sizes.first ?? CGSize(width: 10000, height: 0)
        }
        .accessibility(label: Text(text))
    }

    private func rotationAngle() -> Angle {
        angle.degrees < 270 && angle.degrees > 90 ? Angle(degrees: angle.degrees - 180) : angle
    }
}

extension AngledText {
    public func kerning(_ kerning: CGFloat) -> AngledText {
        var copy = self
        copy.spacing = kerning
        return copy
    }

    public func italic() -> AngledText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .italic()
        }
        return copy
    }

    public func bold() -> AngledText {
        fontWeight(.bold)
    }

    public func fontWeight(_ weight: Font.Weight?) -> AngledText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .fontWeight(weight)
        }
        return copy
    }
}
