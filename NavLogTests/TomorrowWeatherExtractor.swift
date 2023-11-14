//
//  TomorrowWeatherExtractor.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 10/27/23.
//

import XCTest

final class TomorrowWeatherExtractor: XCTestCase {

    let govTestURL = "https://api.weather.gov/points/39.7456,-97.0892"
    let testURL = "https://aviationweather.gov/api/data/windtemp?region=slc&level=low&fcst=06"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStarterExample() async throws {
        guard let url = URL(string: govTestURL) else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let resultString = String(data: data, encoding: .utf8)
        print(resultString)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
