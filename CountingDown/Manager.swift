//
//  Manager.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import Foundation

struct Manager: Codable {
    
    static let shared = Manager()
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("events").appendingPathExtension("plist")
    
    static func loadEvents() -> [Event]? {
        guard let codedEvents = try? Data(contentsOf: archiveURL) else {return nil}
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Array<Event>.self, from: codedEvents)
    }
    
    static func saveEvents(_ events: [Event]) {
        let encoder = PropertyListEncoder()
        let coded = try? encoder.encode(events)
        try? coded?.write(to: archiveURL)
    }
    
    static func loadBaseEvents() -> [Event] {
        var events = [Event]()
        var year = Calendar.current.component(.year, from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        var date = formatter.date(from: "\(year)/12/25 00:00")
        if date! < Date() {
            year += 1
            date = formatter.date(from: "\(year)/12/25 00:00")
        }
        events.append(Event(title: "Christmas", isFavorite: false, date: date!, colorR: 1, colorA: 1, isImageIncluded: false, isAllDay: true, tasks: [], notes: "Christmas is a wonderful time of year where families get together and celebrate, give each other presents, and eat until they have their fill.", notifications: .never, firstAlarm: .dayBefore, secondAlarm: .none))
        date = formatter.date(from: "\(year)/10/31 00:00")
        if date! < Date() {
            year += 1
            date = formatter.date(from: "\(year)/10/31 00:00")
        }
        events.append(Event(title: "Halloween", isFavorite: false, date: date!, hasImage: true, colorR: 1, colorG: 0.5, colorA: 1, imageAddress: "Halloween", isImageIncluded: true, isAllDay: true, tasks: [], notifications: .never, firstAlarm: .dayBefore, secondAlarm: .none))
        
        return events
    }
}
