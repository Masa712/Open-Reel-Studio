//
//  Item.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
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
