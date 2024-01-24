//
//  JSONArchiver.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/24/24.
//

import Foundation
import OSLog

class JSONArchiver {
    
    private let airplaneDirectory = URL.documentsDirectory
   
    func read(from fileName: String, with fileExtension: String) throws -> Data? {
        var retData: Data?
        
        do {
            let fileURL = airplaneDirectory.appending(path: fileName + "." + fileExtension)
            retData = try Data(contentsOf: fileURL)
            
        } catch let error {
            Logger.api.critical("Read failed: \(error.localizedDescription)")
            throw FileReadWrite.read("Read failed: \(error.localizedDescription)")
        }
        
        return retData
    }
    
    
    func write(data: Data, to fileName: String, with fileExtension: String) throws {
        do {
            let fileURL = airplaneDirectory.appending(path: fileName + "." + fileExtension)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            
        } catch let error {
            Logger.api.critical("Save failed: \(error.localizedDescription)")
            throw FileReadWrite.write("Save failed: \(error.localizedDescription)")
       }
    }
}


enum FileReadWrite: Error {
    case read(String)
    case write(String)
}
