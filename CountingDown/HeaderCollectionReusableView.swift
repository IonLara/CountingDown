//
//  HeaderCollectionReusableView.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 15/06/23.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    let label = UILabel()
    let line: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }()
    
    let button: UIButton = {
        let bttn = UIButton()
        
        bttn.configuration = .borderless()
        bttn.setTitle("Sort", for: .normal)
        bttn.setTitleColor(.darkGray, for: .normal)
        return bttn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button)
        addSubview(label)
        addSubview(line)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 5).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
