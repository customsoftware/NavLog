//
//  AirportParseTest.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 1/8/24.
//

import XCTest
@testable import NavLog

final class AirportParseTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGettingAirportData() async throws {
        let aParser = AirportParser()
        let airports: String = "KPVU"
        let _ = try await aParser.fetchAirportData(for: airports)
        let runways = aParser.runways
        XCTAssertNotNil(runways, "We should have gotten some runways")
        XCTAssertTrue(runways.count == 4, "PVU just has four runways. Not \(runways.count)")
    }
    
    func testParseAirport() throws {
        guard let airportData = airportTest.data(using: .utf8) else {
            XCTFail("JSON didn't build")
            return
        }
        do {
            var airportInformation = try JSONDecoder().decode(AirportData.self, from: airportData)
            XCTAssertNil(airportInformation.iataId)
            XCTAssertEqual(airportInformation.name, "AMERICAN FORK\\/AMERICAN FORK HOSPITAL ")
            
        } catch {
            print(airportData)
        }
    }
    
    func testParseRunway() throws {
        guard let runwayData = runwayTest.data(using: .utf8) else {
            XCTFail("JSON didn't build")
            return
        }
        do {
            let aRunway = try JSONDecoder().decode(Runway.self, from: runwayData)
            XCTAssertNotNil(aRunway, "You should have a runway")
            XCTAssertTrue(aRunway.alignment == 192, "The alignment should be '192', it's \(aRunway.alignment)")
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    let runwayTest: String =
    """
    {"id":"18\\/36","dimension":"6628x150","surface":"A","alignment":"192"}
    """;
    
    let airportTest: String =
    """
    {"id": "17481","icaoId": null,"iataId": null,"faaId": "UT56","name": "AMERICAN FORK\\/AMERICAN FORK HOSPITAL ","state": "UT","country": "US","source": "FAA","type": "HEL","lat": 40.3797,"lon": -111.769,"elev": 1403,"magdec": "14E","owner": "R","runways": [{"id": "H1","dimension": "85x65","surface": "A","alignment": 0}],"rwyNum": "1","rwyLength": "S","rwyType": "A","services": null,"tower": null,"beacon": null,"operations": "0","passengers": null,"freqs": "-","priority": "9"}
    """;
}


// {"id":"13\/31","dimension":"8603x150","surface":"A","alignment":"146"}
