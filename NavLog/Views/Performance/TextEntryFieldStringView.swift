//
//  TextEntryFieldStringView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import SwiftUI

struct TextEntryFieldStringView: View {
    var captionText: String
    var textWidth: CGFloat
    var promptText: String?
    var isBold: Bool = false
    @Binding var textValue: String {
        didSet {
            print("New value: \(textValue)")
        }
    }
    
    var body: some View {
        HStack {
            if isBold {
                Text(captionText)
                    .frame(width: textWidth, height: 30, alignment: .leading)
                    .bold()
            } else {
                Text(captionText)
                    .frame(width: textWidth, height: 30, alignment: .leading)
            }
            
            TextField(captionText, text: $textValue, prompt: Text(promptText ?? ""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

#Preview {
    TextEntryFieldStringView(captionText: "Test", textWidth: 180.0, promptText: "Prompt", textValue: .constant("Test Value"))
}
