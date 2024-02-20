import UIKit

var retValue: String = ""
//  We need to know what time it is in Zulu
let now = Date()
let dateFormatter = DateFormatter()
dateFormatter.calendar = Calendar.current
dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
dateFormatter.dateFormat = "YYYYMMDD_HH0000"

retValue = dateFormatter.string(from: now)

print(retValue + "Z")
