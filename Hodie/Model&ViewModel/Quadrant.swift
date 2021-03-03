//
//  Quadrant.swift
//  Hodie
//
//  Created by 김현식 on 2021/03/02.
//

import SwiftUI

enum Quadrant {
    case one, two, three, four, error

    var oppsite: Quadrant {
        switch self {
        case .one:
            return .three
        case .two:
            return .four
        case .three:
            return .one
        case .four:
            return .two
        default:
            return .error
        }
    }

    init(center: CGPoint, point: CGPoint) {
        let newPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        if newPoint.x > 0 && newPoint.y >= 0 {
            self = .one
        } else if newPoint.x >= 0 && newPoint.y < 0 {
            self = .four
        } else if newPoint.x < 0 && newPoint.y <= 0 {
            self = .three
        } else if newPoint.x <= 0 && newPoint.y > 0 {
            self = .two
        } else {
            print("some error")
            self = .error
        }
    }

    init(size: CGSize, point: CGPoint) {
        let center = CGPoint(x: size.width/2, y: size.height/2)
        self.init(center: center, point: point)
    }

    static func quadrants(size: CGSize, point: CGPoint) -> [Quadrant] {
        var result = [Quadrant]()
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let newPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        if newPoint.x > 0 && newPoint.y >= 0 {
            result.append(.one)
        }
        if newPoint.x >= 0 && newPoint.y < 0 {
            result.append(.four)
        }
        if newPoint.x < 0 && newPoint.y <= 0 {
            result.append(.three)
        }
        if newPoint.x <= 0 && newPoint.y > 0 {
            result.append(.two)
        }
        return result
    }

    func isFromLeft(stack: [Quadrant]) -> Bool {
        print("angle isLeft: \(self)")
        switch stack[0] {
        case .one:
            return stack[1] == (.four)
        case .two:
            return stack[1] == (.one)
        case .three:
            return stack[1] == (.two)
        case .four:
            return stack[1] == (.three)
        case .error:
            return false
        }
    }
}
