//
//  ParseEngine.swift
//  NavLog
//
//  Created by Kenneth Cluff on 10/14/23.
//

import Foundation

class ParserFactory {
    
    static func getNavLogParser(_ mode: ParseType, using handler:@escaping (NavLogXML) -> Void) -> ParserProtocol {
        var retValue: ParserProtocol
        switch mode {
        case .dynon:
            retValue = DynonParser(useTheseResults: handler)
        case .garmin:
            retValue = GarminParser(useTheseResults: handler)
        }
        
        return retValue
    }
}
