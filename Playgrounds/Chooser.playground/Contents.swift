import Foundation


var testXML: String =
"""
<?xml version="1.0" encoding="utf-8"?>
<flight-plan xmlns="http://www8.garmin.com/xmlschemas/FlightPlan/v1">
  <created>2024-01-25T19:24:05Z</created>
  <waypoint-table>
    <waypoint>
      <identifier>KPVU</identifier>
      <type>AIRPORT</type>
      <country-code>K2</country-code>
      <lat>40.219167</lat>
      <lon>-111.723361</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>PEDLE</identifier>
      <type>INT</type>
      <country-code>K2</country-code>
      <lat>40.474683</lat>
      <lon>-111.928328</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>VPSLC</identifier>
      <type>INT</type>
      <country-code>K2</country-code>
      <lat>40.763889</lat>
      <lon>-111.914167</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>CRKIT</identifier>
      <type>INT</type>
      <country-code>K2</country-code>
      <lat>40.765486</lat>
      <lon>-112.147172</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>SHEAR</identifier>
      <type>INT</type>
      <country-code>K2</country-code>
      <lat>41.960372</lat>
      <lon>-113.044178</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>KEUL</identifier>
      <type>AIRPORT</type>
      <country-code>K1</country-code>
      <lat>43.641850</lat>
      <lon>-116.635764</lon>
      <comment />
    </waypoint>
    <waypoint>
      <identifier>KPSC</identifier>
      <type>AIRPORT</type>
      <country-code>K1</country-code>
      <lat>46.264681</lat>
      <lon>-119.119025</lon>
      <comment />
    </waypoint>
  </waypoint-table>
  <route>
    <route-name>KPVU KPSC</route-name>
    <flight-plan-index>1</flight-plan-index>
    <route-point>
      <waypoint-identifier>KPVU</waypoint-identifier>
      <waypoint-type>AIRPORT</waypoint-type>
      <waypoint-country-code>K2</waypoint-country-code>
    </route-point>
    <route-point>
      <waypoint-identifier>PEDLE</waypoint-identifier>
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
      <waypoint-identifier>KEUL</waypoint-identifier>
      <waypoint-type>AIRPORT</waypoint-type>
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

let searchString = "<comment />"
let dummyReplaceString =
"""
<comment />
      <elevation>2590.8</elevation>
"""

if testXML.contains("<elevation") {
    print("It contains the segment")
} else {
    print("It doesn't contain the segment... fix!")
    testXML = testXML.replacingOccurrences(of: searchString, with: dummyReplaceString)
    print("This is the fixed string...")
    print(testXML)
}
