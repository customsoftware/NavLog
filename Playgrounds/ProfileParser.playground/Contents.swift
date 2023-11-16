import Foundation

struct TakeOffWeight: Codable {
    var weight: Double
    var roll: Double
}

struct Multiple: Codable {
    var elevation: Int
    var multiple: Double
}

struct PerformanceProfile: Codable {
    var takeoff: [TakeOffWeight]
    var multipliers: [Multiple]
}


let sampleJSON =
"""
{
  "takeoff": [
    {
      "weight": 1900,
      "roll": 455
    },
    {
      "weight": 2200,
      "roll": 630
    },
    {
      "weight": 2350,
      "roll": 738
    }
  ],
  "multipliers": {
        "sealevel": 1,
        "elevation2500": 1.1893,
        "elevation5000": 1.204,
        "elevation7500": 1.2149
    }
}
""";

let sampleTakeoff =
"""
{
      "weight": 1900,
      "roll": 455
}
""";


let sampleMultipliers =
"""
{
    "sealevel": 1,
    "elevation2500": 1.1893,
    "elevation5000": 1.204,
    "elevation7500": 1.2149
 }
""";



//let jsonData = Data(sampleMultipliers.utf8)
//let jsonData = Data(sampleJSON.utf8)
let jsonData = Data(sampleTakeoff.utf8)

var object: TakeOffWeight?
//var object: PerformanceProfile?
//var object: Multipliers?

do {
//    object = try JSONDecoder().decode(TakeOffWeight.self, from: jsonData)
    //    print("Weight: \(object?.weight ?? 0), Roll: \(object?.roll ?? 0)")
//    print("Sealevel: \(object?.sealevel ?? 0), Elev2500: \(object?.elevation2500 ?? 0)")
} catch let error {
    print("\(error.localizedDescription)")
}

let t1 = TakeOffWeight(weight: 2350, roll: 738)
let t2 = TakeOffWeight(weight: 2200, roll: 640)
let t3 = TakeOffWeight(weight: 1900, roll: 458)

let m1 = Multiple(elevation: 0, multiple: 1)
let m2 = Multiple(elevation: 2500, multiple: 1.118)
let m3 = Multiple(elevation: 5000, multiple: 1.118)
let m4 = Multiple(elevation: 7500, multiple: 1.118)


let performance = PerformanceProfile(takeoff: [t3, t2, t1], multipliers: [m1, m2, m3, m4])

let encoder = JSONEncoder()
do {
    let theJSON = try encoder.encode(performance)
    print(theJSON)
} catch let error {
    print("An error occured: \(error.localizedDescription)")
}
