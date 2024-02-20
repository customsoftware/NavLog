//
//  LegalSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/24/23.
//

import SwiftUI
import NavTool

struct LegalSwiftUIView: View {
    var body: some View {
        Text("Use of this software is AS-IS only. Use at your own risk. While the developer has worked to assure the accuracy of the presented data, the developer of the software makes no warranties as to the accuracy of the information herein presented.\n\nAs PIC of the aircraft, it is your responsibility to assure the aircraft is operated in a safe manner. This software product is offered only as a tool to assist in your decision process. The ultimate accuracy of the information you use is up to you.")
            .padding()
            .navigationTitle("Legalese")
        Spacer()
        Text("External Library: \(NavTool.shared.appName). Version: \(NavTool.shared.version)")
            .padding()
    }
}

#Preview {
    LegalSwiftUIView()
}
