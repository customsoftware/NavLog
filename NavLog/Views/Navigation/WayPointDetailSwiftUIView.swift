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
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    @State private var pins: [MapPins] = []
    @State private var activePin: MapPins = MapPins(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    @Binding var waypoint: WayPoint
    private let fieldWidth: CGFloat = 110.0
    
    var body: some View {
        Form {
            Section(header: Text("General Parameters")) {
                TextEntryFieldStringView(captionText: "Name", textWidth: fieldWidth, promptText: "Name of waypoint", isBold: true, textValue: $waypoint.name)
                TextEntryIntFieldView(formatter: formatter, captionText: "Altitude", textWidth: fieldWidth, promptText: "Altitude", isBold: true, textValue: $waypoint.altitude)
                TextEntryIntFieldView(formatter: formatter, captionText: "Ground Speed", textWidth: fieldWidth, promptText: "Ground Speed", isBold: false, textValue: $waypoint.estimatedGroundSpeed)
                TextEntryFieldView(formatter: formatter, captionText: "Distance", textWidth: fieldWidth, promptText: "Distance to next waypoint", isBold: false, integerOnly: false, textValue: $waypoint.estimatedDistanceToNextWaypoint)
                TextEntryFieldView(formatter: formatter, captionText: "Fuel", textWidth: fieldWidth, promptText: "Fuel to next waypoint", isBold: false, integerOnly: false, testValue: 30, textValue: $waypoint.computedFuelBurnToNextWayPoint)
                Toggle(isOn: $waypoint.isCompleted, label: {
                    Text("Is Completed")
                })
            }
            Section(header: Text("Wind")) {
                TextEntryFieldView(formatter: formatter, captionText: "Wind", textWidth: fieldWidth, promptText: "Direction", isBold: true, integerOnly: false, testValue: nil, textValue: $waypoint.wind.directionFrom)
                TextEntryFieldView(formatter: formatter, captionText: "Speed", textWidth: fieldWidth, promptText: "Speed", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.wind.speed)
            }
            Section(header: Text("Course")) {
                TextEntryFieldView(formatter: formatter, captionText: "Magnetic", textWidth: fieldWidth, promptText: "Deviation", isBold: true, testValue: nil, textValue: $waypoint.magneticDeviation)
                TextEntryIntFieldView(formatter: formatter, captionText: "Course", textWidth: fieldWidth, promptText: "Course", isBold: false, testValue: nil, textValue: $waypoint.courseFrom)
            }
            Section(header: Text("Map")) {
                HStack {
                    Text("Lat")
                    Text(formatter.string(from: waypoint.location.coordinate.latitude as NSNumber) ?? "")
                    Spacer()
                    Text("Long")
                    Text(formatter.string(from: waypoint.location.coordinate.longitude as NSNumber) ?? "")
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
        }
        .onAppear(perform: {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125))
            
            activePin = MapPins(coordinate: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude))
            pins = [activePin]
        })
    }
}

#Preview {
    WayPointDetailSwiftUIView(waypoint: .constant(WayPoint(name: "Test", location: CLLocation(latitude: 44.25, longitude: -112.012), altitude: 1500, wind: Wind(speed: 5, directionFrom: 115), courseFrom: 315, estimatedDistanceToNextWaypoint: 2.75, estimatedGroundSpeed: 65, estimatedTimeReached: 85, computedFuelBurnToNextWayPoint: 2.5)))
}



