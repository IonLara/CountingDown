//
//  GroupCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 01/10/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class GroupCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GroupDelegate {
    func updateGroup(_ index: Int) {
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func saveGroups() {
        Manager.saveGroups(groups)
        collectionView.reloadData()
    }
    
    
    var groups = [Group]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//
//        if let temp = Manager.loadEvents(){
//            groups = temp
//        } else {
//            events = Manager.loadBaseEvents()
//        }
//        print("ViewDidAppear")
//
        Manager.saveGroups(groups)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let loaded = Manager.loadGroups() {
            groups = loaded
        } else {
            var temp = Group()
            temp.groupName = "Example Group"
            temp.events = []
            temp.members = [Manager.user!]
            temp.admins = [Manager.user!]
            groups = [temp]
        }
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    @IBSegueAction func showGroupDetail(_ coder: NSCoder, sender: Any?) -> GroupViewController? {
        var detailView = GroupViewController(coder: coder)
        guard let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) else{return detailView}
        let index = indexPath.item
        
        detailView?.group = groups[index]
        detailView?.delegate = self
        detailView?.groupIndex = index
        return detailView
    }
    
    func createLayout() ->UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.48))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
//        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
        print(indexPath.item)
        let group = groups[indexPath.item]
        
        cell.nameLabel.text = group.groupName
        cell.numberLabel.text = "\(group.events.count)"
//        print("\(group.groupName) has \(group.events.count) events!")
        cell.remainderLabel.text = "Events"
        
        if !group.hasImage {
            cell.image.backgroundColor = UIColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
            cell.image.image = nil
            cell.image.layer.borderWidth = 0
        } else {
            if let temp = Data(base64Encoded: group.imageData!) {
                let image = UIImage(data: temp)
                cell.image.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: group.imageOrientation!)!)
            }
            cell.image.layer.borderWidth = 5
            cell.image.layer.borderColor = CGColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
        }
        cell.opacityView.layer.borderWidth = 5
        cell.opacityView.layer.borderColor = CGColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
        cell.image.layer.cornerRadius = 20
        cell.image.clipsToBounds = true
        cell.opacityView.layer.cornerRadius = 20
        cell.opacityView.clipsToBounds = true
        
        cell.deleteButton.tag = indexPath.item + 1000
//        cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
        
        
        cell.favoriteButton.tag = indexPath.item + 1000
//        cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
//        cell.favoriteButton.isSelected = event.isFavorite
        
        cell.shareButton.tag = indexPath.item + 1000
//        cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
//        if event.isSynced {
//            cell.shareButton.setImage(UIImage(systemName: "checkmark.icloud.fill"), for: .normal)
//            cell.shareButton.isEnabled = false
//        } else {
//            cell.shareButton.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
//            cell.shareButton.isEnabled = true
//        }
        
        
        if group.hasEmoji {
            cell.emoji.text = group.emoji
        } else {
            cell.emoji.text = ""
        }
        
        cell.isEditing = isEditing
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return groups.count
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
