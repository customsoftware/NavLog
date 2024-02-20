//
//  FetchMagneticDeviation.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 10/30/23.
//

import XCTest

final class FetchMagneticDeviation: XCTestCase {

    struct DecData : Codable {
        var date: Double
        var elevation: Int
        var declination: Double
        var latitude: Int
        var declnation_sv: Double
        var declination_uncertainty: Double
        var longitude: Double
    }
    struct DecUnits: Codable {
        var elevation: String
        var declination: String
        var declination_sv: String
        var latitude: String
        var declination_uncertainty: String
        var longitude: String
    }
    struct DeclinationResults : Codable {
        var result : [DecData]
        var model: String
        var units: DecUnits
        var version: String
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDecResults() throws {
        let decResultsString = """
            {"date": 2023.8274, "elevation": 0, "declination": 10.71451, "latitude": 40, "declnation_sv": -0.09586, "declination_uncertainty": 0.37029, "longitude": -111.7234}
            """;
        let decResultData = Data(decResultsString.utf8)
        do {
            let results = try JSONDecoder().decode( DecData.self, from: decResultData)
            XCTAssertTrue(results.latitude == 40)
        } catch {
            XCTFail("JSON didn't parse: \(error.localizedDescription)")
        }
    }
        
    func testDecUnits() throws {
        let decUnitsString = """
            { "elevation": "km", "declination": "degrees", "declination_sv": "degrees", "latitude": "degrees", "declination_uncertainty": "degrees", "longitude": "degrees" }
            """;
        let decUnitData = Data(decUnitsString.utf8)
        do {
            let results = try JSONDecoder().decode( DecUnits.self, from: decUnitData)
            XCTAssertTrue(results.latitude == "degrees")
        } catch {
            XCTFail("JSON didn't parse: \(error.localizedDescription)")
        }
    }
        
    func testFullSet() async throws {
        let stringOne = "https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=40&lon1=-111.7234&key=zNEw7&resultFormat=json"
        guard let queryURL = URL(string: stringOne) else { return }
        let (data, _) = try await URLSession.shared.data(from: queryURL)
        do {
            let deviationResult = try JSONDecoder().decode(DeclinationResults.self, from: data)
            XCTAssertTrue(deviationResult.result.first?.declination == 10.68486, "Magnetice deviation reported as \(deviationResult.result.first?.declination) not 10.68486 which is what we expected.")
        } catch {
            XCTFail("JSON didn't parse: \(error.localizedDescription)")
        }
    }
}
