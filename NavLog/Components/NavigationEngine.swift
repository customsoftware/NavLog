//
//  NavigationEngine.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/31/23.
//  https://www.visualcrossing.com/weather-history/40.7128%2C-74.0060

import Foundation
import CoreLocation
import OSLog
import NavTool

@Observable
class NavigationEngine {
    private let searchString = "<comment />"
    private let fileName: String = "missionPlan"
    private let fileNameExtension: String = "mplan"
    private (set) var activeLog: NavLogXML?
    var activeWayPoints: [WayPoint] = []
    var importFinished = false
    private var doGarmin = true
    private let metersToFeetMultiple = 3.28084
    private let deviationEngine = DeviationFetchEngine()
    
    func runLog() {
        
    }
    
    func refreshNavLog() {
        fixIASforMetricsChange()
        fleshOutWayPoints()
        AppMetricsSwift.settings.pushCurrentToOld()
        AppMetricsSwift.settings.saveDefaults()
    }
    
    func saveLogToDisk() {
        do {
            let archiveData = try JSONEncoder().encode(activeWayPoints)
            try JSONArchiver().write(data: archiveData, to: fileName, with: fileNameExtension)
            Logger.api.info("Writing log to archive worked!!")
        } catch let error {
            Logger.api.warning("The write failed: \(error.localizedDescription)")
        }
    }
    
    func readWaypointsFromDisk() throws -> [WayPoint]? {
        var retValue: [WayPoint]?
        guard let data = try JSONArchiver().read(from: fileName, with: fileNameExtension) else { return retValue }
        do {
            retValue = try JSONDecoder().decode([WayPoint].self, from: data)
            Logger.api.info("Loading archived log into data worked!!")
        } catch let error {
            Logger.api.warning("Decoding log failed: \(error.localizedDescription)")
        }
        
        return retValue
    }
    
