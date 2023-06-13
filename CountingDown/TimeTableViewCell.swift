//
//  TimeTableViewCell.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 13/06/23.
//

import UIKit

class TimeTableViewCell: UITableViewCell {

    let timePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .inline
        return dp
    }()
    let label: UILabel = {
       let label = UILabel()
        label.text = "Time:"
        label.font = .boldSystemFont(ofSize: 19)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(timePicker)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        timePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
