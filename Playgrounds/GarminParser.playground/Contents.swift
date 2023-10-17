import UIKit

let xmlContent =
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

let xmlData = Data(xmlContent.utf8)

let xmlParser = XMLParser(data: xmlData)

struct NavLog {
    var title: String
    var nameSpace: String
    var navPoints : [NavigationPoint] = []
}

struct NavigationPoint {
    var name: String
    var latitude: String
    var longitude: String
    var pointType: String = ""
    var elevation: Double = 0
}

class GarminParser: NSObject, XMLParserDelegate {
    var parserNames: [String] = []
    var navLog: NavLog = NavLog(title: "", nameSpace: "")
    var routeNameEncountered = false
    var routePoint = 0
    var wayPointName = ""
    var lastSeenName = ""
    var navPoint: NavigationPoint?
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        
        routeNameEncountered = false
        lastSeenName = elementName
        switch elementName {
        case "flight-plan":
            navLog.nameSpace = namespaceURI ?? ""
        case "created":()
        case "waypoint-table":
            routePoint = 0
        case "waypoint":
            routePoint += 1
        case "identifier":()
        case "type":()
        case "country-code":()
        case "lat":()
        case "lon":()
        case "comment":()
        case "elevation":()
        case "route":()
        case "route-name":
            routeNameEncountered = true
        case "flight-plan-index":()
        case "route-point":()
        case "waypoint-identifier":()
        case "waypoint-type":()
        case "waypoint-country-code":()
        default:()
        }
    }
    
    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        if navLog.title.isEmpty, routeNameEncountered {
            navLog.title = string.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if routePoint > 0,
                  lastSeenName == "identifier",
                  (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            if !string.contains("false") {
                navPoint = NavigationPoint(name: string, latitude: "", longitude: "")
            }
        } else if var navP = navPoint,
                  routePoint > 0,
                  (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") ,
                  !string.contains("false") {
            
            if lastSeenName == "lat" {
                navPoint?.latitude = string
            } else if lastSeenName == "lon" {
                navPoint?.longitude = string
            } else if lastSeenName == "type" {
                navPoint?.pointType = string
            } else if lastSeenName == "elevation" {
                navP.elevation = Double(string) ?? 0.0
                navLog.navPoints.append(navP)
                navPoint = nil
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print ("Nav URI \(navLog.nameSpace)")
        print("Nav Title: \(navLog.title)")
        
        for navPoint in navLog.navPoints {
            let printString = String("Waypoint name: \(navPoint.name) - Lat: \(navPoint.latitude), Long: \(navPoint.longitude), Type: \(navPoint.pointType), Elevation: \(navPoint.elevation)")
            print(printString)
        }
    }
}


let garminParser = GarminParser()
xmlParser.delegate = garminParser
xmlParser.shouldProcessNamespaces = true
xmlParser.parse()
