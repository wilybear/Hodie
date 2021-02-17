//
//  CircleText.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/15.
//

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

// make each character identifiable
private struct IdentifiableCharacter: Identifiable {
    var id: String { "\(index) \(character)" }
    let index: Int
    let character: Character
}

extension IdentifiableCharacter {
    var string: String { "\(character)" }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Curved Text

public struct AngledText: View {


    @Binding var todoTask: TodoTask
    var radius: CGFloat
    private var angle: Angle {
        todoTask.midAngle
    }
    private var text: String {
        todoTask.name
    }
    internal var textModifier: (Text) -> Text = { $0 }
    internal var spacing: CGFloat = 0

    @State private var sizes: [CGSize] = []

    private func textRadius(at index: Int) -> CGFloat {
        radius - size(at: index).height / 2
    }
    
    private func distance(at index: Int) -> CGFloat{
        (radius-unavailableRadius) / CGFloat(text.count) * CGFloat(index)
    }
    
    private var letterWidths: [CGFloat] {
        sizes.map {$0.width}
    }
    
    private var unavailableRadius : CGFloat {
        let maxHeight = sizes.map{$0.height}.max()
        return (maxHeight ?? 1) / 2 / tan(CGFloat(todoTask.interval))
    }

    public var body: some View {
        VStack {
            ZStack {
                ForEach(textAsCharacters()) { item in
                    PropagateSize {
                        self.textView(char: item)
                    }
                    .frame(width: self.size(at: item.index).width,
                           height: self.size(at: item.index).height)
                    .rotationEffect(rotationAngle())
                    .offset(x: cos(CGFloat(angle.radians)) * (distance(at: item.index) + unavailableRadius) ,
                            y: sin(CGFloat(angle.radians)) * (distance(at: item.index) + unavailableRadius))
                }
            }
            .frame(width: radius * 2, height: radius * 2)
            .onPreferenceChange(TextViewSizeKey.self) { sizes in
                self.sizes = sizes
            }
        }
        .accessibility(label: Text(text))
    }

    private func textAsCharacters() -> [IdentifiableCharacter] {
        let string =  angle.degrees < 270 && angle.degrees > 90 ? String(text.reversed()) : text
        return string.enumerated().map(IdentifiableCharacter.init)
    }
    
    private func rotationAngle()-> Angle{
        angle.degrees < 270 && angle.degrees > 90 ? Angle(degrees: angle.degrees - 180) : angle
    }

    private func textView(char: IdentifiableCharacter) -> some View {
        textModifier(Text(char.string))
    }

    private func size(at index: Int) -> CGSize {
        sizes[safe: index] ?? CGSize(width: 1000000, height: 0)
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


