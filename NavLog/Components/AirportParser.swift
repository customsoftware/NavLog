//
//  AirportParser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import Foundation
import Combine

class AirportParser: ObservableObject {
    @Published var runways: [Runway] = []
    
    private var cancellable = Set<AnyCancellable>()
    
    let baseQueryString: String = "https://aviationweather.gov/api/data/airport?ids=<<airportString>>&format=json"
    
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
}
