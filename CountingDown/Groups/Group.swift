//
//  Group.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 01/10/23.
//

import Foundation

class Group: Codable, Equatable {
    
    let id: UUID
    
    var groupName: String
    var description: String?
    
    var members: [User]
    var admins: [User]
    
    var events: [Int]
    
    var hasImage: Bool = false
    var imageData: String?
    var imageOrientation: Int?
    var imageLocation = ""
    
    var hasEmoji: Bool = false
    var emoji: String
    
    var colorR: Double = 0.0
    var colorG: Double = 0.0
    var colorB: Double = 0.0
    var colorA: Double = 1.0
    
    init() {
        self.id = UUID()
        self.groupName = "New Group"
        self.description = nil
        self.members = [Manager.user!]
        self.admins = [Manager.user!]
        self.events = [Int]()
        self.hasImage = false
        self.imageData = nil
        self.imageOrientation = nil
        self.hasEmoji = false
        self.emoji = ""
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
    
    
    
}

