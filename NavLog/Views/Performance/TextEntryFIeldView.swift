//
//  TextEntryFIeldView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/14/23.
//

import SwiftUI

struct TextEntryFieldView: View {
    var formatter: NumberFormatter
    var captionText: String
    var textWidth: CGFloat
    var promptText: String
    var isBold: Bool = false
    var testValue: Double?
    @State private var isValid: Bool = true
    @Binding var textValue: Double
    
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
            TextField(promptText, value: $textValue, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numbersAndPunctuation)
                .foregroundColor(titleColor)
        }
        .onChange(of: textValue) { oldValue, newValue in
            guard newValue > 0 else { return }
            if let tValue = testValue {
                isValid = newValue <= tValue
            }
        }
    }
    
    
    private var titleColor: Color {
        guard isValid else {
            return .red
        }
        return Color.basicText
    }
}

#Preview {
    TextEntryFieldView(formatter: NumberFormatter(), captionText: "Test", textWidth: 180.0, promptText: "Prompt", testValue: 48, textValue: .constant(230.0))
}