    func importNavLog(doingGarmin: Bool = true, with url: URL) {
        doGarmin = doingGarmin
        importFinished = false
        var parser: ParserProtocol
        
        if doGarmin {
            fixGarmin(at: url)
            parser = ParserFactory.getNavLogParser(.garmin) { [weak self] aLog in
                self?.activeLog = aLog
                var sequence = 0
                self?.activeWayPoints.removeAll()
                aLog.navPoints.forEach { navPoint in
                    self?.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
                
                self?.cleanupAfterImport(from: url)
            }
        } else {
            parser = ParserFactory.getNavLogParser(.dynon, using: { [weak self] aLog in
                self?.activeLog = aLog
                var sequence = 0
                self?.activeWayPoints.removeAll()
                aLog.navPoints.forEach { navPoint in
                    self?.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
                
                self?.cleanupAfterImport(from: url)
            })
        }
        
        let xmlData = try! Data(contentsOf: url)
        parser.parseData(xmlData)
    }
    
    func buildTestNavLog() {
        var parser: ParserProtocol
        let fileName: String
        let fileID: String
        if doGarmin {
            parser = ParserFactory.getNavLogParser(.garmin) { aLog in
                self.activeLog = aLog
                var sequence = 0
                aLog.navPoints.forEach { navPoint in
                    self.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
                
                self.fleshOutWayPoints()
            }
            fileName = "GarminPlan"
            fileID = "fpl"
        } else {
            
            parser = ParserFactory.getNavLogParser(.dynon, using: { aLog in
                self.activeLog = aLog
                var sequence = 0
                aLog.navPoints.forEach { navPoint in
                    self.loadIntoWayPoint(navPoint, sequence)
                    sequence += 1
                }
                
                self.fleshOutWayPoints()
            })
            fileName = "DynonPlan"
            fileID = "gpx"
        }
        guard let sourceFile = Bundle.main.path(forResource: fileName, ofType: fileID) else { return }
        if let xmlData = FileManager().contents(atPath: sourceFile) {
            parser.parseData(xmlData)
        }
    }
    
    func loadWayPoints() -> [WayPoint] {
        // We need the app to wait for this to finish
        return activeWayPoints
    }
    
    func computeCourseBetweeen(currentLocation: CLLocation, and destination: CLLocation) -> Double {
        let circle = 360.0
        var retValue: Double = 0.0
        let deltaLong = currentLocation.coordinate.longitude - destination.coordinate.longitude
        let y = sin(deltaLong) * cos(currentLocation.coordinate.latitude)
        let x = cos(destination.coordinate.latitude) * sin(currentLocation.coordinate.latitude) - sin(destination.coordinate.latitude) * cos(currentLocation.coordinate.latitude) * cos(deltaLong)
        let radValue = atan2(y, x)
        let degreeValue = NavTool.shared.convertToDegrees(radians: radValue)
        retValue = 360 - (degreeValue + circle).truncatingRemainder(dividingBy: circle)
        return retValue
    }
}

//let circle = 360.0
//var retValue: Double = 0.0
//let deltaLong = destination.coordinate.longitude - currentLocation.coordinate.longitude
//let y = sin(deltaLong) * cos(destination.coordinate.latitude)
//let x = cos(currentLocation.coordinate.latitude) * sin(destination.coordinate.latitude) - sin(currentLocation.coordinate.latitude) * cos(destination.coordinate.latitude) * cos(deltaLong)
//let radValue = atan2(y, x)
//let degreeValue = Core.services.radToDegrees(radValue)
//retValue = 360 - (degreeValue + circle).truncatingRemainder(dividingBy: circle)
//return retValue


fileprivate extension NavigationEngine {
    
    func fixGarmin(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if var importFile = String(data: data, encoding: .utf8) {
                importFile = importFile.replacingOccurrences(of: searchString, with: returnFixString())
                
                let updatedData = importFile.data(using: .utf8)
                try updatedData?.write(to: url, options: .atomic)
                
            }
        } catch let error {
            print("Replacing the file didn't work")
        }
    }
    
    func returnFixString() -> String {
        """
        <comment />
              <elevation>2590.8</elevation>
        """
    }
    
    func buildTestAircraft() -> Aircraft {
        var retValue : Aircraft = Aircraft(registration: "NCC-1701X", standardClimbRate: 700, standardDescentRate: 500, cruiseFuelBurnRate: 8.6, climbToAltitudeFuelBurnRate: 12.9, descendingFuelBurnRate: 4.4, stallSpeed: 54, climbSpeed: 90, cruiseSpeed: 110, descentSpeed: 110)
        return retValue
    }
    
    func getWeatherForWayPoints(latitude: Double, longitude: Double) async throws -> Wind {
        var retValue = Wind(speed: 0, directionFrom: 0)
        let weatherString = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/\(latitude),\(longitude)/today/?key=BNDMZR7VESR5SJXPF4CE5ALKK"
        guard let url = URL(string: weatherString) else { return retValue}
        var weatherData: Data?
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            weatherData = data
            let weatherReport = try JSONDecoder().decode(WeatherReport.self, from: data)
            retValue = Wind(speed: weatherReport.currentConditions.windspeed, directionFrom: weatherReport.currentConditions.winddir)
        } catch let error {
            if let wxData = weatherData,
               let weatherString = String(data: wxData, encoding: .utf8) {
                
                print("\(weatherString)")
            }
            Logger.api.error("Getting weather for waypoint failed: \(error.localizedDescription)")
        }
        return retValue
    }
    
    func cleanupAfterImport(from url: URL) {
        guard let aLog = activeLog,
              activeWayPoints.count > 0
        else { return }
        
        self.fleshOutWayPoints()
        
        if aLog.navPoints.count > 0,
           activeWayPoints.count == aLog.navPoints.count {
            
            removeFile(at: url)
            saveLogToDisk()
            importFinished = true
        }
    }
    
    func removeFile(at url: URL) {
        try! FileManager().removeItem(at: url)
    }
    
    func fleshOutWayPoints() {
        activeWayPoints = activeWayPoints.sorted(by: { w1, w2 in
            w1.sequence < w2.sequence
        })
        
        Task {
            do {
                try await activeWayPoints.asyncForEach { waypoint in
                    var aWayPoint = waypoint
                    
                    // The rule here is to determine course to waypoint b from waypoint a
                    let nextSequence : Int = aWayPoint.sequence + 1
                    let currentSequence: Int = aWayPoint.sequence
                    
                    // Get wind at location
                    let aLocation = aWayPoint.location
                    let wind = try await self.getWeatherForWayPoints(latitude: aLocation.coordinate.latitude, longitude: aLocation.coordinate.longitude)
                    aWayPoint.wind = wind
                    
                    // Compute deviation at current location
                    let deviation = try await DeviationFetchEngine.shared.getMagneticDeviationForLocation(atLat:aWayPoint.latitude, andLong: aWayPoint.longitude)
                    if let deviate = deviation?.result.first?.declination {
                        aWayPoint.magneticDeviation = -deviate
                    }
                    
                    
                    // Get the next location to compute heading and course
                    guard let nextWayPoint = self.activeWayPoints.first(where: { wp in
                        wp.sequence == nextSequence
                    }) else { return }
                    
                    // Get course from current to next
                    let results = aWayPoint.computeCourseToWayPoint(nextWayPoint)
                    aWayPoint.courseFrom = results.0
                    aWayPoint.estimatedDistanceToNextWaypoint = results.1
                    
                    
                    // Get ground speed. Use stored aircraft values.
                    // Compute time from take off to cruise altitude
                    // Compute time to descend from cruise to pattern at destination
                    // If total flight time is less than time to altitude, use climb speed.
                    // Compute distance flown to descend to pattern from cruise altitude divided by descent feet per minute
                    
                    //                try? self.activeWayPoints[currentSequence].getMagneticDeviationForLocation { result in
                    //
                    //                    self.activeWayPoints[currentSequence].magneticDeviation = result
                    //                    let doubleCourseFrom = Double(self.activeWayPoints[currentSequence].courseFrom)
                    //                    let modifiedCourseFrom = doubleCourseFrom - result
                    //                    let intCourseFrom = Int(modifiedCourseFrom)
                    //                    self.activeWayPoints[currentSequence].headingFrom = intCourseFrom
                    //                    print("Deviation complete: \(currentSequence), Course: \(self.activeWayPoints[currentSequence].courseFrom), Heading: \(self.activeWayPoints[currentSequence].headingFrom)")
                    //                }
                    //                aWayPoint.courseFrom = Int(courseFrom)
                    //                // -- Caveat to this is wind is surface wind. Still working to get wind at altitude
                    //                // Once course has been computed, determine wind adjusted course
                    //                // Once wind adjusted course has been set, adjust for magnetic variation for that location
                    //                guard let index = wayPointList.firstIndex(of: aWayPoint) else { return }
                    //                wayPointList[index] = aWayPoint
                    //                print("Computed: \(courseFrom), Altered: \(aWayPoint.courseFrom), Index: \(index), Stored: \(wayPointList[index].courseFrom)")
                    //
                    
                    self.activeWayPoints[currentSequence] = aWayPoint
                    self.saveLogToDisk()
                    
                }
            } catch let error {
                Logger.api.error("Set up waypoints failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fixIASforMetricsChange() {
        guard AppMetricsSwift.settings.oldSpeedMode != AppMetricsSwift.settings.speedMode else { return }
        let multiplier: Double
        // We know these modes aren't the same.
        //  Find the multiplier to use
        switch AppMetricsSwift.settings.speedMode {
        case .metric:
            if AppMetricsSwift.settings.oldSpeedMode == .nautical {
                // Convert nautical to metric
                multiplier = 1.852
            } else {
                // Convert standard to metric
                multiplier = 1.60934
            }
        case .standard:
            if AppMetricsSwift.settings.oldSpeedMode == .nautical {
                // Convert nautical to standard
                multiplier = 1.15078
            } else {
                // Convert metric to standard
                multiplier = 0.621371
            }
        case .nautical:
            if AppMetricsSwift.settings.oldSpeedMode == .standard {
                // Convert standard to nautical
                multiplier = 0.868976
            } else {
                // Convert metric to nautical
                multiplier = 0.539957
            }
        }
        
        activeWayPoints.forEach { aWayPoint in
            let esg = Double(aWayPoint.estimatedGroundSpeed)
            let currentSequence: Int = aWayPoint.sequence
            activeWayPoints[currentSequence].estimatedGroundSpeed = Int(round(esg * multiplier))
        }
    }
    
    func loadIntoWayPoint(_ logEntry: NavigationPoint, _ index: Int) {
        let theAltitude = Int(logEntry.elevation * metersToFeetMultiple)
        var aWayPoint = WayPoint(name: logEntry.name, latitude: logEntry.latitude, longitude: logEntry.longitude, altitude: theAltitude, wind: Wind(speed: 0, directionFrom: 0), courseFrom: 0, estimatedDistanceToNextWaypoint: 0, estimatedGroundSpeed: 0, estimatedTimeReached: 0, computedFuelBurnToNextWayPoint: 0)
        aWayPoint.sequence = index
        activeWayPoints.append(aWayPoint)
    }
}
