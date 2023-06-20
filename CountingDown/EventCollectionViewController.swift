//
//  EventCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import UIKit

private let reuseIdentifier = "EventCell"

class EventCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, EventDelegate{
    
    var events = [Event]()
    var favorites = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        navigationItem.leftBarButtonItem = editButtonItem

        if let savedEvents = Manager.loadEvents() {
            events = savedEvents
        } else {
            events = Manager.loadBaseEvents()
        }
        favorites = getFavorites()
        collectionView.collectionViewLayout = createLayout()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = collectionView.cellForItem(at: indexPath) as! EventCollectionViewCell
            cell.isEditing = isEditing
        }
    }
    
    func toggleFavorite(_ index: Int, _ adding: Bool) {
        if adding {
            favorites.append(events[index])
        } else {
            if let i = favorites.firstIndex(of: events[index]) {
                favorites.remove(at: i)
            }
        }
        
        collectionView.reloadData()
//        collectionView.insertItems(at: [[0,0]])
        
    }
    func updateName(_ index: Int) {
        collectionView.reloadItems(at: [[1,index]])
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
            favorites.remove(at: sender.tag - 2000)
            events.remove(at: index!)
            collectionView.reloadData()
        } else { //Index was taken from regular events section
            if events[sender.tag - 1000].isFavorite {
                let index = favorites.firstIndex(of: events[sender.tag - 1000])
                favorites.remove(at: index!)
            }
            events.remove(at: sender.tag - 1000)
            collectionView.reloadData()
        }
    }
    
    @objc func favoriteEvent(sender: UICollectionViewCell) {
        let isFav = sender.tag / 1000 == 2
        if isFav {
            
        } else {
            
        }
    }
    
    @objc func shareEvent(sender: UICollectionViewCell) {
        let isFav = sender.tag / 1000 == 2
        if isFav {
            
        } else {
            
        }
    }
    
    func createLayout() ->UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(1))
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
            index = events.firstIndex(of: favorites[index])!
        }
        detailView?.event = events[index]
        detailView?.delegate = self
        detailView?.index = index
        return detailView
    }
    @IBSegueAction func createEvent(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        let view = EventDetailViewController(coder: coder)
        events.append(Event())
        collectionView.reloadSections([1])
        let index = events.count - 1
        view?.event = events[index]
        view?.delegate = self
        view?.index = index
        return view
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
            if !event.hasImage {
                cell.image.image = nil
                cell.image.layer.borderWidth = 0
                cell.image.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            } else {
                if event.isImageIncluded {
                    cell.image.image = UIImage(named: event.imageAddress)
                } else {
                    //Code to get image from phone
                }
                cell.image.layer.borderWidth = 5
                cell.image.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            }
            cell.image.layer.cornerRadius = 20
            cell.image.clipsToBounds = true
            cell.deleteButton.tag = indexPath.item + 2000
            cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
            cell.isEditing = isEditing
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
            let event = events[indexPath.item]
            cell.nameLabel.text = event.title
            let temp = getTime(event.date.timeIntervalSinceNow)
            cell.numberLabel.text = "\(temp.1)"
            if !event.hasImage {
                cell.image.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
                cell.image.image = nil
                cell.image.layer.borderWidth = 0
            } else {
                if event.isImageIncluded {
                    cell.image.image = UIImage(named: event.imageAddress)
                } else {
                    //Code to get image from phone
                }
                cell.image.layer.borderWidth = 5
                cell.image.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
            }
            cell.image.layer.cornerRadius = 20
            cell.image.clipsToBounds = true
            cell.deleteButton.tag = indexPath.item + 1000
            cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
            cell.isEditing = isEditing
            return cell
        }
    }
    @objc override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderCollectionReusableView
        if indexPath.section == 0 {
            headerView.label.text = "Favorites"
        } else {
            headerView.label.text = "Events"
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

enum TimeMeassure {
    case days
    case hours
    case minutes
    case seconds
}
