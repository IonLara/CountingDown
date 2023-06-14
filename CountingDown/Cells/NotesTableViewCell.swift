//
//  NotesTableViewCell.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 13/06/23.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    let textField: UITextView = {
        let tf = UITextView()
        tf.text = ""
        tf.isEditable = true
        tf.isScrollEnabled = false
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
