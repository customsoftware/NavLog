//
//  AirportParser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import Foundation
import Combine
import CoreLocation

class AirportParser: ObservableObject {
    @Published var runways: [Runway] = []
    @Published var airports: [AirportData] = []
    @Published var chosenAirport: AirportData = AirportData(name: "", iata: "", runways: [])
    
    private var cancellable = Set<AnyCancellable>()
    
    let baseQueryString: String = "https://aviationweather.gov/api/data/airport?ids=<<airportString>>&format=json"
    private let baseGeoQueryString: String = "https://aviationweather.gov/api/data/airport?bbox=<<geoString>>&format=json"
    private let baseBoxString: String = "40.04,-111.,40.4,-111.2"
    private let airportGeoBoxSpaceHolder: String = "<<geoString>>"
    
    @MainActor
    func fetchAirportData(for airport: String) async throws {
        // Reset the runway data
        self.runways = []
        
        let fixedAirport = AirportComposer.fixAirportCode(airport)
        
        let airportQueryString = baseQueryString.replacingOccurrences(of: ParseTestData.airportSpaceHolder, with: fixedAirport)
        
        guard let url = URL(string: airportQueryString) else { throw HTTPError.badURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            var resultString = String(data: data, encoding: .utf8)!
            resultString.removeFirst()
            resultString.removeLast()
            
            let modifiedData = resultString.data(using: .utf8)
            var airportData = try JSONDecoder().decode(AirportData.self, from: modifiedData!)
            airportData.setRunways()
            
            runways = airportData.runways
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    @MainActor
    func fetchNearbyAirports(for location: CLLocation, closeIn: Bool) async throws {
        airports.removeAll()
        // How big a radius around the airport?
        let bracketBox: String = buildBracketBox(using: location, closeIn: closeIn)
        let bracketQuery: String = baseGeoQueryString.replacingOccurrences(of: airportGeoBoxSpaceHolder, with: bracketBox)
        
        // Query the API
        guard let url = URL(string: bracketQuery) else { throw HTTPError.badURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            var airportList = try JSONDecoder().decode( [AirportData].self, from: data)
            airportList = airportList.filter({ anAirport in
                anAirport.name != "-"
            })
            
            airports = airportList
            if airports.count == 0,
               closeIn == true {
                try await fetchNearbyAirports(for: location, closeIn: false)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
   }
    
    
    private func buildBracketBox(using location: CLLocation, closeIn: Bool = true ) -> String {
        var retValue = ""
        let latRounded = round(location.coordinate.latitude * 100)/100
        let longRounded = round(location.coordinate.longitude * 100)/100
        if closeIn {
            retValue = "\(latRounded - 0.125),\(longRounded - 0.125),\(latRounded + 0.125),\(longRounded + 0.125)"
        } else {
            retValue = "\(latRounded - 0.5),\(longRounded - 0.5),\(latRounded + 0.5),\(longRounded + 0.5)"
        }
        return retValue
    }
}
