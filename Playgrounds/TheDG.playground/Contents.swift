//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport


struct TickMark: View {
    var origin: CGPoint
    var opposite: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x - (origin.x - opposite.x), y: origin.y))
            path.addLine(to: CGPoint(x: origin.x - (origin.x - opposite.x), y: origin.y - (origin.y - opposite.y)))
            path.addLine(to: CGPoint(x: origin.x, y: origin.y - (origin.y - opposite.y)))
      }
        .fill(.white)
    }
}


struct HSISwiftUIView: View {
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var tickWidth: CGFloat = 2.0
    var tickHeight: CGFloat = 30.0
    
    var body: some View {
        ZStack(alignment: .center) {
            TickMark(origin: CGPointMake(0, 0), opposite: CGPoint(x: tickHeight, y: tickWidth))
                .rotationEffect(Angle(degrees: 45), anchor: .topLeading)
            
            TickMark(origin: CGPointMake(frameWidth - tickWidth, 0), opposite: CGPoint(x: frameWidth, y: tickHeight + tickWidth))
                .rotationEffect(Angle(degrees: 45), anchor: .topTrailing)
            
            TickMark(origin: CGPointMake(frameWidth - tickHeight, frameHeight - tickWidth), opposite: CGPoint(x: frameWidth, y: frameHeight))
                .rotationEffect(Angle(degrees: 45), anchor: .bottomTrailing)
            
            TickMark(origin: CGPointMake(0, frameHeight), opposite: CGPoint(x: tickWidth, y: frameHeight - tickHeight))
                .rotationEffect(Angle(degrees: 45), anchor: .bottomLeading)
        }
        .frame(width: frameWidth, height: frameHeight, alignment: .center)
  }
}

struct DGView: View {
    let outerFrame: CGFloat = 300.0
    let ringWidth: CGFloat = 40.0
    let adjuster: CGFloat = 0.785
    
    var body: some View {
        ZStack {

            Circle()
                .stroke(lineWidth: ringWidth)
                .foregroundColor(.primary)
                .frame(width: outerFrame, height: outerFrame, alignment: .center)
                .padding(.horizontal, ringWidth/1.5)
                .padding(.vertical, ringWidth/1.5)
                .scaledToFit()
            

            HSISwiftUIView(frameWidth: outerFrame * adjuster, frameHeight: outerFrame * adjuster)
            
            Text("N")
                .foregroundColor(.primary).colorInvert()
                .bold()
                .font(.title2)
                .offset(x: 0, y: -outerFrame/2)
            Text("E")
                .foregroundColor(.primary).colorInvert()
                .bold()
                .font(.title2)
                .offset(x: outerFrame/2, y: 0)
            
            Text("S")
                .foregroundColor(.primary).colorInvert()
                .bold()
                .font(.title2)
                .offset(x: 0, y: outerFrame/2)
            Text("W")
                .foregroundColor(.primary).colorInvert()
                .bold()
                .font(.title2)
                .offset(x: -outerFrame/2, y: 0)
        }
        
    }
}

struct InstrumentView: View {
    var body: some View {
        DGView()
            .rotationEffect(.degrees(0), anchor: .center)
    }
}


// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(InstrumentView())
