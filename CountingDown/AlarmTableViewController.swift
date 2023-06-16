//
//  AlarmTableViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 13/06/23.
//

import UIKit

class AlarmTableViewController: UITableViewController {
    
    var disabledIndex: Int!
    var editView: EventDetailViewController!
    var current: Event.AlarmTime!
    var event: Event!
    var isFirst = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isFirst {
            event.firstAlarm = Event.AlarmTime.all[indexPath.row]
            editView.tableView.reloadRows(at: [[1,1]], with: .automatic)
        } else {
            event.secondAlarm = Event.AlarmTime.all[indexPath.row]
            editView.tableView.reloadRows(at: [[1,2]], with: .automatic)
        }
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = Event.AlarmTime.all[indexPath.row].rawValue
        if isFirst {
            if indexPath.row == event.firstAlarm.index {
                cell.accessoryType = .checkmark
            } else if indexPath.row == event.secondAlarm.index && event.secondAlarm.index > 0 {
                cell.backgroundColor = .systemGray4
                cell.isUserInteractionEnabled = false
                content.textProperties.color = .black
            }
        } else {
            if indexPath.row == event.secondAlarm.index {
                cell.accessoryType = .checkmark
            } else if indexPath.row == event.firstAlarm.index && event.firstAlarm.index > 0 {
                cell.backgroundColor = .systemGray4
                cell.isUserInteractionEnabled = false
                content.textProperties.color = .black
            }
        }
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFirst {
            return "First Alarm"
        } else {
            return "Second Alarm"
        }
    }
}
