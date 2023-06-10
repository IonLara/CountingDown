//
//  Task.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import Foundation

class Task: Codable {
    
    var description: String
    var isComplete: Bool
    
    init(description: String, isComplete: Bool) {
        self.description = description
        self.isComplete = isComplete
    }
}
