//
//  NavigationDetail.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/2/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct NavigationDetail: View {
    
    private let formatter: NumberFormatter = NumberFormatter()
    @State private var maxAltitude: Float = 12500
    @Binding var waypoint: WayPoint
    
    @State private var altitude: Float = 0.0
    @State private var course: String = ""
    @State private var heading: String = ""
    @State private var timeToNext: String = ""
    @State private var distanceToNext: String = ""
    @State private var fuelToNext: String = ""
    @State private var windSpeed: String = ""
    @State private var windDirection: String = ""
    @State private var latitude: String = ""
    {
       didSet {
           lat = formatter.number(from: latitude)?.doubleValue ?? 0
           print("Lat value changed to \(lat)")
       }
   }
    @State private var longitude: String = "" {
        didSet {
            long = formatter.number(from: longitude)?.doubleValue ?? 0
            print("Long value changed to \(long)")
        }
    }
    @State private var lat: Double = 0
    @State private var long: Double = 0
    
    @State private var waypointLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    @State private var pins: [MapPins] = []
    @State private var activePin: MapPins = MapPins(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text("Waypoint Name").italic()
                TextField("Waypoint Name", text: $waypoint.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Altitude").italic()
                Slider(value: $altitude, in: 0...maxAltitude, step: 100)
                    .padding()
                    .accentColor(Color.blue)
                    .border(Color.blue, width: 3)
                Text(self.formatter.string(from: (altitude as NSNumber))!)
                Divider()
                HStack(alignment: .top, spacing: nil) {
                    Text("Time").italic()
                    TextField("Time to next", text: $timeToNext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .top, spacing: nil) {
                    Text("Distance").italic()
                    TextField("Distance to next", text: $distanceToNext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .top, spacing: nil) {
                    Text("Fuel").italic()
                    TextField("Fuel to next", text: $fuelToNext)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text("Wind").italic()
                        TextField("Direction", text: $windDirection)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    })
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text("Speed").italic()
                        TextField("Speed", text: $windSpeed)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    })
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text("HDG").italic()
                        TextField("Heading", text: $heading)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    })
                    VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                        Text("CRS").italic()
                        TextField("Course", text: $course)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    })
                }
            })
            
//            Text("Location").italic()
            HStack(alignment: .top, spacing: nil) {
                Text("Latitude").italic()
                TextField("Latidute", text: $latitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack(alignment: .top, spacing: nil) {
                Text("Longitude").italic()
                TextField("Longitude", text: $longitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
//        .padding()
        .onAppear(perform: {
            loadViewControls(using: self.waypoint)
        })
        .onDisappear(perform: {
            
        })
        .onChange(of: waypoint) {
            loadViewControls(using: waypoint)
        }
    }
    
    func convertDoubleToString(_ doubleValue: Int) -> String {
        return formatter.string(from: NSNumber(value: doubleValue))!
    }
    func convertIntToString(_ intValue: Int) -> String {
        return formatter.string(from: NSNumber(value: intValue))!
    }
    
    private func loadViewControls(using wayPoint: WayPoint) {
        altitude = Float(waypoint.altitude)
        course = "\(waypoint.courseFrom)"
        heading = "\(waypoint.headingFrom())"
        waypointLocation = waypoint.location
        windSpeed = "\(waypoint.wind.speed)"
        distanceToNext = "\(wayPoint.estimatedDistanceToNextWaypoint)"
        windDirection = "\(waypoint.wind.directionFrom)"
        lat = waypoint.location.coordinate.latitude
        long = waypoint.location.coordinate.longitude
        latitude = "\(lat)"
        longitude = "\(long)"
        activePin = MapPins(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        pins = [activePin]
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125))
    }
    
    func computeClimb() {
        // This takes current altitude and altitude of the next waypoint. It then takes Vy value and computes time to altitude. Then it computes horizontal distance using ground speed.
        // It then creates a "climbing Waypoint and inserts it between the previous and active waypoint.
        // Once it is injected, the following waypoint is amended to account for this one's impact on distant traveled.
    }

    
    func computeDescent() {
        // This takes current altitude and altitude of the next waypoint. It then takes standard descent value and computes time to altitude. Then it computes horizontal distance using ground speed.
        // It then creates a "descending Waypoint and inserts it between the previous and active waypoint.
        // Once it is injected, the following waypoint is amended to account for this one's impact on distant traveled.
    }
}

struct MapPins: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

#Preview {
    NavigationDetail(waypoint: .constant(Core.services.navEngine.activeWayPoints.first!))
}
