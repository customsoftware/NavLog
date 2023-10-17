//
//  DynonParser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/14/23.
//  https://blog.logrocket.com/xml-parsing-swift/
//  https://codebeautify.org/xmlviewer



import Foundation

class DynonParser: NSObject, ParserProtocol {
    
    var useResults: (NavLogXML) -> Void
    
    var navLog: NavLogXML = NavLogXML(title: "", nameSpace: "")
    var routeNameEncountered = false
    var routePoint = 0
    
    var lastSeenName = ""
    var routeSeen = false
    var latitude = 0.0
    var longitude = 0.0
    var locationName = ""
    
    init(useTheseResults: @escaping (NavLogXML) -> Void) {
        useResults = useTheseResults
        super.init()
    }
    
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
                let stringLat = attributeDict["lat"] ?? "0"
                latitude = (stringLat as NSString).doubleValue
            }
            if (attributeDict.index(forKey: "lon") != nil) {
                let stringLong = attributeDict["lon"] ?? "0"
                longitude = (stringLong as NSString).doubleValue
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
        useResults(navLog)
    }
}
