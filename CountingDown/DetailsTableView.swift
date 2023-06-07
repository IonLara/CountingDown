//
//  DetailsTableView.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 06/06/23.
//

import UIKit

class DetailsTableView: UITableView {
    
    
    
    override func numberOfRows(inSection section: Int) -> Int {
        2
    }

    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        print("Hi")
        
        return self.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
        
    }
}
