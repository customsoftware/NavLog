//
//  HeadingNavigationView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 9/2/23.
//

import SwiftUI

struct HeadingNavigationView: View {
    
    @Binding var controllingWayPoint: WayPoint
    @Binding var gpsIsActive: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading, content: {
            Rectangle()
                .frame(minWidth: 280, idealWidth: 320, maxWidth: .infinity, minHeight: 280, idealHeight: 320, maxHeight: 320, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(15.0)
                .foregroundColor(Color(.systemBackground))
            VStack(alignment: .center, content: {
                Text("\(controllingWayPoint.headingFrom)")
                    .font(.bold(.body)())
                    .frame(minWidth: 280, idealWidth: 300, maxWidth: .infinity, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .foregroundColor(Color(.label))
                Rectangle() // This is the desired course line
                    .frame(minWidth: 2, idealWidth: 2, maxWidth: 2, minHeight: 175, idealHeight: 240, maxHeight: 270, alignment: .center)
                    .foregroundColor(Color(.label))
                Spacer()
            })
            
            /// The key to this working is its offset must be according to deviation of actual heading, obtained by GPS from planned heading is is programmed in. To do this we need to know the width of the containing view
            if gpsIsActive {
                VStack(content: {
                    Text("Actual")
                    Rectangle() // This is the current line
                        .frame(minWidth: 2, idealWidth: 2, maxWidth: 2, minHeight: 140, idealHeight: 215, maxHeight: 245, alignment: .center)
                        .foregroundColor(Color(.headingIndicator))
                })
                .offset(x: 100, y: 55)
            }
        })
        .clipped()
    }
}

#Preview {
    HeadingNavigationView(controllingWayPoint:  .constant(Core.services.navEngine.loadWayPoints().first!), gpsIsActive: .constant(true))
}
