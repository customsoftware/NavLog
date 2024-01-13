import SwiftUI
import Foundation
import Combine

// Runway struct
struct Runway: Codable {
    var id: String
    var dimension: String
    var surface: String
    var alignment: String
    
    var runwayLength: Int {
        let runwayComponents = dimension.components(separatedBy: "x")
        let retValue = (runwayComponents[0] as NSString).intValue
        return Int(retValue)
    }
    
    func getRunwayAxis() -> (Int, Int) {
        let axisComponents = id.components(separatedBy: "/")
        let axis1 = (axisComponents[0] as NSString).integerValue
        let axis2 = (axisComponents[1] as NSString).integerValue
        return (axis1, axis2)
    }
}

// AirportData struct
struct AirportData: Codable {
    var name: String?
    var iata: String
    var runways: [Runway]
    
    enum CodingKeys: String, CodingKey {
        case name = "id"
        case iata
        case runways
    }
}

// Airport error
enum AirPortError: Error, LocalizedError, CustomStringConvertible {
    case badURL(description: String)
    case networkError(description: String)
    case parsingError(description: String)
    case noError
    
    public var errorDescription: String? {
        let retValue: String
        switch self {
        case .badURL(description: let errorString):
            retValue = NSLocalizedString("Bad URL - \(errorString)", comment: "")
            
        case .networkError(description: let errorString):
            retValue = NSLocalizedString("Network - \(errorString)", comment: "")
            
        case .parsingError(description: let errorString):
            retValue = NSLocalizedString("Parsing - \(errorString)", comment: "")
            
        case .noError:
            retValue = "No error"
        }
        return retValue
    }

    public var description: String {
        let retValue: String
        switch self {
        case .badURL(description: let error):
            retValue = "Bad URL - \(error)"
            
        case .networkError(description: let error):
            retValue = "Network - \(error)"
            
        case .parsingError(description: let error):
            retValue = "Parsing - \(error)"
        
        case .noError:
            retValue = "No error"
        }
        return retValue
    }
}



class APIService {
    
    private let airportQueryString =
        """
        https://aviationweather.gov/api/data/airport?ids=KPUC&format=json
        """
    
    private var cancellable = Set<AnyCancellable>()
    
    func fetchAirportData() throws {
        guard let url = URL(string: airportQueryString) else {
            throw AirPortError.badURL(description: airportQueryString)
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap({ data, response in
                guard let aResponse = response as? HTTPURLResponse,
                      aResponse.statusCode >= 200,
                      aResponse.statusCode < 300 else {
                    if let aResponse = response as? HTTPURLResponse {
                        throw AirPortError.networkError(description: "Invalid status code: \(aResponse.statusCode)")
                    } else {
                        throw AirPortError.networkError(description: "Invalid response")
                    }
                }
                return data
            })
            .sink { completion in
                switch completion {
                case .finished:
                    print("It worked")
                case .failure(let error):
                    print("It failed")
                }
            } receiveValue: { values in
                return values
            }
            .decode(type: AirportData, decoder: JSONDecoder())
    }
}

class APIServiceViewModel: ObservableObject {
    
}

struct APIServiewView: View {
    
    @StateObject private var vm = APIServiceViewModel()
    
    var body: some View {
        Text("Hello, Ken")
    }
}
