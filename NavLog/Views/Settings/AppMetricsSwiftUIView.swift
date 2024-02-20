//
//  AppMetricsSwiftUIView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 1/24/24.
//

import SwiftUI
import OSLog

struct AppMetricsSwiftUIView: View {
    
    @StateObject private var vm: AppMetricsSwift = AppMetricsSwift.settings
    
    var body: some View {
        
        VStack (alignment: .leading) {
            Text("Distances measured in...")
            Picker("Distance Mode?", selection: $vm.distanceMode ) {
                Text("Std. Miles").tag(DistanceMode.standard)
                Text("Nautical miles").tag(DistanceMode.nautical)
                Text("Kilometers").tag(DistanceMode.metric)
                
            }
            .pickerStyle(.segmented)
            
            
            Text("Altitude measured in...")
            Picker("Altitude Mode?", selection: $vm.altitudeMode) {
                Text("Meters").tag(AltitudeMode.meters)
                Text("Feet").tag(AltitudeMode.feet)
            }
            .pickerStyle(.segmented)
            
            Text("Speed measured in...")
            Picker("Speed Mode?", selection: $vm.speedMode) {
                Text("MPH").tag(SpeedMode.standard)
                Text("KTS").tag(SpeedMode.nautical)
                Text("KPH").tag(SpeedMode.metric)
            }
            .pickerStyle(.segmented)
            
            
            Text("Fuel capacity measured in...")
            Picker("Fuel Mode?", selection: $vm.fuelMode) {
                Text("Gallons").tag(CapacityMode.gallon)
                Text("Liters").tag(CapacityMode.liter)
            }
            .pickerStyle(.segmented)
            Spacer()
            Text("Because of how the application imports and stores these values, when you change any of these values, you MUST refresh the stored navigation log")
            
        }
        .padding()
        .onDisappear(perform: {
            vm.saveDefaults()
        })
        .navigationTitle("Units of Measure")
    }
}

#Preview {
    AppMetricsSwiftUIView()
}


/// Information stored in this class is stored in user defaults
class AppMetricsSwift: ObservableObject {
    private let defaults: UserDefaults
    private let distanceKey: String = "kDistanceKey"
    private let altitudeKey: String = "kAltitudeKey"
    private let speedKey: String = "kSpeedKey"
    private let fuelKey: String = "kFuelKey"
    private let oldDistanceKey: String = "kOldDistanceKey"
    private let oldAltitudeKey: String = "kOldAltitudeKey"
    private let oldSpeedKey: String = "kOldSpeedKey"
    private let oldFuelKey: String = "kOldFuelKey"
    
    static let settings: AppMetricsSwift = AppMetricsSwift()
    
    @Published var distanceMode: DistanceMode = .standard {
        didSet {
            oldDistanceMode = oldValue
        }
    }
    
    @Published var speedMode: SpeedMode = .standard {
        didSet {
            oldSpeedMode = oldValue
        }
    }
    
    @Published var altitudeMode: AltitudeMode = .feet {
        didSet {
            oldAltitudeMode = oldValue
        }
    }
    
    @Published var fuelMode: CapacityMode = .gallon {
        didSet {
            oldFuelMode = oldValue
        }
    }
    
    @Published var oldDistanceMode: DistanceMode = .standard
    
    @Published var oldSpeedMode: SpeedMode = .standard
    
    @Published var oldAltitudeMode: AltitudeMode = .feet
    
    @Published var oldFuelMode: CapacityMode = .gallon
    
    
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        self.loadCurrentKeys()
        self.loadOldKeys()
    }
    
    func loadCurrentKeys() {
        if let distance = defaults.string(forKey: distanceKey) {
            switch distance {
            case "NM":
                distanceMode = .nautical
            case "SM":
                distanceMode = .standard
            case "KM":
                distanceMode = .metric
            default:
                Logger.viewCycle.critical("A new distance mode has been encountered")
            }
            
        } else {
            Logger.viewCycle.warning("No saved distance")
        }
        
        if let altitude = defaults.string(forKey: altitudeKey) {
            switch altitude {
            case "feet":
                altitudeMode = .feet
            case "meters":
                altitudeMode = .meters
            default:
                Logger.viewCycle.critical("A new altitude mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved altitude")
        }
        
        if let speed = defaults.string(forKey: speedKey) {
            switch speed {
            case "MPH":
                speedMode = .standard
            case "KPH":
                speedMode = .metric
            case "KTS":
                speedMode = .nautical
            default:
                Logger.viewCycle.critical("A new speed mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved speed")
        }
        
        if let fuel = defaults.string(forKey: fuelKey) {
            switch fuel {
            case "gallons":
                fuelMode = .gallon
            case "liters":
                fuelMode = .liter
            default:
                Logger.viewCycle.critical("A new fuel capacity mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved fuel")
        }
    }
    
    func loadOldKeys() {
        if let distance = defaults.string(forKey: oldDistanceKey) {
            switch distance {
            case "NM":
                oldDistanceMode = .nautical
            case "SM":
                oldDistanceMode = .standard
            case "KM":
                oldDistanceMode = .metric
            default:
                Logger.viewCycle.critical("A new distance mode has been encountered")
            }
            
        } else {
            Logger.viewCycle.warning("No saved old distance")
        }
        
        if let altitude = defaults.string(forKey: oldAltitudeKey) {
            switch altitude {
            case "feet":
                oldAltitudeMode = .feet
            case "meters":
                oldAltitudeMode = .meters
            default:
                Logger.viewCycle.critical("A new altitude mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved old altitude")
        }
        
        if let speed = defaults.string(forKey: oldSpeedKey) {
            switch speed {
            case "MPH":
                oldSpeedMode = .standard
            case "KPH":
                oldSpeedMode = .metric
            case "KTS":
                oldSpeedMode = .nautical
            default:
                Logger.viewCycle.critical("A new speed mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved old speed")
        }
        
        if let fuel = defaults.string(forKey: oldFuelKey) {
            switch fuel {
            case "gallons":
                oldFuelMode = .gallon
            case "liters":
                oldFuelMode = .liter
            default:
                Logger.viewCycle.critical("A new fuel capacity mode has been encountered")
            }
        } else {
            Logger.viewCycle.warning("No saved old fuel")
        }
    }
    
    func saveDefaults() {
        defaults.setValue(distanceMode.modeSymbol, forKey: distanceKey)
        defaults.setValue(altitudeMode.text, forKey: altitudeKey)
        defaults.setValue(speedMode.modeSymbol, forKey: speedKey)
        defaults.setValue(fuelMode.text, forKey: fuelKey)
        defaults.setValue(oldDistanceMode.modeSymbol, forKey: oldDistanceKey)
        defaults.setValue(oldAltitudeMode.text, forKey: oldAltitudeKey)
        defaults.setValue(oldSpeedMode.modeSymbol, forKey: oldSpeedKey)
        defaults.setValue(oldFuelMode.text, forKey: oldFuelKey)
        defaults.synchronize()
    }
    
    func pushCurrentToOld() {
        oldFuelMode = fuelMode
        oldSpeedMode = speedMode
        oldAltitudeMode = altitudeMode
        oldDistanceMode = distanceMode
    }
}
