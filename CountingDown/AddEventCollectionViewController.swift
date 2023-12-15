//
//  AddEventCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 13/12/23.
//

import UIKit

private let reuseIdentifier = "EventCell"

class AddEventCollectionViewController: UICollectionViewController {

    var added: [Event]!
    var events: [Event]!
    var options = [Event]()
    var group: Group!
    var groupView: GroupViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events = Manager.loadEvents()
        for event in events {
            if !added.contains(event) {
                options.append(event)
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = createLayout()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

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
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return options.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item <  options.count {
            group.events.append(options[indexPath.item].id)
            groupView.getEvents()
            groupView.delegate.saveGroups()
            groupView.collectionView.reloadData()
            options.remove(at: indexPath.item)
            collectionView.reloadData()
        } else {
            print("New Event")
        }
    }
    @IBSegueAction func addNewEvent(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        var eventView = EventDetailViewController(coder: coder)
        let event = Event()
        events.append(event)
        
        let index = events.count - 1
        
        group.events.append(events[index].id)
        groupView.events.append(event)
//        groupView.getEvents()
        groupView.contained.append(event)
        
        groupView.saveEvents()
        
        groupView.collectionView.reloadData()
        
        eventView?.event = event
        eventView?.delegate = groupView
        eventView?.index = index
        return eventView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        if indexPath.item < options.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventCollectionViewCell
            let event = options[indexPath.item]
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
//            cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
            
            cell.favoriteButton.tag = indexPath.item + 2000
//            cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
            cell.favoriteButton.isSelected = event.isFavorite
            
//            cell.shareButton.tag = indexPath.item + 2000
//            cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
//            cell.shareButton.isHidden = event.isSynced
            
            if event.hasEmoji {
                cell.emoji.text = event.emoji
            } else {
                cell.emoji.text = ""
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCell", for: indexPath)
            return cell
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
