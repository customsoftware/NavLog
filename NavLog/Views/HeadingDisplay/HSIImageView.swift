//
//  HSIImageView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/26/23.
//

import SwiftUI

struct HSIImageView: View {
    
    @State var courseState: CourseState
    
    var body: some View {
        VStack {
            VStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .fill(.black)
                    .shadow(radius: 5)
                    .padding(10)
                    .frame(width: 350, height: 350)
                
                Text("\(Int(courseState.currentHeading))")
                    .bold()
                    .offset(y: -335)
                    .colorInvert()
            }
            CenterLine(width: 1, height: 80, center: 200, top: 0)
            CenterLine(width: 1, height: 80, center: 200, top: 40)
            CenterLine(width: 1, height: 150, center: 200 + (Int((courseState.plannedHeading - courseState.currentHeading)) * 10), top: -210)
                
        }
    }
}

#Preview {
    HSIImageView(courseState: generateDemoCourseState())
}


struct CenterLine: View {
    @State var width: Int
    @State var height: Int
    @State var center: Int
    @State var top: Int
    
    var body: some View {
        Path() { path in
            path.move(to: CGPoint(x: center - (width/2), y: top))
            path.addLine(to: CGPoint(x: center - (width/2), y: top + height))
            path.addLine(to: CGPoint(x: center + (width/2), y: top + height))
            path.addLine(to: CGPoint(x: center + (width/2), y: top))
        }
        .offsetBy(dx: 0, dy: -330)
        .stroke(lineWidth: 2)
        .fill(.white)
    }
}
