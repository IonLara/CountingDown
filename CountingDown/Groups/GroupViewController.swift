//
//  GroupViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 03/10/23.
//

import UIKit
import EventKit

protocol GroupDelegate {
    func updateGroup(_ index: Int)
    func saveGroups()
}

class GroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EventDelegate {
    
    let store = EKEventStore()
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var emojiTextField: EmojiTextField!
    
    var imagePicker = UIImagePickerController()
    
    var delegate: GroupDelegate!
    
    var group: Group!
    var groupIndex: Int!
    
    var events: [Event]!
    var contained = [Event]()
    
    var bool: Bool!  {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItem = editButtonItem
        
        title = group.groupName
        
        membersButton.titleLabel?.text = "Members [ \(group.members.count) ]"
        membersButton.setTitle("Members [ \(group.members.count) ]", for: .selected)
        membersButton.setTitle("Members [ \(group.members.count) ]", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        groupNameField.text = group.groupName
        
        groupImage.layer.cornerRadius = 20.0
        groupImage.clipsToBounds = true
        groupImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        groupImage.addGestureRecognizer(gestureRecognizer)
        
        groupImage.layer.borderWidth = 5
        groupImage.layer.borderColor = CGColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
        
        colorWell.selectedColor = UIColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
        colorWell.supportsAlpha = false
        colorWell.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        
        emojiTextField.isUserInteractionEnabled = false
        emojiTextField.addTarget(self, action: #selector(emojiDone), for: .editingChanged)
        emojiTextField.addTarget(self, action: #selector(emojiCanceled), for: .editingDidEnd)
        
        if group.hasImage {
            if let temp = Data(base64Encoded: group.imageData!) {
                let image = UIImage(data: temp)
                groupImage.image = UIImage(cgImage: (image?.cgImage!)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: group.imageOrientation!)!)
            }
        } else {
            groupImage.backgroundColor = UIColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
            if group.hasEmoji {
                emojiTextField.text = group.emoji
            }
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        store.requestAccess(to: .event, completion: { granted, error in
        })
        events = Manager.loadEvents()
        getEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let temp = Manager.loadEvents(){
            events = temp
        } else {
            events = Manager.loadBaseEvents()
        }
        print("ViewDidAppear")
        
        collectionView.reloadData()
    }
    
    func getEvents() {
        contained.removeAll()
        for event in events {
            if group.events.contains(event.id) {
                contained.append(event)
            }
        }
    }
    
    @IBAction func nameEditAccept(_ sender: UITextField) {
        view.endEditing(true)
    }
    @IBAction func nameEditChanged(_ sender: UITextField) {
        title = sender.text
    }
    @IBAction func nameEditEnded(_ sender: UITextField) {
        sender.resignFirstResponder()
        if sender.text == nil || sender.text == "" {
            sender.text = group.groupName
            title = group.groupName
        } else {
            group.groupName = sender.text!
            title = sender.text!
        }
        delegate.updateGroup(groupIndex)
        delegate.saveGroups()
    }
    
    @objc func imageTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Choose Image", style: .default, handler: {_ in
            self.chooseImage()
        }))
        alertController.addAction(UIAlertAction(title: "Choose Emoji", style: .default, handler: {_ in
            self.useEmoji()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.dismissAlert()
        }))
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
        
        groupImage.image = image
        group.hasImage = true
        group.imageOrientation = image.imageOrientation.rawValue
        if let result = image.pngData()?.base64EncodedString() {
            group.imageData = result
        }
        
