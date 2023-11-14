import Foundation
import CoreLocation


let accessKey = "zNEw7"
var declinationURI: String = "https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=LATITUDE&lon1=LONGITUDE&key=zNEw7&resultFormat=json"
let wayPoint = CLLocation(latitude: 40.21967, longitude: -111.7234)
let nextWayPoint = CLLocation(latitude: 33.434283, longitude: -112.0116)
//let wayPoint = CLLocation(latitude: 39.099912, longitude: -94.581213)
//let nextWayPoint = CLLocation(latitude: 38.627089, longitude: -90.200203)
struct WayPoint {
    var latitude: Double
    var longitude: Double
    var deviation: Double = 0.0
}

let startWP = WayPoint(latitude: wayPoint.coordinate.latitude, longitude: wayPoint.coordinate.longitude)
let stopWP = WayPoint(latitude: nextWayPoint.coordinate.latitude, longitude: nextWayPoint.coordinate.longitude)

let magDeviation = -10.5
var distanceToNextWaypointSwift: Double = 0
var distanceToNextWaypointArc: Double = 0
let meterToMile: Double = 0.000621371
let circle: Double = 360.0
let radMultiple = Double.pi/180
let earthRadiusMetric: Double = 6371000 // meters

func convertRadToDegrees(_ radiansIn: Double) -> Double {
    var retValue = radiansIn * 180 / Double.pi
    if retValue < 0 {
        let intRetValue = Int(retValue * 100 + 36000)
        retValue = Double(intRetValue)
    } else {
        retValue = retValue * 100
    }
    return round(retValue)/100
}

func computeDistanceBetweenWayPoints(from thisWayPoint: CLLocation, to nextPoint: CLLocation) -> Double {
    var retValue = 0.0
    let startLat = thisWayPoint.coordinate.latitude * radMultiple
    let startLong = thisWayPoint.coordinate.longitude * radMultiple
    
    let endLat = nextPoint.coordinate.latitude * radMultiple
    let endLong = nextPoint.coordinate.longitude * radMultiple
    
    let deltaLat = endLat - startLat
    let deltaLong = endLong - startLong
    
    let arcValue = sin(deltaLat/2) * sin(deltaLat/2) + cos(startLat) * cos(endLat) * sin(deltaLong/2) * sin(deltaLong/2)
    let coveredValue = 2.0 * atan2(arcValue.squareRoot(), (1-arcValue).squareRoot())
    retValue = coveredValue * earthRadiusMetric
    
    return retValue
}

func computeCourseToWayPoint(from thisWayPoint: CLLocation, to nextPoint: CLLocation) -> Double {
    distanceToNextWaypointSwift = thisWayPoint.distance(from: nextPoint) // This is in meters. Convert to miles
    
    let startLat: Double = thisWayPoint.coordinate.latitude
    let startLong: Double = thisWayPoint.coordinate.longitude
    
    let endLat: Double = nextPoint.coordinate.latitude
    let endLong: Double = nextPoint.coordinate.longitude
    
    let deltaLong: Double = round((nextPoint.coordinate.longitude - thisWayPoint.coordinate.longitude)*100000)/100000
    
    let courseX = cos(endLat * radMultiple) * sin(deltaLong * radMultiple)
    let courseYpart1 = cos(startLat * radMultiple) * sin(endLat * radMultiple)
    let courseYpart2 = sin(startLat * radMultiple) * cos(endLat * radMultiple) * cos(deltaLong * radMultiple)
    let courseY = courseYpart1 - courseYpart2
   
    let course = atan2(courseX, courseY) // In radians

    return convertRadToDegrees(course)
}

func buildQueryString(for wayPoint: WayPoint) -> String {
    let lat = Int(wayPoint.latitude)
    let long = wayPoint.longitude
    let queryString = declinationURI.replacing("LATITUDE", with: "\(lat)").replacing("LONGITUDE", with: "\(long)")
    print(queryString)
    return queryString
}

struct DecData : Codable {
    var date: Double
    var elevation: Int
    var declination: Double
    var latitude: Int
    var declnation_sv: Double
    var declination_uncertainty: Double
    var longitude: Double
}
struct DecUnits: Codable {
    var elevation: String
    var declination: String
    var declination_sv: String
    var latitude: String
    var declination_uncertainty: String
    var longitude: String
}
struct DeclinationResults : Codable {
    var result : [DecData]
    var model: String
    var units: DecUnits
    var version: String
}



func getMagneticDeviation(distance: Double, start: WayPoint, end: WayPoint) -> Double {
    var queries: [String] = []
    var results: [Double] = []
    
    if distance <= 100 {
        // If distance is less than or equals to 100 miles, use mag dev of starting point
        let queryString = buildQueryString(for: start)
        queries.append(queryString)
    } else {
        // If distance is more than 100 miles, and less than 400, use average of destination and starting location mag dev
        let startString = buildQueryString(for: start)
        queries.append(startString)
        let endString = buildQueryString(for: end)
        queries.append(endString)
    }
    
    for aQuery in queries {
        guard let queryURL = URL(string: aQuery) else { return  1.0 }
        
        let (data, _) = try await URLSession.shared.data(from: queryURL)
        if let magData = data {
            /// do exception handler so that our app does not crash
            do {
                let aResult = try JSONDecoder().decode(DeclinationResults.self, from: magData)
                results.append(aResult.result.first!.declination)
                print("Results count: \(results.count)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    return Double(results.count)
}

print("FlyQ Distance 4.7.3 miles, Course: 172")

let rawCourse = computeCourseToWayPoint(from: wayPoint, to: nextWayPoint)

let deviation = getMagneticDeviation(distance: distanceToNextWaypointSwift, start: startWP, end: stopWP)

print("\(deviation)")
//distanceToNextWaypointArc = computeDistanceBetweenWayPoints(from: wayPoint, to: nextWayPoint)
//print("Arc Distance: \(round(distanceToNextWaypointArc * meterToMile))")

print("Swift Distance: \(round(distanceToNextWaypointSwift * meterToMile))")



print("Computed Course: \(round(rawCourse))")
