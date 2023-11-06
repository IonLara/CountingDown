//
//  MembersTableViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 22/10/23.
//

import UIKit

class MembersTableViewController: UITableViewController {
    
    var group: Group!
    var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addedMember() {
        print("Added Member")
    }
    
    @objc func dismissAlert() {
        if presentedViewController is UIAlertController {
            self.dismiss(animated: true)
        }
    }
    
    @objc func addAdmin() {
        print("Adding as admin!")
    }
    
    @objc func removeAdmin() {
        if group.admins.count == 1 {
            print("Can't remove! There must be at least 1 admin.")
        } else {
            
        }
    }
    
    @objc func removeMember() {
        if group.members.count == 1 {
            print("Can't remove, there must be at least 1 member.")
        } else {
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return group.members.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Title", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
        if indexPath.row <= group.members.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Member", for: indexPath)
            var content = cell.defaultContentConfiguration()
            let user = group.members[indexPath.row - 1]
            content.text = user.username
            if group.admins.contains(user) {
                content.secondaryText = "Admin"
            } else {
                content.secondaryText = ""
            }
            cell.contentConfiguration = content
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Add", for: indexPath)
            addButton = cell.viewWithTag(100) as? UIButton
            addButton.addTarget(self, action: #selector(addedMember), for: .primaryActionTriggered)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row <= group.members.count {
            if group.admins.contains(Manager.user!) {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                if group.admins.contains(group.members[indexPath.row - 1]) {
                    //Delete as Admin
                    alertController.addAction(UIAlertAction(title: "Remove as Admin", style: .default, handler: {_ in
                        self.removeAdmin()
                    }))
                } else {
                    //Add as Admin
                    alertController.addAction(UIAlertAction(title: "Set as Admin", style: .default, handler: {_ in
                        self.addAdmin()
                    }))
                }
                
                alertController.addAction(UIAlertAction(title: "Remove from Group", style: .destructive, handler: {_ in
                    self.removeMember()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                    self.dismissAlert()
                }))
                present(alertController, animated: true)
                
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
