//
//  User.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 01/10/23.
//

import Foundation

class User: Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    var username: String
    
    init() {
        self.id = UUID()
        self.username = "Username"
    }
}
