//
//  ImportNavLogView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/20/23.
//

import SwiftUI
import OSLog


struct ImportNavLogView: View {
    
    @State private var importing: Bool = false
    @State private var isShowingError: Bool = false
    @Bindable private var navEngine = Core.services.navEngine
    
    var body: some View {
        VStack {
            Button("Import") {
                importing = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .fileImporter(
                isPresented: $importing,
                allowedContentTypes: [.xml]
            ) { result in
                switch result {
                case .success(let file):
                    let _ = file.startAccessingSecurityScopedResource()
                    importNavLog(at: file)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            if navEngine.importFinished {
                Text("Import is finished")
            }
            Spacer()
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(
                title: Text("Unsupport File Chosen"),
                message: Text("The file you chose must have either 'fpl' or 'gpx' file extension."),
                dismissButton: .default(Text("OK"))
            )
        })
        .navigationTitle("NavLog Import")
        .onDisappear(perform: {
            navEngine.importFinished = false
        })
    }
    
    private func importNavLog(at url: URL) {
        let isGarmin = url.lastPathComponent.hasSuffix("fpl")
        let isDynon = url.lastPathComponent.hasSuffix("gpx")
        
        if isGarmin {
            navEngine.importNavLog(doingGarmin: true, with: url)
        } else if isDynon {
            navEngine.importNavLog(doingGarmin: false, with: url)
        } else {
            isShowingError = true
        }
    }
}

#Preview {
    ImportNavLogView()
}
