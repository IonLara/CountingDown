//
//  Manager.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import Foundation
import UserNotifications

struct Manager: Codable {
    
    static let shared = Manager()
    
    var messages = ["Almost there! ", "Can't wait! ", "So exciting! ", "Getting closer! ", "Less time than yesterday! ", "Don't forget! ", "Just ", "Only ", ""]
    
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
        events.append(Event(title: "Christmas", isFavorite: false, date: date!, hasImage: false, hasEmoji: true, emoji: "🎅", colorR: 1,colorB: 0, colorG: 0, colorA: 1, imageAddress: "", isImageIncluded: false, isAllDay: true, tasks: [], notes: "Christmas is a wonderful time of year where families get together and celebrate, give each other presents, and eat until they have their fill.", notifications: .never, firstAlarm: .dayBefore, secondAlarm: .none))
        date = formatter.date(from: "\(year)/10/31 00:00")
        if date! < Date() {
            year += 1
            date = formatter.date(from: "\(year)/10/31 00:00")
        }
        events.append(Event(title: "Halloween", isFavorite: false, date: date!, hasImage: true, hasEmoji: false, emoji: "", colorR: 1,colorB: 0, colorG: 0.5, colorA: 1, imageAddress: "Halloween", isImageIncluded: true, isAllDay: true, tasks: [], notifications: .never, firstAlarm: .dayBefore, secondAlarm: .none))
        
        return events
    }
    
    func scheduleNotification(_ event: Event) {
        let hour = event.isAllDay ? 12 : Calendar.current.component(.hour, from: event.date)
        let minute = event.isAllDay ? 00 : Calendar.current.component(.minute, from: event.date)
        var date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        var count = 0
        outerloop: while date < event.date {
            let notCad = event.notifications
            switch notCad {
            case .never:
                break outerloop
            case .daily:
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            case .bidaily:
                date = Calendar.current.date(byAdding: .day, value: 2, to: date)!
            case .weekly:
                date = Calendar.current.date(byAdding: .day, value: 7, to: date)!
            case .biweekly:
                date = Calendar.current.date(byAdding: .day, value: 14, to: date)!
            case .monthly:
                date = Calendar.current.date(byAdding: .day, value: 30, to: date)!
            }
            if date > event.date {
                break outerloop
            }
            
            var comps = DateComponents()
            comps.month = Calendar.current.component(.month, from: date)
            comps.day = Calendar.current.component(.day, from: date)
            comps.hour = Calendar.current.component(.hour, from: date)
            comps.minute = Calendar.current.component(.minute, from: date)
                
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                
            let content = UNMutableNotificationContent()
            content.title = event.title.capitalized
            content.body = "\(messages.randomElement() ?? "") \(getRemain(event))"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "\(event.id)-\(count)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {(error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            count += 1
        }
        
    }
    
    func cancelNotifications(_ id: String) {
        let center = UNUserNotificationCenter.current()
        var identifiers = [String]()
        
        center.getPendingNotificationRequests(completionHandler: { (requests) in
            for request in requests {
                if request.identifier.contains(id) {
                    identifiers.append(request.identifier)
                }
            }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        })
    }
    
    func getTimeLeft(_ event: Event) -> (Int, Int, Int, Int) {
        var seconds = Double(event.date.timeIntervalSinceNow)
        let days = seconds / 86_400
        seconds = seconds.truncatingRemainder(dividingBy: 86_400)
        let hours = seconds / 3_600
        seconds = seconds.truncatingRemainder(dividingBy: 3_600)
        let minutes = seconds / 60
        seconds = seconds.truncatingRemainder(dividingBy: 60)
        
        return (Int(days), Int(hours), Int(minutes), Int(seconds))
    }
    
    func getRemain(_ event: Event) -> String {
        let time = getTimeLeft(event)
        let day = time.0 == 1 ? "Day" : "Days"
        let days = time.0 < 1 ? "" : "\(time.0) \(day)"

        return "\(days) Left"
    }
    
    func updateRemain(_ event: Event) -> String {
        let time = getTimeLeft(event)
        let days = time.0 < 1 ? "" : "\(time.0) Days, "
        let hours = days == "" && time.1 < 1 ? "" : "\(time.1) Hours, "
        let minutes = hours == "" && time.2 < 1 ? "" : "\(time.2) Minutes, "
        let seconds = "\(time.3) Seconds Left."
        
        return "\(days)\(hours)\(minutes)\(seconds)"
    }
}
