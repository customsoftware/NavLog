//
//  ContentView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/23/23.
//

import SwiftUI
import MapKit
import CoreLocation

extension CLLocationCoordinate2D {
    static let startingPoint = CLLocationCoordinate2D(latitude: 40.2_231, longitude:  -111.7193)
}


struct ContentView: View {
    @State var region = MKCoordinateRegion(
        center: .init(latitude: 40.2_231,longitude: -111.7193),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    
    var body: some View {
        Map{
            Marker("My Plane", coordinate: .startingPoint)
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    
    private func startup() {
        let core = Core.services
        core.gpsEngine.configure()
    }
    
}

#Preview {
    ContentView()
}
