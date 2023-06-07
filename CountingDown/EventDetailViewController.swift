//
//  EventDetailViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 06/06/23.
//

import UIKit

protocol EventDelegate {
    func toggleFavorite(_ index: Int)
}

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event!
    var delegate: EventDelegate!
    var index: Int!
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        event.isFavorite.toggle()
        favoriteButton.isSelected = event.isFavorite
        
        delegate.toggleFavorite(index)
    }
    
    func getTimeLeft(_ seconds: Double) -> (Int, Int, Int, Int) {
        var seconds = Double(seconds)
        let days = seconds / 86_400
        seconds = seconds.truncatingRemainder(dividingBy: 86_400)
        let hours = seconds / 3_600
        seconds = seconds.truncatingRemainder(dividingBy: 3_600)
        let minutes = seconds / 60
        seconds = seconds.truncatingRemainder(dividingBy: 60)
        
        return (Int(days), Int(hours), Int(minutes), Int(seconds))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventImage.layer.cornerRadius = 20.0
        eventImage.clipsToBounds = true
        if event.hasImage == false {
            eventImage.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
        }
        nameLabel.text = event.title
        favoriteButton.isSelected = event.isFavorite
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return event.tasks.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0,0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let time = getTimeLeft(event.date.timeIntervalSinceNow)
            let text = "\(time.0) Days, \(time.1) Hours, \(time.2) Minutes, and \(time.3) Seconds left."
            content.text = text
            content.textProperties.font = .boldSystemFont(ofSize: 19)
            cell.contentConfiguration = content
            return cell
        case [0,1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let formattedDate = event.isAllDay ? event.date.formatted(date: .abbreviated, time: .omitted) : event.date.formatted(date: .abbreviated, time: .shortened)
            content.text = "Date:"
            content.textProperties.font = .boldSystemFont(ofSize: 19)
            content.secondaryText = "\(formattedDate.capitalized)"
            content.secondaryTextProperties.font = .boldSystemFont(ofSize: 17)
            cell.contentConfiguration = content
            return cell
        default:
            return  tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            
        }
    }
}
