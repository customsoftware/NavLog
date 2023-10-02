//
//  WaypointListItem.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/25/23.
//

//  This is the waypoint item used in the Mission Log and Navigation Log. It is read-only in the mission log.

import SwiftUI
import MapKit

struct WaypointListItem: View {
    
    @Binding var wayPoint: WayPoint
    
    let formatter = Formatter()
    
    var body: some View {
        
        VStack {
            HStack (alignment: .top, spacing: nil) {
                VStack(alignment: .leading) {
                    Text("Name")
                    Text(wayPoint.name)
                        .font(.headline)
                        .frame(width: 100)
                        
                    //                Text("Loc")
                    //                Map(coordinateRegion:
                    //                        .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: wayPoint.location.coordinate.latitude, longitude: wayPoint.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125))))
                    //                .frame(width: 75, height: 75, alignment: .center)
                }
                
                VStack(alignment: .leading, content: {
                    Text("ALT")
                    Text("\(wayPoint.altitude)")
                        .font(.headline)
                    Text("Wind")
                    Text("\(wayPoint.windPrintable())")
                        .font(.headline)
                })
                .frame(width: 85)
                VStack(content: {
                    Text("HDG")
                    Text("\(wayPoint.headingFrom)")
                        .font(.headline)
                    Text("CRS")
                    Text("\(wayPoint.courseFrom)")
                        .font(.headline)
                })
                Spacer()
            }
            .padding(.leading, 10)
            HStack {
                HStack {
                    Text("D")
                    Text(String(format: "%g", wayPoint.estimatedDistanceToNextWaypoint))
                        .font(.headline)
                    Text(wayPoint.shortDistanceMode())
                }
                HStack {
                    Text("T")
                    Text(wayPoint.estimateTime())
                        .font(.headline)
                }
                HStack {
                    Text("F")
                    Text(String(format: "%g", wayPoint.computedFuelBurnToNextWayPoint))
                        .font(.headline)
                    Text("gal")
                }
                Spacer()
            }
            .padding(.top, 5)
            .padding(.leading, 10)
            Spacer()
//            Divider().padding(.leading, 10)
        }
    }
    
    func generateCoordinateRegion(from aLocation: CLLocation) -> MKMapRect {
        return MKMapRect(origin: MKMapPoint(aLocation.coordinate), size: MKMapSize(width: 75, height: 75))
    }
    
    func generatePin(from aLocation: CLLocation) -> [APin] {
        return [APin(coordinate: aLocation.coordinate)]
    }
    
}

struct APin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    WaypointListItem(wayPoint: .constant(Core.services.navEngine.loadWayPoints()[0]))
}
