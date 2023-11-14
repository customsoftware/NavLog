//
//  TakeOffPerformanceView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct TakeOffPerformanceView: View {
    var results: PerformanceResults
    
    var body: some View {
        Text("Take off Performance")
    }
}

#Preview {
    TakeOffPerformanceView(results: PerformanceResults())
}
