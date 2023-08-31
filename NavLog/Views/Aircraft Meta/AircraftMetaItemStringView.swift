//
//  AircraftMetaItemStringView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import SwiftUI

struct AircraftMetaItemStringView: View {
    
    @Binding var metaItem: MetaString
    
    var body: some View {
        HStack {
            Spacer(minLength: 15)
            Text(metaItem.name).bold()
            Spacer(minLength: 20)
            TextField(metaItem.name, text: $metaItem.value)
            Spacer()
        }
    }
}

#Preview {
    @State var metaData1 = MetaString(name: "Test", value: "Value")
    @State var metaData2 = MetaString(name: "Alternate Test", value: "Another Value")
    @State var metaData3 = MetaString(name: "Units", value: DistanceMode.standard.rawValue)
    
    return Group {
        AircraftMetaItemStringView(metaItem: .constant(metaData1))
        AircraftMetaItemStringView(metaItem: .constant(metaData2))
        AircraftMetaItemStringView(metaItem: .constant(metaData3))
    }
}
