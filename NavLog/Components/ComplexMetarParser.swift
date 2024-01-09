//
//  ComplexMetarParser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/8/24.
//

import Foundation
import Combine

class ComplexMetarParser: ObservableObject {
    @Published var weather: [AirportWeather] = []
    private var activeWeather: AirportWeather?
    private var cancellable = Set<AnyCancellable>()
    
    @MainActor
    func fetchWeatherData(for airports: [String]) async throws {
        // Reset the weather property
        self.weather = []
        
        // Compose the list of airports to query
        let airportList = composeAirportList(airports)
        guard airportList.isEmpty == false else { throw HTTPError.badURL }
        
        let reportTime = getTime()
        let queryString = ParseTestData.baseQueryString.replacingOccurrences(of: ParseTestData.airportSpaceHolder, with: airportList).replacingOccurrences(of: ParseTestData.zuluTimeSpaceHolder, with: reportTime)
        
        // Query the API
        guard let url = URL(string: queryString) else { throw HTTPError.badURL }
        
        var stringResults: String = ""
        
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            stringResults = String(decoding: data, as: UTF8.self)
            var metarResults = stringResults.components(separatedBy: "metar_id")
            metarResults.removeFirst()
            
            // Process the results - iterate through each airport's data.
            for aResult in metarResults {
                //  Decode the main one
                let parsable = repairJSONString(aResult)
                guard let modifiedData = parsable.data(using: .utf8) else { throw HTTPError.structure }
                
                do {
                    let interimData = try JSONDecoder().decode(InterimAirportWeather.self, from: modifiedData)
                    let windDirection = fetchWindDirection(modifiedData)
                    let windSpeed = fetchWindSpeed(modifiedData)
                    //  Compose the finished
                    let airportData = interimData.buildAirportWeather(withSpeed: windSpeed, andDirection: windDirection)
                    self.activeWeather = airportData
                    if let someWeather = self.activeWeather {
                        self.weather.append(someWeather)
                        self.activeWeather = nil
                    }
                } catch {
                    // Do something
                }
                // Go to the next airport
            }
        }
    }
    
    private func composeAirportList(_ list: [String]) -> String {
        var retValue: String = ""
        guard list.count > 0 else { return retValue }
        
        if list.count > 1 {
            let counterIndex = list.count - 1
            var index = 0
            
            list.forEach { anAirport in
                retValue = AirportComposer.fixAirportCode(anAirport)
                if index < counterIndex {
                    retValue = retValue + ","
                    index += 1
                }
            }
            
        } else {
            retValue = AirportComposer.fixAirportCode(list.first!)
        }
        
        return retValue
    }
    
    private func getTime() -> String {
        var retValue: String = ""
        //  We need to know what time it is in Zulu
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYYMMDD_HH0000"
        
        retValue = dateFormatter.string(from: now) + "Z"
        
        return retValue
    }
    
    private func repairJSONString(_ aResult: String) -> String {
        // We have an array of metar reports. Parse each one...
        var parsableResult = "[{metar_id" + aResult
        parsableResult = parsableResult.replacingOccurrences(of: "}]},{", with: "}]")
        
        // Strip out the array components
        parsableResult = parsableResult.replacingOccurrences(of: "[{m", with: "{\"m")
        parsableResult = parsableResult.replacingOccurrences(of: "}]\"", with: "}]}")
        parsableResult = parsableResult.replacingOccurrences(of: "}]}]", with: "}]}")
        
        return parsableResult
    }
    
    private func fetchWindDirection(_ jsonData: Data) -> VariableWindDirection? {
        var retValue: VariableWindDirection?
        do {
            let parsedInt = try JSONDecoder().decode(AiportWindDirectionInt.self, from: jsonData)
            retValue = parsedInt
        } catch {
            do {
                let parsedString = try JSONDecoder().decode(AiportWindDirectionString.self, from: jsonData)
                retValue = parsedString
            } catch {
                print("This error matters")
            }
        }
        return retValue
    }
    
    private func fetchWindSpeed(_ jsonData: Data) -> VariableWindSpeed? {
        var retValue: VariableWindSpeed?
        do {
            let parsedInt = try JSONDecoder().decode(AiportWindSpeedInt.self, from: jsonData)
            retValue = parsedInt
        } catch {
            do {
                let parsedString = try JSONDecoder().decode(AiportWindSpeedString.self, from: jsonData)
                retValue = parsedString
            } catch {
                print("This error matters")
            }
        }
        return retValue
    }
}


struct ParseTestData {
    static let baseQueryString: String = "https://aviationweather.gov/api/data/metar?ids=<<airportString>>&format=json&date=<<zuluDateString>>"
    static let airportSpaceHolder: String = "<<airportString>>"
    static let zuluTimeSpaceHolder: String = "<<zuluDateString>>"
    static let testSingleAirportString: String = "KPVU"
    static let testMultipleAirportString: String = "KPVU,KSLC,KFOM,KLAX,KTIX"
    static let testTimeString: String = "20240106_170000Z"
}

struct AirportComposer {
    static func fixAirportCode(_ code: String) -> String {
        var airport = code
        
        if airport.first?.uppercased() != "K",
           airport.count == 3 {
            airport = "K" + airport
        }
        
        return airport
    }
}
