//
//  TimeInfoTableViewCell.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 13/06/23.
//

import UIKit

class TimeInfoTableViewCell: UITableViewCell {
    
    let label: UILabel = {
        let lab = UILabel()
        lab.text = "Is all day:"
        lab.font = .boldSystemFont(ofSize: 19)
        return lab
    }()
    
    let allDaySwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(allDaySwitch)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        
        allDaySwitch.translatesAutoresizingMaskIntoConstraints = false
        allDaySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        allDaySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
