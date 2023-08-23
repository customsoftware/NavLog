//
//  Item.swift
//  NavLog
//
//  Created by Kenneth Cluff on 8/23/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
