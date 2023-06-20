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
    init() {
        id = UUID()
        title = "New Event"
        isFavorite = false
        date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        hasImage = false
        colorR = 0.9
        colorG = 0.9
        colorB = 0.9
        colorA = 1
        imageAddress = ""
        isImageIncluded = false
        isAllDay = true
        tasks = []
        notes = nil
        notifications = .never
        firstAlarm = .none
        secondAlarm = .none
    }

    enum NotificationCadency: String, Codable {
        case never = "Never"
        case daily = "Everyday"
        case bidaily = "Every Second Day"
        case weekly = "Every Week"
        case biweekly = "Every Second Week"
        case monthly = "Every Month"
        
        static let all = [never, daily, bidaily, weekly, biweekly, monthly]
        
        var index: Int {
            switch self {
            case .never:
                return 0
            case .daily:
                return 1
            case .bidaily:
                return 2
            case .weekly:
                return 3
            case .biweekly:
                return 4
            case .monthly:
                return 5
            }
        }
    }
    enum AlarmTime: String, Codable{
        case none = "None"
        case tenMin = "Ten Minutes Before"
        case halfHour = "30 Minutes Before"
        case oneHour = "One Hour Before"
        case sixHours = "Six Hours Before"
        case dayBefore = "The Day Before"
        
        static let all = [none, tenMin, halfHour, oneHour, sixHours, dayBefore]
        
        var index: Int {
            switch self {
            case .none:
                return 0
            case .tenMin:
                return 1
            case .halfHour:
                return 2
            case .oneHour:
                return 3
            case .sixHours:
                return 4
            case .dayBefore:
                return 5
            }
        }
    }
}
