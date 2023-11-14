//
//  WeightAndBalanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/13/23.
//

import SwiftUI

struct WeightAndBalanceView: View {
    let boundaries = Boundaries()
    let modifier : CGFloat = 0.5
    @State var computedMoment: CGFloat = 237.2
    @State var computedWeight: CGFloat = 2135.0
    
    var body: some View {
        ZStack(content: {
            Path { path in
                path.move(to: buildCGPoint(from: boundaries.forwardAnchor))
                path.addLine(to: buildCGPoint(from: boundaries.forwardInflection))
                path.addLine(to: buildCGPoint(from: boundaries.forwardMax))
                path.addLine(to: buildCGPoint(from: boundaries.aftMax))
                path.addLine(to: buildCGPoint(from: boundaries.aftMin))
                path.closeSubpath()
            }
            .offsetBy(dx: -200, dy: -500)
            .stroke(.black, lineWidth: 2.0, antialiased: true)
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10, alignment: .center)
                .offset(x: computedMoment * modifier, y: ((1200 - computedWeight) * modifier) * modifier)
        })
    }
    
    func buildCGPoint(from coordinate: Coordinates) -> CGPoint {
        let returnPoint = CGPoint(x: coordinate.x / modifier, y: (modifier * coordinate.y))
        return returnPoint
    }
}

#Preview {
    WeightAndBalanceView()
}


struct Boundaries {
    var forwardAnchor: Coordinates = Coordinates(x: 120, y: 2350)
    var forwardInflection: Coordinates = Coordinates(x: 210, y: 1550)
    var forwardMax: Coordinates = Coordinates(x: 247, y: 1200)
    var aftMax: Coordinates = Coordinates(x: 269, y: 1200)
    var aftMin: Coordinates = Coordinates(x: 137, y: 2350)
}

struct Coordinates {
    var x: CGFloat
    var y: CGFloat
}
