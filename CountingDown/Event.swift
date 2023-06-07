//
//  Event.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import Foundation
import UIKit

struct Event: Codable{
    
    var title: String
    var isFavorite: Bool
    var date: Date
    var hasImage: Bool = false
    var colorR: Double = 0.0
    var colorB: Double = 0.0
    var colorG: Double = 0.0
    var colorA: Double = 0.0
    var imageAddress: String = ""
    var isAllDay: Bool
    var tasks: [Task]
    var notes: String?
    
    var notifications: NotificationCadency

    var firstAlarm: AlarmTime
    var secondAlarm: AlarmTime

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
