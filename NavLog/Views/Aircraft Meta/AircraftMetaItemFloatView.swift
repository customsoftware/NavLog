//
//  AircraftMetaItemFloatView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import SwiftUI

struct AircraftMetaItemFloatView: View {
    
    @Binding var metaItem: MetaFloat
    
    private let numberFormatter = NumberFormatter()
    
    var body: some View {
        
        HStack {
            Spacer(minLength: 15)
            Text(metaItem.name).bold()
            Spacer(minLength: 20)
//            TextField(metaItem.name, text: $metaItem.value)
            Spacer()
        }
    }
    
    func convertFloatToString(_ floatValue: Float) -> String {
        let retValue: String = "\(floatValue)"
        return retValue
    }
    
}

#Preview {
    @State var metaData1 = MetaFloat(name: "Test", value: 2.5)
    @State var metaData2 = MetaFloat(name: "Alternate Test", value: 500)
    
    return Group {
        AircraftMetaItemFloatView(metaItem: .constant(metaData1))
        AircraftMetaItemFloatView(metaItem: .constant(metaData2))
    }
}
