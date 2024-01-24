//
//  ImportNavLogView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/20/23.
//

import SwiftUI

struct ImportNavLogView: View {
    
    @State private var importing: Bool = false
    
    var body: some View {
        Text("This is where we import a file into our navLog")
            .fileImporter(
                isPresented: $importing,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let file):
                    do {
                        let testFile = file.startAccessingSecurityScopedResource()
//                        try aircraftManager.importMomentData(using: file)
                    } catch let error {
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}

#Preview {
    ImportNavLogView()
}
