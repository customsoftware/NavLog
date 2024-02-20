import SwiftUI
import Foundation


struct Aircraft {
    var name: String
    var cruiseSpeed: Double
    var climbSpeed: Double
    var descentSpeed: Double
    var climbRate: Double
    var descentRate: Double
    var fuelBurnTO: Double
    var fuelBurnCruise: Double
    var fuelBurnDescent: Double
    var fuelCapacity: Double
}

let theCardinal = Aircraft(name: "Cardinal", cruiseSpeed: 110, climbSpeed: 100, descentSpeed: 110, climbRate: 500, descentRate: 500, fuelBurnTO: 12.9, fuelBurnCruise: 8.5, fuelBurnDescent: 4.5, fuelCapacity: 48)

enum LocationType {
    case takeoff
    case enroute
    case landing
}

struct WayPoint {
    var sequence: Int
    var startingAltitude: Double = 0 // In feet
    var endingAltitude: Double = 0 // In feet
    var distanceToNext: Double // In miles
    var speed: Double = 0 // miles per hour
    var location: LocationType
    func timeToNext() -> Double {
        return (distanceToNext / speed) * 60 // Returns minutes
    }
}

var start = WayPoint(sequence: 0, startingAltitude: 4497, distanceToNext: 1.5, location: .takeoff)
var crosswindD = WayPoint(sequence: 1, startingAltitude: 4497 + 600, distanceToNext: 0.5, location: .enroute)
var downwindD = WayPoint(sequence: 2, startingAltitude: 4497 + 800, distanceToNext: 16.0, location: .enroute)
var pointOfMountain = WayPoint(sequence: 3, startingAltitude: 6500, distanceToNext: 24.7, location: .enroute)
var BTF = WayPoint(sequence: 4, startingAltitude: 6500, distanceToNext: 15.2, location: .enroute)
var HAFB = WayPoint(sequence: 5, startingAltitude: 6500, distanceToNext: 5.0, location: .enroute)
var OGD = WayPoint(sequence: 6, endingAltitude: 4432, distanceToNext: 4.0, location: .landing)

let flightPlan :[WayPoint] = [start, crosswindD, downwindD, pointOfMountain, BTF, HAFB, OGD]


func computeDistanceToCruise(_ startingPoint: WayPoint, endingWayPoint: WayPoint, for aircraft: Aircraft) -> Double {
    var retValue: Double = 0.0
    let deltaAltitude = endingWayPoint.endingAltitude - startingPoint.startingAltitude
    let timeToClimb = deltaAltitude / aircraft.climbRate
    retValue = timeToClimb
    return retValue
}

func fillMissingAltitude(_ startingWaypoint: inout WayPoint, _ endingWayPoint: inout WayPoint) {
    if startingWaypoint.location == .takeoff {
        // Our ending point is the starting point for the endingWayPoint
        startingWaypoint.endingAltitude = endingWayPoint.startingAltitude
        
    } else if endingWayPoint.location == .landing {
        // Our starting waypoing is pattern altitude or ending + 1000 rounded up to the nearest 100
        var workingStart = endingWayPoint.endingAltitude + 1000
        let mod = workingStart.truncatingRemainder(dividingBy: 100)
        if mod >= 50 {
            let tempStart = round(workingStart/100) * 100
            workingStart = tempStart
        } else {
            let tempStart = (round(workingStart/100) * 100) + 100
            workingStart = tempStart
        }
        endingWayPoint.startingAltitude = workingStart
        endingWayPoint.speed = theCardinal.climbSpeed
    }
    
    if startingWaypoint.startingAltitude != endingWayPoint.startingAltitude {
        // This is the standard computation when altitudes are not the same
        startingWaypoint.endingAltitude = endingWayPoint.startingAltitude
        if startingWaypoint.startingAltitude > endingWayPoint.startingAltitude {
            // We are descending so set descending speed
            startingWaypoint.speed = theCardinal.descentSpeed
        } else if startingWaypoint.startingAltitude < endingWayPoint.startingAltitude {
            // We are climbing so set climbing speed
            startingWaypoint.speed = theCardinal.climbSpeed
        }
        
    } else if startingWaypoint.startingAltitude == endingWayPoint.startingAltitude {
        // This is what we use when the altitudes are the same
        startingWaypoint.endingAltitude = startingWaypoint.startingAltitude
        startingWaypoint.speed = theCardinal.cruiseSpeed
    }
}


func computeDistanceFlownForTime(_ timeInMinutes: Double, for aircraft: Aircraft) -> Double {
    return (aircraft.climbSpeed * timeInMinutes) / 60.0
}

var finishedList : [WayPoint] = []

var totalTime : Double = 0
var totalDistance: Double = 0
let _ = flightPlan.map { aWayPoint in
    var modifiableWayPoint = aWayPoint
    let nextSequence = aWayPoint.sequence + 1
    if var nextPoint = flightPlan.first(where: { nextWaypoint in
        nextWaypoint.sequence == nextSequence
    }) {
        fillMissingAltitude(&modifiableWayPoint, &nextPoint)
    } else {
        // Process the last one
        let previousSequence = aWayPoint.sequence - 1
        if var previousPoint = flightPlan.first { aPrevPoint in
            aPrevPoint.sequence == previousSequence
        } {
            fillMissingAltitude(&previousPoint, &modifiableWayPoint)
        }
    }
    
    finishedList.append(modifiableWayPoint)
    totalTime = totalTime + modifiableWayPoint.timeToNext()
    totalDistance = totalDistance + modifiableWayPoint.distanceToNext
}

let _ = finishedList.map { aWaypoint in
    print("\(aWaypoint) \(aWaypoint.timeToNext())")
}
print("")
print("Total time: \(round(totalTime)) minutes")
print("Total distance: \(round(totalDistance)) miles")
