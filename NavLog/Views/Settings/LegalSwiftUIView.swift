//
//  LegalSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/24/23.
//

import SwiftUI

struct LegalSwiftUIView: View {
    var body: some View {
        Text("Use of this software is AS-IS only. Use at your own risk. The developer of the software makes no warranties as to the accuracy of the information herein presented.")
            .padding()
            .navigationTitle("Legalese")
        Spacer()
    }
}

#Preview {
    LegalSwiftUIView()
}
