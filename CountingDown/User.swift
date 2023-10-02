//
//  User.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 01/10/23.
//

import Foundation

class User: Codable {
    let id: UUID
    var username: String
    
    init() {
        self.id = UUID()
        self.username = "Username"
    }
}
