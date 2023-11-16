//
//  PerformanceResults.swift
//  NavLog
//
//  Created by Kenneth Cluff on 11/16/23.
//

import Foundation


struct PerformanceResults {
    var isUnderGross: Bool = false
    var cgIsInLimits: Bool = false
    var overWeightAmount: Double = 0
    var pressureAltitude: Double = 0
    var densityAltitude: Double = 0
    var computedTakeOffRoll: Double = 1400
    var computedOver50Roll: Double = 2100
}
