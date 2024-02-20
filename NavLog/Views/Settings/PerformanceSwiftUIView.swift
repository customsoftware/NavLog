//
//  PerformanceSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 12/4/23.
//

import SwiftUI

struct PerformanceSwiftUIView: View {
    
    @StateObject private var vm: PerformanceViewModel = PerformanceViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PerformanceSwiftUIView()
}

class PerformanceViewModel: ObservableObject {
    
}
