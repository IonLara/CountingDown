//
//  EventCollectionViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import UIKit

private let reuseIdentifier = "EventCell"

class EventCollectionViewController: UICollectionViewController {

    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedEvents = Manager.loadEvents() {
            events = savedEvents
        } else {
            events = Manager.loadBaseEvents()
        }
    }
}
