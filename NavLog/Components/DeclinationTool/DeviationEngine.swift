//
//  DeviationEngine.swift
//  DeclinationLib
//
//  Created by Kenneth Cluff on 11/13/23.
//

import Foundation
import Combine
import OSLog

class DeviationFetchEngine: ObservableObject {
    static let shared = DeviationFetchEngine()
    
    func getMagneticDeviationForLocation(atLat latitude: Double, andLong longitude: Double) async throws -> DeclinationResults? {
        let queryString = buildQueryString(at: latitude, and: longitude)
        var results: DeclinationResults?
        guard let url = URL(string: queryString) else {
            throw DeclinationError.badURL(description: "Invalid location coordinates")
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            results = try JSONDecoder().decode(DeclinationResults.self, from: data)
        } catch let error {
            Logger.api.warning("Decode failed: \(error.localizedDescription)")
        }
        //            URLSession.shared.dataTaskPublisher(for: url)
        //                .receive(on: DispatchQueue.main)
        //                .tryMap {(data, response) in
        //                    guard let aResponse = response as? HTTPURLResponse,
        //                          aResponse.statusCode >= 200,
        //                          aResponse.statusCode < 300 else {
        //                        if let aResponse = response as? HTTPURLResponse {
        //                            throw DeclinationError.networkError(description: "Invalid status code: \(aResponse.statusCode)")
        //                        } else {
        //                            throw DeclinationError.networkError(description: "Invalid response")
        //                        }
        //                    }
        //                    return data
        //                }
        //                .decode(type: DeclinationResults.self, decoder: JSONDecoder())
        //                .sink { completion in
        //                    switch completion {
        //                    case .finished:()
        //                    case .failure(let error):
        //                        if let decError = error as? DeclinationError {
        //                            throw decError
        //                        } else {
        //                            return promise(.failure(.parsingError(description: "\(error.localizedDescription)")))
        //                        }
        //                    }
        //
        //                } receiveValue: { values in
        //                    return promise(.success(values))
        //                }
        //                .store(in: &self.cancellable)
        return results
    }
    
    
    private func buildQueryString(at lat: Double, and long: Double) -> String {
        let declinationURI: String = "https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=LATITUDE&lon1=LONGITUDE&key=zNEw7&resultFormat=json"
        let lat = Int(lat)
        let long = long
        let queryString = declinationURI.replacing("LATITUDE", with: "\(lat)").replacing("LONGITUDE", with: "\(long)")
        return queryString
    }
}
