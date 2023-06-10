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
    @IBOutlet weak var remainLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        event.isFavorite.toggle()
        favoriteButton.isSelected = event.isFavorite
        
        delegate.toggleFavorite(index)
    }
    
    func updater() {
        updateRemain()
    }
    
    func getTimeLeft() -> (Int, Int, Int, Int) {
        var seconds = Double(event.date.timeIntervalSinceNow)
        let days = seconds / 86_400
        seconds = seconds.truncatingRemainder(dividingBy: 86_400)
        let hours = seconds / 3_600
        seconds = seconds.truncatingRemainder(dividingBy: 3_600)
        let minutes = seconds / 60
        seconds = seconds.truncatingRemainder(dividingBy: 60)
        
        return (Int(days), Int(hours), Int(minutes), Int(seconds))
    }
    
    func updateRemain() {
        let time = getTimeLeft()
        let days = time.0 < 1 ? "" : "\(time.0) Days, "
        let hours = days == "" && time.1 < 1 ? "" : "\(time.1) Hours, "
        let minutes = hours == "" && time.2 < 1 ? "" : "\(time.2) Minutes, "
        let seconds = "\(time.3) Seconds Left."
        
        remainLabel.text = "\(days)\(hours)\(minutes)\(seconds)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updater()
        })
        
        eventImage.layer.cornerRadius = 20.0
        eventImage.clipsToBounds = true
        if event.hasImage == false {
            eventImage.backgroundColor = UIColor(red: event.colorR, green: event.colorG, blue: event.colorB, alpha: event.colorA)
        } else if event.isImageIncluded == true {
            eventImage.image = UIImage(named: event.imageAddress)
        } else {
            //Add code to get image from user's phone
        }
        nameLabel.text = event.title
        favoriteButton.isSelected = event.isFavorite
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateRemain()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == [1,0] {
            event.tasks.insert(Task(description: "", isComplete: false), at: 0)
            tableView.reloadSections([1], with: .automatic)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return event.tasks.count + 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let formattedDate = event.isAllDay ? event.date.formatted(date: .abbreviated, time: .omitted) : event.date.formatted(date: .abbreviated, time: .shortened)
            content.text = "Date:"
            content.textProperties.font = .boldSystemFont(ofSize: 19)
            content.secondaryText = "\(formattedDate.capitalized)"
            content.secondaryTextProperties.font = .boldSystemFont(ofSize: 17)
            cell.contentConfiguration = content
            return cell
        case 1:
            if indexPath.row < 1 {
                return tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
                print(event.tasks[indexPath.row - 1])
                cell.task = event.tasks[indexPath.row - 1]
                cell.updateFields()
                return cell
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            if let notes = event.notes {
                content.text = notes
            } else {
                content.text = "No notes"
                content.textProperties.color = .darkGray
            }
            cell.contentConfiguration = content
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Tasks:"
        case 2:
            return "Notes:"
        default:
            return nil
        }
    }
}
