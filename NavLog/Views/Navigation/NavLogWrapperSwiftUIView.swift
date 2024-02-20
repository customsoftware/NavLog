//
//  NavLogWrapperSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/22/24.
//

import SwiftUI

struct NavLogWrapperSwiftUIView: View {
    var body: some View {
        NavigationStack {
            NavigationLog()
        }
    }
}

#Preview {
    NavLogWrapperSwiftUIView()
}
