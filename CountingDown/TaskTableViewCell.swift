//
//  TaskTableViewCell.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 09/06/23.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskButton: UIButton!
    
    var task: Task!
    
    @IBAction func textFieldUpdated(_ sender: UITextField) {
        task.description = taskTextField.text ?? ""
    }
    @IBAction func tappedDoneButton(_ sender: UIButton) {
        task.isComplete.toggle()
        sender.isSelected.toggle()
    }
    
    func updateFields() {
        taskTextField.text = task.description
        taskButton.isSelected = task.isComplete
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
