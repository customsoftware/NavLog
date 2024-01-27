//
//  AircraftManager.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/16/24.
//

import Foundation
import OSLog

@Observable
class AircraftManager {
    var chosenAircraft: MomentDatum {
        didSet {
            guard !isRetrievingAc else { return }
            saveChosenAircraft(chosenAircraft)
        }
    }
    private var isRetrievingAc: Bool = false
    var isAdding: Bool = false
    private let aircraftFileName: String = "chosenACName"
    private let aircraftFileExtension: String = "mmt"
    private (set) var availableAircraft: [MomentDatum] = []
    private let airplaneDirectory: URL
    private let fileManager = FileManager.default
    private (set) var listOfAircraft: [URL]?
    
    init() {
        chosenAircraft = MomentDatum(from: "NoName")
        do {
            airplaneDirectory = URL.documentsDirectory
            listOfAircraft = try fileManager.contentsOfDirectory(at: airplaneDirectory, includingPropertiesForKeys: nil)
     
            guard listOfAircraft?.count ?? 0 > 0 else {
                // If in test mode then load test aircraft
#if DEBUG
                fetchTestAircraft()
#endif
                return
            }
            listOfAircraft?.forEach { aFileUrl in
                do {
                    // Read the file from the directory then create the airplane and add it to the availableAircraft list
                    let acData = try Data(contentsOf: aFileUrl)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase
                    let aMomentObect = try decoder.decode(MomentDatum.self, from: acData)
                    availableAircraft.append(aMomentObect)
                } catch {
                    print("DO something")
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// This saves the chosen aircraft to UserDefaults
    private func saveChosenAircraft(_ aircraft: MomentDatum) {
        do {
            let acData = try JSONEncoder().encode(aircraft)
            try JSONArchiver().write(data: acData, to: aircraftFileName, with: aircraftFileExtension)
        } catch let error {
            Logger.api.info("Failed to archive selected aircraft: \(error.localizedDescription)")
        }
    }
    
    /// This retrieves chosen aircraft from user Defaults
    func retrieveChosenAircraft()  {
        var retValue: MomentDatum?
        do {
            guard let acData = try JSONArchiver().read(from: aircraftFileName, with: aircraftFileExtension) else {
                return
            }
            retValue = try JSONDecoder().decode(MomentDatum.self, from: acData)
        } catch let error {
            Logger.api.info("Failed to retrieve archived aircraft: \(error.localizedDescription)")
        }
        
        guard let ac = retValue else { return }
        isRetrievingAc = true
        chosenAircraft = ac
        isRetrievingAc = false
    }
    
    
    func importMomentData(using url: URL) throws {
        do {
            let acData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let aMomentObject = try decoder.decode(MomentDatum.self, from: acData)
            
            // Now we validate the model to see if we should import it
            let matchingAC = availableAircraft.first { aMoment in
                aMoment.aircraft == aMomentObject.aircraft
            }
            
            defer {
                try! fileManager.removeItem(at: url)
            }
            guard let _ = matchingAC else {
                availableAircraft.append(aMomentObject)
                return }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchTestAircraft(){
        availableAircraft.removeAll()
        availableAircraft.append(MomentDatum(from: "CardinalMoment"))
        availableAircraft.append(MomentDatum(from: "KatanaMoment"))
        availableAircraft.append(MomentDatum(from: "Cherokee140Moment"))
        availableAircraft.append(MomentDatum(from: "DA40 Moment"))
    }
    
    func saveCurrentAircraft() {
        // If the aircraft named file exists in the documents directory go ahead and save it
        // If it doesn't then create the file and the aircraft and add the aircraft to the availableAircraft list
        do {
            let acData = try JSONEncoder().encode(_chosenAircraft)
            let fileName = _chosenAircraft.aircraft
            let fileExtension = "data"
            let fileURL = airplaneDirectory.appending(path: fileName + "." + fileExtension)
            try acData.write(to: fileURL, options: [.atomic, .completeFileProtection])
            
            // Now update the array of aircraft
            let index = availableAircraft.firstIndex { anAC in
                anAC.id == chosenAircraft.id
            }
            if let idx = index {
                availableAircraft[idx] = chosenAircraft
            }
            
        } catch let error {
            print("Save failed: \(error.localizedDescription)")
        }
    }
}


// weights are in pounds
// arm is inches from datum
// aircraft arm is different it is moment-arm

enum ImportErrors: Error {
    case badURL
}
