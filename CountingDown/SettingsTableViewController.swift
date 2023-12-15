//
//  SettingsTableViewController.swift
//  CountingDown
//
//  Created by Ion Sebastian Rodriguez Lara on 14/12/23.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Manager.loadUser()
        
        usernameLabel.text = Manager.user?.username
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Table view data source
    @IBAction func EnterTapped(_ sender: UITextField) {
        Manager.user?.username = sender.text!
        Manager.saveUser()
        
        let groups = Manager.loadGroups()
        
        for group in groups! {
            if let index = group.members.firstIndex(of: Manager.user!) {
                group.members[index].username = sender.text!
            }
        }
        
        Manager.saveGroups(groups!)
        
        dismissKeyboard()
    }
    @IBAction func EditedName(_ sender: UITextField) {
        Manager.user?.username = sender.text!
        Manager.saveUser()
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
