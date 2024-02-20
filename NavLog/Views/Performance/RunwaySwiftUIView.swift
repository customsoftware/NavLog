//
//  RunwaySwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/13/24.
//

import SwiftUI

struct RunwaySwiftUIView: View {
    var runway: Runway
    @Binding var isActive: Bool
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Runway")
                    .bold(isActive)
                Text(runway.id)
            }
            VStack (alignment: .leading) {
                Text("Size")
                    .bold(isActive)
                Text(runway.dimension)
            }
            .frame(width: 120)
            VStack (alignment: .leading) {
                Toggle("Active", isOn: $isActive)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    RunwaySwiftUIView(runway: Runway(id: "13/31", dimension: "8000x150", surface: "A", alignment: "145"), isActive: .constant(true))
}
