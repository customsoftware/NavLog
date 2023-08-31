//
//  AircraftMetaDataView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

import SwiftUI

struct AircraftMetaDataView: View {
    @State var metaItems = AircraftMetaDataView.metaDataItems()
    
    var body: some View {
        List {
            
        }
    }
    
    
    private static func metaDataItems() -> [String] {
        var retValue: [String] = []
        retValue.append("Aircraft")
        retValue.append("Registration Number")
        retValue.append("Aircraft Type")
        retValue.append("Vso")
        retValue.append("Vy")
        retValue.append("Vcruise")
        retValue.append("Fuel Capacity")
        retValue.append("Standard Climb: 'fpm'")
        retValue.append("Standard Descent: 'fpm'")
        retValue.append("Climbing Fuel burn 'gph'")
        retValue.append("Cruising Fuel burn 'gph'")
        retValue.append("Descending Fuel burn 'gph'")
        return retValue
    }
}



#Preview {
    AircraftMetaDataView()
}
