//
//  ParserObjects.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/14/23.
//

import Foundation

struct NavLogXML {
    var title: String
    var nameSpace: String
    var navPoints : [NavigationPoint] = []
    
    func fuelRemaining() -> Double {
        return 0
    }
}

struct NavigationPoint {
    var name: String
    var latitude: Double
    var longitude: Double
    var pointType: String = ""
    var elevation: Double = 0
}

enum ParseType {
    case garmin
    case dynon
}


protocol ParserProtocol : XMLParserDelegate {
    var navLog: NavLogXML {
        get
    }
    
    var useResults: (_ results: NavLogXML) -> Void { get set }
    
    func parseData(_ xmlData: Data)
}


extension ParserProtocol {
    func parseData(_ xmlData: Data) {
        let xmlParser = XMLParser(data: xmlData)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()
    }
}
