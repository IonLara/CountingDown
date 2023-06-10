//
//  Event.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import Foundation
import UIKit

class Event: Codable, Equatable{
    let id: UUID
    
    var title: String
    var isFavorite: Bool
    var date: Date
    var hasImage: Bool = false
    var colorR: Double = 0.0
    var colorB: Double = 0.0
    var colorG: Double = 0.0
    var colorA: Double = 0.0
    var imageAddress: String = ""
    var isImageIncluded: Bool
    var isAllDay: Bool
    var tasks: [Task]
    var notes: String?
    
    var notifications: NotificationCadency

    var firstAlarm: AlarmTime
    var secondAlarm: AlarmTime
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    init(title: String, isFavorite: Bool, date: Date, hasImage: Bool, colorR: Double, colorB: Double, colorG: Double, colorA: Double, imageAddress: String, isImageIncluded: Bool, isAllDay: Bool, tasks: [Task], notes: String? = nil, notifications: NotificationCadency, firstAlarm: AlarmTime, secondAlarm: AlarmTime) {
        self.id = UUID()
        self.title = title
        self.isFavorite = isFavorite
        self.date = date
        self.hasImage = hasImage
        self.colorR = colorR
        self.colorB = colorB
        self.colorG = colorG
        self.colorA = colorA
        self.imageAddress = imageAddress
        self.isImageIncluded = isImageIncluded
        self.isAllDay = isAllDay
        self.tasks = tasks
        self.notes = notes
        self.notifications = notifications
        self.firstAlarm = firstAlarm
        self.secondAlarm = secondAlarm
    }

    enum NotificationCadency: Codable {
        case never
        case daily
        case bidaily
        case weekly
        case biweekly
        case monthly
    }
    enum AlarmTime: Codable{
        case none
        case tenMin
        case halfHour
        case oneHour
        case sixHours
        case dayBefore
    }
}
