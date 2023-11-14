//
//  DeviationEngine.swift
//  DeclinationLib
//
//  Created by Kenneth Cluff on 11/13/23.
//

import Foundation
import Combine


class DeviationFetchEngine: ObservableObject {
    static let shared = DeviationFetchEngine()
    
    private var cancellable = Set<AnyCancellable>()
    
    func getMagneticDeviationForLocation(atLat latitude: Double, andLong longitude: Double) -> Future<DeclinationResults, DeclinationError> {
        let queryString = buildQueryString(at: latitude, and: longitude)
        
        return Future { promise in
            guard let url = URL(string: queryString) else {
                return promise(.failure(.badURL(description: "Invalid location coordinates")))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .tryMap {(data, response) in
                    guard let aResponse = response as? HTTPURLResponse,
                          aResponse.statusCode >= 200,
                          aResponse.statusCode < 300 else {
                        if let aResponse = response as? HTTPURLResponse {
                            throw DeclinationError.networkError(description: "Invalid status code: \(aResponse.statusCode)")
                        } else {
                            throw DeclinationError.networkError(description: "Invalid response")
                        }
                    }
                    return data
                }
                .decode(type: DeclinationResults.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .finished:()
                    case .failure(let error):
                        if let decError = error as? DeclinationError {
                            return promise(.failure(decError))
                        } else {
                            return promise(.failure(.parsingError(description: "\(error.localizedDescription)")))
                        }
                    }
                    
                } receiveValue: { values in
                    return promise(.success(values))
                }
                .store(in: &self.cancellable)
        }
    }
    
    
    private func buildQueryString(at lat: Double, and long: Double) -> String {
        let declinationURI: String = "https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=LATITUDE&lon1=LONGITUDE&key=zNEw7&resultFormat=json"
        let lat = Int(lat)
        let long = long
        let queryString = declinationURI.replacing("LATITUDE", with: "\(lat)").replacing("LONGITUDE", with: "\(long)")
        return queryString
    }
}