        if group.hasEmoji {
            group.hasEmoji = false
            group.emoji = ""
            emojiTextField.text = ""
        }
        delegate.updateGroup(groupIndex)
        delegate.saveGroups()
        self.dismiss(animated: true)
    }
    
    @objc func emojiDone() {
        if let temp = emojiTextField.text?.first?.isEmoji {
            if temp == true {
                dismissKeyboard()
                group.hasEmoji = true
                group.emoji = emojiTextField.text!
                group.hasImage = false
                group.imageLocation = ""
                emojiTextField.isUserInteractionEnabled = false
                delegate.updateGroup(groupIndex)
            }else {
                emojiTextField.text = ""
            }
        } else {
            emojiTextField.text = ""
        }
        delegate.saveGroups()
    }
    
    @objc func emojiCanceled() {
        if !((emojiTextField.text?.first?.isEmoji) != nil) {
            if group.hasEmoji {
                group.hasEmoji = false
                group.emoji = ""
                emojiTextField.isUserInteractionEnabled = false
            }
            if group.hasImage {
                if let temp = Data(base64Encoded: group.imageData!) {
                    let image = UIImage(data: temp)
                    groupImage.image = UIImage(cgImage: (image?.cgImage!)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: group.imageOrientation!)!)
                }
            } else {
                groupImage.backgroundColor = UIColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
            }
        }
        delegate.saveGroups()
    }
    
    func useEmoji() {
        groupImage.image = nil
        groupImage.backgroundColor = UIColor(red: group.colorR, green: group.colorG, blue: group.colorB, alpha: group.colorA)
        emojiTextField.isUserInteractionEnabled = true
        emojiTextField.becomeFirstResponder()
        emojiTextField.text = ""
    }
    
    func chooseImage() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true)
        }
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func colorChanged() {
        let color = colorWell.selectedColor
        groupImage.backgroundColor = color
        groupImage.layer.borderColor = color?.cgColor
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue:CGFloat = 0
        var alpha:CGFloat = 0
        color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        group.colorR = red
        group.colorG = green
        group.colorB = blue
        group.colorA = 1
        
        delegate.updateGroup(groupIndex)
        delegate.saveGroups()
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
    
    func createLayout() ->UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalWidth(0.48))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        contained.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
        
        var event = contained[indexPath.item]
        
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
        
        //        cell.deleteButton.tag = indexPath.item + 1000
        //        cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
        
        
        //        cell.favoriteButton.tag = indexPath.item + 1000
        //        cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
        //        cell.favoriteButton.isSelected = event.isFavorite
        //
        //        cell.shareButton.tag = indexPath.item + 1000
        //        cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
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
    @IBSegueAction func showMembers(_ coder: NSCoder, sender: Any?) -> MembersTableViewController? {
        let memberView = MembersTableViewController(coder: coder)
        memberView?.group = group
        return memberView
    }
    @IBSegueAction func showEventDetail(_ coder: NSCoder, sender: Any?) -> EventDetailViewController? {
        let detailView = EventDetailViewController(coder: coder)
        guard let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) else {return detailView}
        let index = indexPath.item
        
        let event = contained[index]
        
        detailView?.event = event
        detailView?.delegate = self
        detailView?.index = events.firstIndex(of: contained[index])
//        detailView?.index = group.events[index]
        return detailView
    }
    
    func toggleFavorite(_ index: Int, _ adding: Bool) {
        events[index].isFavorite.toggle()
//        events[events.firstIndex(of: group.events[index])!].isFavorite.toggle()
        collectionView.reloadData()
    }
    
    func updateName(_ index: Int) {
        
        collectionView.reloadData()
    }
    
    func saveEvents() {
        Manager.saveEvents(events)
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
    
    func syncEvent(_ event: Event) -> Bool {
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
    
    @IBSegueAction func AddEventSegue(_ coder: NSCoder, sender: Any?) -> AddEventCollectionViewController? {
        let screen = AddEventCollectionViewController(coder: coder)
        screen?.added = contained
        screen?.group = group
        screen?.groupView = self
        return screen
    }
    @IBAction func AddEventPressed(_ sender: UIButton) {
        print("Added")
    }
    
    //    func eventCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
    //
    //        var event = group.events[indexPath.item]
    //
    //        cell.nameLabel.text = event.title
    //        let temp = getTime(event.date.timeIntervalSinceNow)
    //        cell.numberLabel.text = "\(temp.1)"
    //        cell.remainderLabel.text = "\(temp.0.rawValue) Left"
    //
    //        if !event.hasImage {
    //            cell.image.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
    //            cell.image.image = nil
    //            cell.image.layer.borderWidth = 0
    //        } else {
    //            if event.isImageIncluded {
    //                cell.image.image = UIImage(named: event.imageLocation)
    //            } else {
    //                if let temp = Data(base64Encoded: event.imageData!) {
    //                    let image = UIImage(data: temp)
    //                    cell.image.image = UIImage(cgImage: (image?.cgImage)!, scale: image!.scale, orientation: UIImage.Orientation(rawValue: event.imageOrientation!)!)
    //                }
    //            }
    //            cell.image.layer.borderWidth = 5
    //            cell.image.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
    //        }
    //        cell.opacityView.layer.borderWidth = 5
    //        cell.opacityView.layer.borderColor = CGColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
    //        cell.image.layer.cornerRadius = 20
    //        cell.image.clipsToBounds = true
    //        cell.opacityView.layer.cornerRadius = 20
    //        cell.opacityView.clipsToBounds = true
    //
    ////        cell.deleteButton.tag = indexPath.item + 1000
    ////        cell.deleteButton.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
    //
    //
    ////        cell.favoriteButton.tag = indexPath.item + 1000
    ////        cell.favoriteButton.addTarget(self, action: #selector(favoriteEvent), for: .touchUpInside)
    ////        cell.favoriteButton.isSelected = event.isFavorite
    ////
    ////        cell.shareButton.tag = indexPath.item + 1000
    ////        cell.shareButton.addTarget(self, action: #selector(shareEvent), for: .touchUpInside)
    //        if event.isSynced {
    //            cell.shareButton.setImage(UIImage(systemName: "checkmark.icloud.fill"), for: .normal)
    //            cell.shareButton.isEnabled = false
    //        } else {
    //            cell.shareButton.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
    //            cell.shareButton.isEnabled = true
    //        }
    //
    //
    //        if event.hasEmoji {
    //            cell.emoji.text = event.emoji
    //        } else {
    //            cell.emoji.text = ""
    //        }
    //
    //        cell.isEditing = isEditing
    //        return cell
    //    }
    
}
