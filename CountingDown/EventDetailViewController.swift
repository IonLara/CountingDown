//
//  EventDetailViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 06/06/23.
//

import UIKit

protocol EventDelegate {
    func toggleFavorite(_ index: Int, _ adding: Bool)
}

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event!
    var delegate: EventDelegate!
    var index: Int!
    
    let dateInfoCell = DateDetailTableViewCell()
    let timeInfoCell = TimeInfoTableViewCell()
    let dateCell = DateTableViewCell()
    let timeCell = TimeTableViewCell()
    
    let noteCell = NotesTableViewCell()
    
    var isDateOpen = false
    var isTimeOpen = false
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var remainLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()
    
    @IBAction func favoriteTapped(_ sender: UIButton) {
        event.isFavorite.toggle()
        favoriteButton.isSelected = event.isFavorite
        
        delegate.toggleFavorite(index, event.isFavorite)
    }
    @IBSegueAction func showNotifications(_ coder: NSCoder, sender: Any?) -> NotificationTableViewController? {
        let notifications = NotificationTableViewController(coder: coder)
        notifications?.current = event.notifications
        return notifications
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
    
    @objc func updateDatePicker() {
        var content = dateInfoCell.contentConfiguration as! UIListContentConfiguration
        let formattedDate = dateCell.datePicker.date.formatted(date: .abbreviated, time: .omitted)
        content.secondaryText = formattedDate
        dateInfoCell.contentConfiguration = content
        event.date = dateCell.datePicker.date
    }
    
    @objc func updateAllDay() {
        isTimeOpen.toggle()
        event.isAllDay.toggle()
        updateDatePicker()
        tableView.reloadData()
    }
    
    @objc func updateTime() {
        event.date = timeCell.timePicker.date
    }
    
    @objc func notesBeganEditing() {
        if noteCell.textField.textColor == .lightGray && noteCell.textField.isFirstResponder {
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{                       self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{                       self.view.frame.origin.y = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.updater()
        })
        noteCell.textField.delegate = self
        isTimeOpen = !event.isAllDay
        
        dateCell.datePicker.date = event.date
        dateCell.datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        dateCell.datePicker.addTarget(self, action: #selector(updateDatePicker), for: .valueChanged)
        dateCell.accessoryType = .disclosureIndicator
        
        timeInfoCell.accessoryType = .none
        timeInfoCell.allDaySwitch.addTarget(self, action: #selector(updateAllDay), for: .valueChanged)
        timeCell.timePicker.date = event.date
        timeCell.timePicker.addTarget(self, action: #selector(updateTime), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
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
        if indexPath == [2,0] {
            event.tasks.insert(Task(description: "", isComplete: false), at: 0)
            tableView.reloadSections([2], with: .automatic)
        } else if indexPath == [0,0] {
            isDateOpen.toggle()
            tableView.reloadData()
        } else if indexPath == [0,2] {
            updateAllDay()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
        case 2:
            return event.tasks.count + 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                //                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                var content = dateInfoCell.defaultContentConfiguration()
                let formattedDate = event.date.formatted(date: .abbreviated, time: .omitted)
                content.text = "Date:"
                content.textProperties.font = .boldSystemFont(ofSize: 19)
                content.secondaryText = "\(formattedDate.capitalized)"
                content.secondaryTextProperties.font = .boldSystemFont(ofSize: 17)
                dateInfoCell.contentConfiguration = content
                return dateInfoCell
            case 1:
                dateCell.datePicker.isHidden = !isDateOpen
                return dateCell
            case 2:
                timeInfoCell.allDaySwitch.isOn = event.isAllDay
                return timeInfoCell
            case 3:
                timeCell.label.text = isTimeOpen ? "Time: " : ""
                timeCell.timePicker.isHidden = !isTimeOpen
                return timeCell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
            }
            
        case 1:
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Notifications"
                content.secondaryText = event.notifications.rawValue
                cell.contentConfiguration = content
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "First Alarm"
                content.secondaryText = event.firstAlarm.rawValue
                cell.contentConfiguration = content
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Second Alarm"
                content.secondaryText = event.secondAlarm.rawValue
                cell.contentConfiguration = content
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
            }
        case 2:
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
            if let notes = event.notes {

                noteCell.textField.text = notes
            } else {
                noteCell.textField.text = "No notes..."
                noteCell.textField.textColor = .lightGray
            }
            return noteCell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [0,1] where isDateOpen == false:
            return 0
        case [0,1]:
            return 190
        case [0,3] where isTimeOpen == false:
            return 0
        case [0,3]:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0,1]{
            return 190
        } else {
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Date:"
        case 1:
            return "Notifications:"
        case 2:
            return "Tasks:"
        case 3:
            return "Notes:"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

extension EventDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        event.notes = textView.text
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: [3,0], at: .none, animated: true)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray && textView.isFirstResponder {
            textView.text = nil
            textView.textColor = .black
        }
    }
}
