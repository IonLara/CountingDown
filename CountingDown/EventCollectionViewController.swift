//
//  EventCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import UIKit

private let reuseIdentifier = "EventCell"

class EventCollectionViewController: UICollectionViewController, EventDelegate{
    
    var events = [Event]()
    var favorites = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedEvents = Manager.loadEvents() {
            events = savedEvents
        } else {
            events = Manager.loadBaseEvents()
        }
        favorites = getFavorites()
        collectionView.collectionViewLayout = createLayout()
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
    }
    func updateName(_ index: Int) {
        collectionView.reloadItems(at: [[1,index]])
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
    
    func createLayout() ->UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
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
    @IBSegueAction func testSegue(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        let detailView = EventDetailViewController(coder: coder)
        
        var index = 1
        detailView?.event = events[index]
        detailView?.delegate = self
        detailView?.index = index
        return detailView
    }
    
    @IBAction func unwindToEventCollection(segue: UIStoryboardSegue, sender: Any?) {
        let detail = sender as! EventDetailViewController
        let newData = detail.event
        events[detail.index] = newData!
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
        switch indexPath.section {
        case 0:
            let event = favorites[indexPath.item]
            cell.nameLabel.text = event.title
            let temp = getTime(event.date.timeIntervalSinceNow)
            cell.numberLabel.text = "\(temp.1)"
        default:
            let event = events[indexPath.item]
            cell.nameLabel.text = event.title
            let temp = getTime(event.date.timeIntervalSinceNow)
            cell.numberLabel.text = "\(temp.1)"
        }
        return cell
    }
}

enum TimeMeassure {
    case days
    case hours
    case minutes
    case seconds
}
