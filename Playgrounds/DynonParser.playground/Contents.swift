import UIKit

let xmlContent =
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
}

class DynonParser: NSObject, XMLParserDelegate {
    
    var routePoint = 0
    var routeNameEncountered = false
    var routeSeen = false
    var latitude = ""
    var longitude = ""
    var locationName = ""
    var lastSeenName = ""
    var navLog: NavLog = NavLog(title: "", nameSpace: "")
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        switch elementName {
        case "gpx":
            navLog.nameSpace = namespaceURI ?? ""
        case "rte":
            lastSeenName = elementName
            routeSeen = true
        case "rtept":
            routeSeen = false
            routeNameEncountered = true
            if (attributeDict.index(forKey: "lat") != nil) {
                latitude = "\(attributeDict["lat"] ?? "")"
            }
            if (attributeDict.index(forKey: "lon") != nil) {
                longitude = "\(attributeDict["lon"] ?? "")"
            }
            routePoint += 1
            lastSeenName = elementName
        case "name":()
        case "overfly":()
        default:()
        }
    }
    
    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        if !routeNameEncountered, routeSeen, string.count > 1 {
            navLog.title = string.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if routeSeen {
            // Do nothing -- this is needed
        } else if routePoint == 0 {
            let aString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            navLog.title = aString
        } else if lastSeenName == "rtept",
           (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            let printString = "\(string) - Lat: \(latitude) Long: \(longitude)"
            if !printString.contains("false") {
                navLog.navPoints.append(NavigationPoint(name: string, latitude: latitude, longitude: longitude))
            }
        }
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Nav URI: \(navLog.nameSpace)")
        print("Nav Title: \(navLog.title)")
        for wayPoint in navLog.navPoints {
            print("Waypoint name: \(wayPoint.name) - Lat: \(wayPoint.latitude), Long: \(wayPoint.longitude)")
        }
    }
}

let parser2 = DynonParser()
let xmlParser2 = XMLParser(data: xmlData)
xmlParser2.delegate = parser2
xmlParser2.shouldProcessNamespaces = true
xmlParser2.parse()
