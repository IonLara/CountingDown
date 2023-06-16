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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        addSubview(line)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
