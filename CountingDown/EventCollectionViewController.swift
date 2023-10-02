//
//  EventCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import UIKit
import UserNotifications
import EventKit

private let reuseIdentifier = "EventCell"

class EventCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, EventDelegate{
    
    var events = [Event]()
    var eventsByTitle = [Event]()
    var eventsByTime = [Event]()
    
    var favorites = [Event]()
    var sorting: SortMethod = .created
    
    let store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Yay!")
                } else {
                    print("D'oh")
                }
            }
        

        store.requestAccess(to: .event, completion: { granted, error in
            // Handle the response to the request.
        })
        
        if let savedEvents = Manager.loadEvents() {
            events = savedEvents
        } else {
            events = Manager.loadBaseEvents()
        }
        Manager.loadUser()
        eventsByTitle = events.sorted(by: {$0.title < $1.title})
        eventsByTime = events.sorted(by: {$0.date < $1.date})
        favorites = getFavorites()
        collectionView.collectionViewLayout = createLayout()
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if events.count > 0 || editing == false {
            super.setEditing(editing, animated: animated)
            collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
                let cell = collectionView.cellForItem(at: indexPath) as! EventCollectionViewCell
                cell.isEditing = isEditing
            }
        }
    }
    
    func toggleFavorite(_ index: Int, _ adding: Bool) {
        if adding {
            switch sorting {
            case .title:
                favorites.append(eventsByTitle[index])
                eventsByTitle[index].isFavorite = true
            case .time:
                favorites.append(eventsByTime[index])
                eventsByTime[index].isFavorite = true
            case .created:
                favorites.append(events[index])
                events[index].isFavorite = true
            }
        } else {
            switch sorting {
            case .title:
                if let i = favorites.firstIndex(of: eventsByTitle[index]) {
                    favorites.remove(at: i)
                    
                    eventsByTitle[index].isFavorite = false
                }
            case .time:
                if let i = favorites.firstIndex(of: eventsByTime[index]) {
                    favorites.remove(at: i)
                    
                    eventsByTime[index].isFavorite = false
                }
            case .created:
                if let i = favorites.firstIndex(of: events[index]) {
                    favorites.remove(at: i)
                    events[index].isFavorite = false
                }
            }
        }
        
        collectionView.reloadData()
    }
    func updateName(_ index: Int) {
        updateArrays()
        switch sorting {
        case .title:
//            collectionView.reloadItems(at: [[1, eventsByTitle.firstIndex(of: events[index])!]])
            collectionView.reloadSections([1])
        case .time:
//            collectionView.reloadItems(at: [[1, eventsByTime.firstIndex(of: events[index])!]])
            collectionView.reloadSections([1])
        case .created:
//            collectionView.reloadItems(at: [[1,index]])
            collectionView.reloadSections([1])
        }
        if favorites.contains(events[index]) {
            collectionView.reloadItems(at: [[0, favorites.firstIndex(of: events[index])!]])
        }
    }
    
    func getFavorites() -> [Event] {
        var temp = [Event]()
        for i in 0..<events.count {
            if events[i].isFavorite == true {
                temp.append(events[i])
            }
        }
        return temp
    }
    
    @objc func deleteEvent(sender: UICollectionViewCell) {
        let isFav = sender.tag / 1000 == 2
        if isFav { //Index was taken from favorites section
            let index = events.firstIndex(of: favorites[sender.tag - 2000])
            Manager.shared.cancelNotifications("\(events[index!].id)")
            favorites.remove(at: sender.tag - 2000)
            let event = events[index!]
            updateCalendar(event, true)
            events.remove(at: index!)
            collectionView.reloadData()
        } else { //Index was taken from regular events section
            if events[sender.tag - 1000].isFavorite {
                let index = favorites.firstIndex(of: events[sender.tag - 1000])
                favorites.remove(at: index!)
            }
            let id = "\(events[sender.tag - 1000].id)"
            Manager.shared.cancelNotifications(id)
            let event = events[sender.tag - 1000]
            updateCalendar(event, true)
            events.remove(at: sender.tag - 1000)
            collectionView.reloadData()
        }
        if events.count == 0 {
            setEditing(false, animated: true)
        }
        saveEvents()
    }
    
    @objc func favoriteEvent(sender: UICollectionViewCell) {
        let isFav = sender.tag / 1000 == 2
        if isFav {
            let event = favorites[sender.tag - 2000]
            switch sorting {
            case .title:
                toggleFavorite(eventsByTitle.firstIndex(of: event)!, false)
            case .time:
                toggleFavorite(eventsByTime.firstIndex(of: event)!, false)
            case .created:
                toggleFavorite(events.firstIndex(of: event)!, false)
            }
        } else {
            let index = sender.tag - 1000
            switch sorting {
            case .title:
                if eventsByTitle[index].isFavorite {
                    toggleFavorite(index, false)
                } else {
                    toggleFavorite(index, true)
                }
            case .time:
                if eventsByTime[index].isFavorite {
                    toggleFavorite(index, false)
                } else {
                    toggleFavorite(index, true)
                }
            case .created:
                if events[index].isFavorite {
                    toggleFavorite(index, false)
                } else {
                    toggleFavorite(index, true)
                }
            }
        }
    }
    
    @objc func shareEvent(sender: UICollectionViewCell) {
        let isFav = sender.tag / 1000 == 2
        if isFav {
            let event = favorites[sender.tag - 2000]
            syncEvent(event)
        } else {
            let index = sender.tag - 1000
            switch sorting {
            case .title:
                syncEvent(eventsByTitle[index])
            case .time:
                syncEvent(eventsByTime[index])
            case .created:
                syncEvent(events[index])
            }
        }
    }
    
    func updateCalendar(_ event: Event, _ delete: Bool) {
        if event.isSynced {
            //Update data
            if delete {
                //Delete
                if let id = event.calendarID {
                    if let calEvent = store.event(withIdentifier: id) {
                        do {
                            try store.remove(calEvent, span: .thisEvent)
                        } catch {
                            print("Could not desync.")
                        }
                    }
                }
            } else {
                print(event.calendarID)
                if let calEvent = store.event(withIdentifier: event.calendarID!) {
                    calEvent.title = event.title
                    calEvent.isAllDay = event.isAllDay
                    calEvent.startDate = event.date
                    calEvent.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: event.date)
                    calEvent.notes = event.notes
                    
                    do {
                        try store.save(calEvent, span: .thisEvent)
                    } catch {
                        print("Could not sync to calendar.")
                    }
                }
            }
        }
    }
    
    func syncEvent(_ event: Event) -> Bool{
        //Create new data
        if !event.isSynced {
            print("Event created")
            let calEvent = EKEvent(eventStore: store)
            

            calEvent.title = event.title
            calEvent.isAllDay = event.isAllDay
            calEvent.startDate = event.date
            calEvent.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: event.date)
            calEvent.notes = event.notes
            calEvent.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(calEvent, span: .thisEvent)
                saveEvents()
                event.isSynced = true
                event.calendarID = calEvent.eventIdentifier
                collectionView.reloadData()
                print(event.isSynced)
                return true
            } catch {
                print("Could not sync to calendar.")
                return false
            }
        }
        return true
    }
    
    func saveEvents() {
        Manager.saveEvents(events)
    }
    
    @objc func sortEvents() {
        let alert = UIAlertController(title: "Sort By:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Date of Creation", style: .default, handler: {_ in
            //Add stuff here
            self.sorting = .created
            self.collectionView.reloadSections([1])
        }))
        alert.addAction(UIAlertAction(title: "Date of Event", style: .default, handler: {_ in
            self.sorting = .time
            self.collectionView.reloadSections([1])
        }))
        alert.addAction(UIAlertAction(title: "Title", style: .default, handler: {_ in
            //Add stuff here
            self.sorting = .title
            self.collectionView.reloadSections([1])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    func createLayout() ->UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.48))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func getTime(_ time: Double) -> (TimeMeassure, Int) {
        var meassure = TimeMeassure.days
        var temp = 0
        if time > 86_400 {
            temp = Int(ceil(time / 86_400))
        } else if time > 3_600 {
            meassure = .hours
            temp = Int(ceil(time / 3_600))
        } else if time > 60 {
            meassure = .minutes
            temp = Int(ceil(time / 60))
        } else {
            meassure = .seconds
            temp = Int(round(time))
        }
        return (meassure, temp)
    }
    
    @IBSegueAction func showEventDetail(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        let detailView = EventDetailViewController(coder: coder)
        guard let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) else {return detailView}
        var index = indexPath.item
        if indexPath.section == 0 {
            switch sorting {
            case .title:
                index = eventsByTitle.firstIndex(of: favorites[index])!
            case .time:
                index = eventsByTime.firstIndex(of: favorites[index])!
            case .created:
                index = events.firstIndex(of: favorites[index])!
            }
            
        }
        
        var event: Event!
        switch sorting {
        case .title:
            event = eventsByTitle[index]
        case .time:
            event = eventsByTime[index]
        case .created:
            event = events[index]
        }
        detailView?.event = event
        detailView?.delegate = self
        detailView?.index = index
        return detailView
    }
    @IBSegueAction func createEvent(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        let view = EventDetailViewController(coder: coder)
        events.append(Event())
        updateArrays()
        collectionView.reloadSections([1])
        let index = events.count - 1
        view?.event = events[index]
        view?.delegate = self
        view?.index = index
        return view
    }
    
    func updateArrays() {
        eventsByTime = events.sorted(by: {$0.date < $1.date})
        eventsByTitle = events.sorted(by: {$0.title < $1.title})
    }
    
    @IBAction func unwindToEventCollection(segue: UIStoryboardSegue, sender: Any?) {
        let detail = sender as! EventDetailViewController
        let newData = detail.event
        events[detail.index] = newData!
    }
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return favorites.count
        case 1:
            return events.count
        default:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
            let event = favorites[indexPath.item]
            cell.nameLabel.text = event.title
            let temp = getTime(event.date.timeIntervalSinceNow)
            cell.numberLabel.text = "\(temp.1)"
            cell.remainderLabel.text = "\(temp.0.rawValue) Left"
            
            if !event.hasImage {
                cell.image.image = nil
                cell.image.layer.borderWidth = 0
                cell.image.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            } else {
                if event.isImageIncluded {
                    cell.image.image = UIImage(named: event.imageLocation)
                } else {
                    if let temp = Data(base64Encoded: event.imageData!) {
                        let image = UIImage(data: temp)
                        cell.image.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: event.imageOrientation!)!)
                    }
                }
                cell.image.layer.borderWidth = 5
                cell.image.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            }
            cell.opacityView.layer.borderWidth = 5
            cell.opacityView.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            cell.image.layer.cornerRadius = 20
            cell.image.clipsToBounds = true
            cell.opacityView.layer.cornerRadius = 20
            cell.opacityView.clipsToBounds = true
            
            cell.deleteButton.tag = indexPath.item + 2000
            cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
            cell.favoriteButton.tag = indexPath.item + 2000
            cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
            cell.favoriteButton.isSelected = event.isFavorite
            
            cell.shareButton.tag = indexPath.item + 2000
            cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
            cell.shareButton.isHidden = event.isSynced
            
            if event.hasEmoji {
                cell.emoji.text = event.emoji
            } else {
                cell.emoji.text = ""
            }
            
            cell.isEditing = isEditing
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
            
            var event: Event!
            switch sorting {
            case .title:
                event = eventsByTitle[indexPath.item]
            case .time:
                event = eventsByTime[indexPath.item]
            case .created:
                event = events[indexPath.item]
            }
            
            cell.nameLabel.text = event.title
            let temp = getTime(event.date.timeIntervalSinceNow)
            cell.numberLabel.text = "\(temp.1)"
            cell.remainderLabel.text = "\(temp.0.rawValue) Left"
            
            if !event.hasImage {
                cell.image.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
                cell.image.image = nil
                cell.image.layer.borderWidth = 0
            } else {
                if event.isImageIncluded {
                    cell.image.image = UIImage(named: event.imageLocation)
                } else {
                    if let temp = Data(base64Encoded: event.imageData!) {
                        let image = UIImage(data: temp)
                        cell.image.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: event.imageOrientation!)!)
                    }
                }
                cell.image.layer.borderWidth = 5
                cell.image.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            }
            cell.opacityView.layer.borderWidth = 5
            cell.opacityView.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            cell.image.layer.cornerRadius = 20
            cell.image.clipsToBounds = true
            cell.opacityView.layer.cornerRadius = 20
            cell.opacityView.clipsToBounds = true
            
            cell.deleteButton.tag = indexPath.item + 1000
            cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
           
            cell.favoriteButton.tag = indexPath.item + 1000
            cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
            cell.favoriteButton.isSelected = event.isFavorite
            
            cell.shareButton.tag = indexPath.item + 1000
            cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
            if event.isSynced {
                cell.shareButton.setImage(UIImage(systemName: "checkmark.icloud.fill"), for: .normal)
                cell.shareButton.isEnabled = false
            } else {
                cell.shareButton.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
                cell.shareButton.isEnabled = true
            }
            
            
            if event.hasEmoji {
                cell.emoji.text = event.emoji
            } else {
                cell.emoji.text = ""
            }
            
            cell.isEditing = isEditing
            return cell
        }
    }
    @objc override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderCollectionReusableView
        if indexPath.section == 0 {
            headerView.label.text = "Favorites"
            headerView.button.isHidden = true
        } else {
            headerView.label.text = "Events"
            headerView.button.isHidden = false
            headerView.button.addTarget(self, action: #selector(sortEvents), for: .touchUpInside)
        }
        headerView.label.font = .boldSystemFont(ofSize: 28)
        headerView.label.textColor = .darkGray

        return headerView
    }
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        CGSize(width: 10, height: 10)
//    }
}

enum TimeMeassure: String {
    case days = "Days"
    case hours = "Hours"
    case minutes = "Minutes"
    case seconds = "Seconds"
}
enum SortMethod {
    case title
    case time
    case created
}
