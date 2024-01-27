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
    @StateObject private var metrics = AppMetricsSwift.settings
    @StateObject private var aircraft = AircraftPerformance.shared
    
    @Binding var waypoint: WayPoint
    private let fieldWidth: CGFloat = 160.0
    
    var body: some View {
        Form {
            Toggle(isOn: $waypoint.isCompleted, label: {
                Text("Is Completed")
            })
            Section(header: Text("General Parameters")) {
                TextEntryFieldStringView(captionText: "Name", textWidth: fieldWidth, promptText: "Name of waypoint", isBold: true, textValue: $waypoint.name)
                TextEntryIntFieldView(formatter: formatter, captionText: "Altitude: (" + metrics.altitudeMode.text + ")", textWidth: fieldWidth, promptText: "Altitude", isBold: true, textValue: $waypoint.altitude)
                TextEntryIntFieldView(formatter: formatter, captionText: "Ground Speed: " + metrics.speedMode.modeSymbol, textWidth: fieldWidth, promptText: "Ground Speed", isBold: false, textValue: $waypoint.estimatedGroundSpeed)
                TextEntryFieldView(formatter: formatter, captionText: "Distance: " + metrics.distanceMode.modeSymbol, textWidth: fieldWidth, promptText: "Distance to next waypoint", isBold: false, integerOnly: false, textValue: $waypoint.estimatedDistanceToNextWaypoint)
                Text("Estimated Travel Time: \(Int(waypoint.computeTimeToWaypoint())) seconds")
                Text("Trip Performance Regime")
                Picker("Mode", selection: $waypoint.operationMode) {
                    Text("Climbing").tag(OperationMode.climb)
                    Text("Cruising").tag(OperationMode.cruise)
                    Text("Descending").tag(OperationMode.descend)
                }
                .pickerStyle(.segmented)
                Text("Estimated fuel burn: \(waypoint.estimatedFuelBurn(acData: aircraft), specifier: "%.1f") \(metrics.fuelMode.text)")
            }
            Section(header: Text("Wind")) {
                TextEntryFieldView(formatter: formatter, captionText: "Wind", textWidth: fieldWidth, promptText: "Direction", isBold: true, integerOnly: false, testValue: nil, textValue: $waypoint.wind.directionFrom)
                TextEntryFieldView(formatter: formatter, captionText: "Speed: " + metrics.speedMode.modeSymbol, textWidth: fieldWidth, promptText: "Speed", isBold: false, integerOnly: false, testValue: nil, textValue: $waypoint.wind.speed)
            }
            Section(header: Text("Course")) {
                TextEntryFieldView(formatter: formatter, captionText: "Magnetic", textWidth: fieldWidth, promptText: "Deviation", isBold: true, integerOnly: false, testValue: nil, textValue: $waypoint.magneticDeviation)
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
        .toolbar(content: {
            Button("Previous") {
                // DO something
            }
            Button("Next") {
                // DO something
            }
        })
        .onAppear(perform: {
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125))
            
            activePin = MapPins(coordinate: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude))
            pins = [activePin]
        })
    }
}

#Preview {
    WayPointDetailSwiftUIView(waypoint: .constant(WayPoint(name: "Test", latitude: 44.25, longitude: -112.012, altitude: 1500, wind: Wind(speed: 5, directionFrom: 115), courseFrom: 315, estimatedDistanceToNextWaypoint: 2.75, estimatedGroundSpeed: 85, estimatedTimeReached: 85, computedFuelBurnToNextWayPoint: 2.5)))
}



