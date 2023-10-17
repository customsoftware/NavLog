//
//  ParserTesting.swift
//  NavLogTests
//
//  Created by Kenneth Cluff on 10/14/23.
//

import XCTest
@testable import NavLog


final class ParserTesting: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGarmin() throws {
        let garminParser = getParser(.garmin) { navLog in
        }
        XCTAssertNotNil(garminParser, "We should have gotten a nav log")
    }
    
    func testDynon() throws {
        let dynonParser = getParser(.dynon) { navLog in
        }
        XCTAssertNotNil(dynonParser, "We should have gotten a nav log")
    }
    
    func testParsingDynon() throws {
        let dynonData = Data(dynonContent.utf8)
        let dynonParser = getParser(.dynon) { navLog in
            // Here is where we see what we got
            XCTAssertNotNil(navLog, "We should have gotten a nav log")
            XCTAssertTrue(navLog.navPoints.count == 10, "We should have gotten 10 Objects. We got \(navLog.navPoints.count) objects")
            
            XCTAssertTrue(navLog.nameSpace == "https://www.topografix.com/GPX/1/1", "The title should be 'https://www.topografix.com/GPX/1/1', it is \(navLog.nameSpace)")
            XCTAssertTrue(navLog.title == "VORtoPSC", "The title should be 'VORtoPSC', it is \(navLog.title)")
        }
        dynonParser.parseData(dynonData)
    }
    
    
    func testParsingGarmin() throws {
        let garminData = Data(xmlGarminContent.utf8)
        let garminParser = getParser(.garmin) { navLog in
            // Here is where we see what we got
            XCTAssertNotNil(navLog, "We should have gotten a nav log")
            XCTAssertTrue(navLog.navPoints.count == 10, "We should have gotten 10 Objects. We got \(navLog.navPoints.count) objects")
            
            XCTAssertTrue(navLog.nameSpace == "http://www8.garmin.com/xmlschemas/FlightPlan/v1", "The title should be 'http://www8.garmin.com/xmlschemas/FlightPlan/v1', it is \(navLog.nameSpace)")
            XCTAssertTrue(navLog.title == "VORTOPSC", "The title should be 'VORTOPSC', it is \(navLog.title)")
      }
        garminParser.parseData(garminData)
    }

    
    func testParsingGarminDataPoints() throws {
        let garminData = Data(xmlGarminContent.utf8)
        let garminParser = getParser(.garmin) { navLog in
            // Here is where we see what we got
            XCTAssertNotNil(navLog, "We should have gotten a nav log")
            let dataPoint = navLog.navPoints.last
            XCTAssertNotNil(dataPoint, "There should be a data point")
            if let point = dataPoint {
                // Name
                XCTAssertTrue(point.name == "KPSC", "The name should be 'KPSC', it is \(point.name)")
                // Lat
                XCTAssertTrue(point.latitude == 46.26468, "The latitude should be 46.26468, it is \(point.latitude)")
                // Long
                XCTAssertTrue(point.longitude == -119.119, "The longitude should be -119.119, it is \(point.longitude)")
                // Altitude
                XCTAssertTrue(point.elevation == 2590.8, "The elevation should be 2590.8, it is \(point.elevation)")
                // Type
                XCTAssertTrue(point.pointType == "AIRPORT", "The type should be 'AIRPORT', it is \(point.pointType)")
            }
       }
        garminParser.parseData(garminData)
    }

    
    func testParsingDynonDataPoints() throws {
        let garminData = Data(dynonContent.utf8)
        let garminParser = getParser(.dynon) { navLog in
            // Here is where we see what we got
            XCTAssertNotNil(navLog, "We should have gotten a nav log")
            let dataPoint = navLog.navPoints.first
            XCTAssertNotNil(dataPoint, "There should be a data point")
            if let point = dataPoint {
                // Name
                XCTAssertTrue(point.name == "KPVU", "The name should be 'KPVU', it is \(point.name)")
                // Lat
                XCTAssertTrue(point.latitude == 40.21917, "The latitude should be 40.21917, it is \(point.latitude)")
                // Long
                XCTAssertTrue(point.longitude == -111.7234, "The longitude should be -111.7234, it is \(point.longitude)")
                // Altitude
                XCTAssertTrue(point.elevation == 0.0, "The elevation should be 0.0, it is \(point.elevation)")
                // Type
                XCTAssertTrue(point.pointType == "", "The type should be empty, it is \(point.pointType)")
            }
       }
        garminParser.parseData(garminData)
    }
    
    func testNavEngine() {
        let engine = NavigationEngine()
        engine.buildTestNavLog()
        XCTAssertNotNil(engine.activeLog, "We don't have a nav log")
    }
    
    func getParser(_ parserMode: ParseType, using handler:@escaping (NavLogXML) -> Void) -> ParserProtocol {
        return ParserFactory.getNavLogParser(parserMode, using: handler)
    }
    
    
    let xmlGarminContent =
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <flight-plan xmlns="http://www8.garmin.com/xmlschemas/FlightPlan/v1">
    <created>2023-10-13T11:10:20Z</created>
    <waypoint-table>
    <waypoint>
    <identifier>KPVU</identifier>
    <type>AIRPORT</type>
    <country-code>K2</country-code>
    <lat>40.21917</lat>
    <lon>-111.7234</lon>
    <comment></comment>
    <elevation>1370.686</elevation>
    </waypoint>
    <waypoint>
    <identifier>VPPTM</identifier>
    <type>INT</type>
    <country-code>K2</country-code>
    <lat>40.45694</lat>
    <lon>-111.9139</lon>
    <comment></comment>
    <elevation>1981.2</elevation>
    </waypoint>
    <waypoint>
    <identifier>VPSLC</identifier>
    <type>INT</type>
    <country-code>K2</country-code>
    <lat>40.76389</lat>
    <lon>-111.9142</lon>
    <comment></comment>
    <elevation>1981.2</elevation>
    </waypoint>
    <waypoint>
    <identifier>CRKIT</identifier>
    <type>INT</type>
    <country-code>K2</country-code>
    <lat>40.76549</lat>
    <lon>-112.1472</lon>
    <comment></comment>
    <elevation>1981.2</elevation>
    </waypoint>
    <waypoint>
    <identifier>SHEAR</identifier>
    <type>INT</type>
    <country-code>K2</country-code>
    <lat>41.96037</lat>
    <lon>-113.0442</lon>
    <comment></comment>
    <elevation>1981.2</elevation>
    </waypoint>
    <waypoint>
    <identifier>BYI</identifier>
    <type>VOR</type>
    <country-code>K1</country-code>
    <lat>42.58024</lat>
    <lon>-113.8659</lon>
    <comment></comment>
    <elevation>2590.8</elevation>
    </waypoint>
    <waypoint>
    <identifier>BOI</identifier>
    <type>VOR</type>
    <country-code>K1</country-code>
    <lat>43.55281</lat>
    <lon>-116.1921</lon>
    <comment></comment>
    <elevation>1981.2</elevation>
    </waypoint>
    <waypoint>
    <identifier>S75</identifier>
    <type>AIRPORT</type>
    <country-code>K1</country-code>
    <lat>44.09398</lat>
    <lon>-116.9031</lon>
    <comment></comment>
    <elevation>679.704</elevation>
    </waypoint>
    <waypoint>
    <identifier>BKE</identifier>
    <type>VOR</type>
    <country-code>K1</country-code>
    <lat>44.8406</lat>
    <lon>-117.8079</lon>
    <comment></comment>
    <elevation>2590.8</elevation>
    </waypoint>
    <waypoint>
    <identifier>KPSC</identifier>
    <type>AIRPORT</type>
    <country-code>K1</country-code>
    <lat>46.26468</lat>
    <lon>-119.119</lon>
    <comment></comment>
    <elevation>2590.8</elevation>
    </waypoint>
    </waypoint-table>
    <route>
    <route-name>VORTOPSC</route-name>
    <flight-plan-index>1</flight-plan-index>
    <route-point>
    <waypoint-identifier>KPVU</waypoint-identifier>
    <waypoint-type>AIRPORT</waypoint-type>
    <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>VPPTM</waypoint-identifier>
    <waypoint-type>INT</waypoint-type>
    <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>VPSLC</waypoint-identifier>
    <waypoint-type>INT</waypoint-type>
    <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>CRKIT</waypoint-identifier>
    <waypoint-type>INT</waypoint-type>
    <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>SHEAR</waypoint-identifier>
    <waypoint-type>INT</waypoint-type>
    <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>BYI</waypoint-identifier>
    <waypoint-type>VOR</waypoint-type>
    <waypoint-country-code>K1</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>BOI</waypoint-identifier>
    <waypoint-type>VOR</waypoint-type>
    <waypoint-country-code>K1</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>S75</waypoint-identifier>
    <waypoint-type>AIRPORT</waypoint-type>
    <waypoint-country-code>K1</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>BKE</waypoint-identifier>
    <waypoint-type>VOR</waypoint-type>
    <waypoint-country-code>K1</waypoint-country-code>
    </route-point>
    <route-point>
    <waypoint-identifier>KPSC</waypoint-identifier>
    <waypoint-type>AIRPORT</waypoint-type>
    <waypoint-country-code>K1</waypoint-country-code>
    </route-point>
    </route>
    </flight-plan>
    """;
    
    let dynonContent =
"""
<?xml version="1.0" encoding="UTF-8" ?>
<gpx xmlns="https://www.topografix.com/GPX/1/1" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" creator="FlyQ" version="1.1" xsi:schemaLocation="https://www.topografix.com/GPX/1/1 https://www.topografix.com/GPX/1/1/gpx.xsd">
<rte>
<name>VORtoPSC</name>
<rtept lat="40.21917" lon="-111.7234">
<name>KPVU</name>
<overfly>false</overfly>
</rtept>
<rtept lat="40.45694" lon="-111.9139">
<name>VPPTM-US</name>
<overfly>false</overfly>
</rtept>
<rtept lat="40.76389" lon="-111.9142">
<name>VPSLC-US</name>
<overfly>false</overfly>
</rtept>
<rtept lat="40.76549" lon="-112.1472">
<name>CRKIT-US</name>
<overfly>false</overfly>
</rtept>
<rtept lat="41.96037" lon="-113.0442">
<name>SHEAR-US</name>
<overfly>false</overfly>
</rtept>
<rtept lat="42.58024" lon="-113.8659">
<name>BYI</name>
<overfly>false</overfly>
</rtept>
<rtept lat="43.55281" lon="-116.1921">
<name>BOI</name>
<overfly>false</overfly>
</rtept>
<rtept lat="44.09398" lon="-116.9031">
<name>S75</name>
<overfly>false</overfly>
</rtept>
<rtept lat="44.8406" lon="-117.8079">
<name>BKE</name>
<overfly>false</overfly>
</rtept>
<rtept lat="46.26468" lon="-119.119">
<name>KPSC</name>
<overfly>false</overfly>
</rtept>
</rte>
</gpx>
""";
}
