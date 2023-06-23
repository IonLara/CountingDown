//
//  EventCollectionViewCell.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 05/06/23.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var remainderLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    //Buttons:
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var syncedButton: UIButton!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var emoji: UILabel!
    
    var isEditing = false {
        didSet {
            deleteButton.isHidden = !isEditing
            favoriteButton.isHidden = !isEditing
            shareButton.isHidden = !isEditing
            editView.isHidden = !isEditing
        }
    }
}
