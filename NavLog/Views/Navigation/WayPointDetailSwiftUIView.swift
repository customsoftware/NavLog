//
//  WayPointDetailSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/22/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct WayPointDetailSwiftUIView: View {
    private let formatter: NumberFormatter = NumberFormatter()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    @State private var pins: [MapPins] = []
    @State private var activePin: MapPins = MapPins(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @Binding var waypoint: WayPoint
    private let fieldWidth: CGFloat = 90.0
    
    var body: some View {
        List {
            TextEntryFieldStringView(captionText: "Name", textWidth: fieldWidth, promptText: "Name of waypoint", isBold: true, textValue: $waypoint.name)
            TextEntryIntFieldView(formatter: formatter, captionText: "Altitude", textWidth: fieldWidth, promptText: "Altitude", isBold: true, testValue: nil, textValue: $waypoint.altitude)
            TextEntryFieldView(formatter: formatter, captionText: "Time", textWidth: fieldWidth, promptText: "Time to next waypoint", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.estimatedTimeReached)
            TextEntryFieldView(formatter: formatter, captionText: "Distance", textWidth: fieldWidth, promptText: "Distance to next waypoint", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.distanceToNextWaypoint)
            TextEntryFieldView(formatter: formatter, captionText: "Fuel", textWidth: fieldWidth, promptText: "Fuel to next waypoint", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.computedFuelBurnToNextWayPoint)
            Toggle(isOn: $waypoint.isCompleted, label: {
                Text("Is Completed")
            })
            HStack {
                TextEntryFieldView(formatter: formatter, captionText: "Wind", textWidth: fieldWidth/2, promptText: "Direction", isBold: true, integerOnly: false, testValue: nil, textValue: $waypoint.wind.directionFrom)
                TextEntryFieldView(formatter: formatter, captionText: "Speed", textWidth: fieldWidth/1.5, promptText: "Speed", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.wind.speed)
            }
            HStack {
                TextEntryFieldView(formatter: formatter, captionText: "Mag", textWidth: fieldWidth/2, promptText: "Deviation", isBold: true, testValue: nil, textValue: $waypoint.magneticDeviation)
                TextEntryIntFieldView(formatter: formatter, captionText: "CRS", textWidth: fieldWidth/1.5, promptText: "Course", isBold: false, testValue: nil, textValue: $waypoint.courseFrom)
            }
            Divider()
            HStack {
                Text("Lat")
                Text("\(waypoint.location.coordinate.latitude)")
                Spacer()
                Text("Long")
                Text("\(waypoint.location.coordinate.longitude)")
            }
            Map(coordinateRegion: $region,
                interactionModes: .zoom,
                showsUserLocation: false,
                userTrackingMode: .none,
                annotationItems: pins,
                annotationContent: { pin in
                MapPin(coordinate: pin.coordinate, tint: .red)
            })
            .frame(width: 320, height: 220)
        }
        .onAppear(perform: {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125))
            
            activePin = MapPins(coordinate: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude))
            pins = [activePin]
        })
    }
}

#Preview {
    WayPointDetailSwiftUIView(waypoint: .constant(WayPoint(name: "Test", location: CLLocation(latitude: 44, longitude: -112), altitude: 1500, wind: Wind(speed: 5, directionFrom: 115), courseFrom: 315, estimatedDistanceToNextWaypoint: 2.75, estimatedGroundSpeed: 65, estimatedTimeReached: 85, computedFuelBurnToNextWayPoint: 2.5)))
}



