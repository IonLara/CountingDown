//
//  SortButtonView.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 21/06/23.
//

import UIKit

class SortButtonView: UICollectionReusableView {
        
    
    let label = UILabel()
    let line: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }()
    
    let button: UIButton = {
        let bttn = UIButton()
        bttn.titleLabel?.text = "Sort"
        bttn.tintColor = .blue
        return bttn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        addSubview(line)
        addSubview(button)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
