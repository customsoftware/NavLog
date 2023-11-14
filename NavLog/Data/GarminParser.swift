//
//  GarminParser.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/14/23.
//  https://blog.logrocket.com/xml-parsing-swift/
//  https://codebeautify.org/xmlviewer


import Foundation

class GarminParser: NSObject, ParserProtocol {
    
    var useResults: (NavLogXML) -> Void
    
    var navLog: NavLogXML = NavLogXML(title: "", nameSpace: "")
    var routeNameEncountered = false
    var routePoint = 0
    var routeIndex = 0
    
    var lastSeenName = ""
    var navPoint: NavigationPoint?
    
    init(useTheseResults: @escaping (NavLogXML) -> Void) {
        useResults = useTheseResults
        super.init()
    }
    
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
                navPoint = NavigationPoint(name: string, latitude: 0, longitude: 0)
            }
        } else if var navP = navPoint,
                  routePoint > 0,
                  (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") ,
                  !string.contains("false") {
            
            if lastSeenName == "lat" {
                navPoint?.latitude = (string as NSString).doubleValue
            } else if lastSeenName == "lon" {
                navPoint?.longitude = (string as NSString).doubleValue
            } else if lastSeenName == "type" {
                navPoint?.pointType = string
            } else if lastSeenName == "elevation" {
                navP.elevation = (string as NSString).doubleValue
                navP.id = routeIndex
                routeIndex += 1
                navLog.navPoints.append(navP)
                navPoint = nil
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        useResults(navLog)
    }
}
