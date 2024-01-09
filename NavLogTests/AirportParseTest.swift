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
        XCTAssertTrue(runways.count == 2, "PVU just has two runways. Not \(runways.count)")
    }
    
    func testParseRunway() throws {
        guard let runwayData = runwayTest.data(using: .utf8) else {
            XCTFail("JSON didn't build")
            return
        }
        do {
            let aRunway = try JSONDecoder().decode(Runway.self, from: runwayData)
            XCTAssertNotNil(aRunway, "You should have a runway")
            XCTAssertTrue(aRunway.alignment == "192", "The alignment should be '192', it's \(aRunway.alignment)")
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    let runwayTest: String =
    """
    {"id":"18\\/36","dimension":"6628x150","surface":"A","alignment":"192"}
    """;
}


// {"id":"13\/31","dimension":"8603x150","surface":"A","alignment":"146"}
