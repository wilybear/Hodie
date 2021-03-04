//
//  ColorExtension.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/17.
//

import SwiftUI

extension Color {
    static let brightRed = Color("BrightRed")
    static let brightBlue = Color("BrightBlue")
    static let brightGreen = Color("BrightGreen")
    static let brightOrange = Color("BrightOrange")
    static let brightPink = Color("BrightPink")
    static let brightPurple = Color("BrightPurple")
    static let brightSkyBlue = Color("BrightSkyBlue")
    static let brightWhite = Color("BrightWhite")
    static let brightYellow = Color("BrightYellow")
    static let lightGray = Color("LightGray")

    static let BrightColors = [brightRed, brightOrange, brightYellow,
                               brightGreen, brightSkyBlue, brightBlue, brightPurple, brightPink, brightWhite]

    static let BackgroundColors = [Color("BackgroundTop"), Color("BackgroundMid"), Color("BackgroundBottom")]

    static let blueGradient = LinearGradient(gradient: Gradient(colors: Color.BackgroundColors), startPoint: .leading, endPoint: .trailing)
    static let iconGradient = LinearGradient(gradient: Gradient(colors: [Color("BackgroundTop"), Color("BackgroundMid"), Color("BackgourndLast")]), startPoint: .top, endPoint: .bottom)
}
