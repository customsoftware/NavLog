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
                .clearButton(text: $textValue)
        }
    }
}

#Preview {
    TextEntryFieldStringView(captionText: "Test", textWidth: 180.0, promptText: "Prompt", textValue: .constant("Test Value"))
}


fileprivate
struct ClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        
        ZStack (alignment: .trailingFirstTextBaseline) {
            content
            if !text.isEmpty {
                Button {
                    text = ""
                }
            label: {
                Image(systemName: "multiply.circle")
                    .foregroundColor(.gray)
            }
            }
        }
    }
}

fileprivate
extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(ClearButton(text: text))
    }
}
