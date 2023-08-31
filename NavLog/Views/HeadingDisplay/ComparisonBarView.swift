//
//  ComparisonBarView.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/26/23.
//

import SwiftUI

struct ComparisonBarView: View {
    
    @State var courseState: CourseState
    
    var body: some View {
        
        VStack {
            
            HSIImageView(courseState: courseState)
            
            Divider()
            VStack {
                Text("Time to Waypoint: \(courseState.actualTimeToNextWaypoint())")
                Text("Planned Course: \(courseState.plannedHeading)")
                Text("Course Deviation: \(courseState.deviation())")
                Text("Ground Speed: \(courseState.observedGroundSpeed)")
                Text("Planned Ground Speed: \(courseState.plannedGroundSpeed)")
            }
        }
        Spacer()
    }
}

#Preview {
    ComparisonBarView(courseState: generateDemoCourseState())
}

func generateDemoCourseState() -> CourseState {
    return CourseState(currentHeading: 180, plannedHeading: 185, observedGroundSpeed: 107, plannedGroundSpeed: 117, plannedTimeToNextWaypoint: 75, distanceToWayPoint: 2.23)
}

struct CourseState {
    var currentHeading: Float
    var plannedHeading: Float
    func deviation() -> Float {
        return plannedHeading - currentHeading
    }
    var observedGroundSpeed: Float
    var plannedGroundSpeed: Float
    var plannedTimeToNextWaypoint: Double
    var distanceToWayPoint: Double
    func actualTimeToNextWaypoint() -> Double {
        let retValue: Double = ( round( distanceToWayPoint/(Double(observedGroundSpeed)/60) * 100 )) / 100
        return retValue
    }
}
