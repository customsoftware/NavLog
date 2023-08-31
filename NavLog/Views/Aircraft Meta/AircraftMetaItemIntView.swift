//
//  AircraftMetaItemIntView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import SwiftUI

struct AircraftMetaItemIntView: View {
    
    @Binding var metaItem: MetaInt
    
    var body: some View {
        HStack {
            Spacer(minLength: 15)
            Text(metaItem.name).bold()
            Spacer(minLength: 20)
//            TextField(metaItem.name, text: $metaItem.value)
            Spacer()
        }
    }
}

#Preview {
    @State var metaData1 = MetaInt(name: "Test", value: 340)
    @State var metaData2 = MetaInt(name: "Alternate Test", value: 0)
    
    return Group {
        AircraftMetaItemIntView(metaItem: .constant(metaData1))
        AircraftMetaItemIntView(metaItem: .constant(metaData2))
    }
}
