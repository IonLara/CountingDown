//
//  NotificationTableViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 09/06/23.
//

import UIKit

class NotificationTableViewController: UITableViewController {

    var current: Event.NotificationCadency!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
        let cadency = Event.NotificationCadency.all[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = cadency.rawValue
        cell.contentConfiguration = content
        cell.accessoryType = cadency == current ? .checkmark : .none
        return cell
    }
}
