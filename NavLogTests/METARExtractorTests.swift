//
//  METARExtractorTests.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 1/5/24.
//

import XCTest
@testable import NavLog

final class METARExtractorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testComplexMultiAirport() async throws {
        let complexParser = ComplexMetarParser()
        let airports: [String] = ["KPVU", "KLAX", "KCDC"]
//        let gotten = try await complexParser.fetchWeatherData(for: airports)
//        XCTAssertTrue(gotten.count == 3,"There should've been three airports. We got: \(gotten.count)")
//        gotten.forEach { airport in
//            print("Airport: \(airport.icaoId), Wind: \(airport.wind)")
//        }
    }
    
    
    func testComplexSingleAirport() async throws {
        let complexParser = ComplexMetarParser()
        let airports: [String] = ["KPVU"]
//        let gotten = try await complexParser.fetchWeatherData(for: airports)
//        XCTAssertTrue(gotten.count == 1,"There should be just one airport. We got: \(gotten.count)")
//        guard let pvu = gotten.first else {
//            XCTFail("We should have gotten an airport")
//            return
//        }
//        print(pvu.icaoId)
    }
}
