//
//  TasksSettingsViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class TasksSettingsViewController: UITableViewController {

    
    var tasks: [Taskk] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tasks"
        print(tasks.count)
        
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        
        tasks[indexPath.row].hoursWorked = 3
        
        cell.titleLabel.text = tasks[indexPath.row].name
        cell.timeLabel.text = "\(Int(tasks[indexPath.row].hoursWorked))/\(Int(tasks[indexPath.row].estimatedHours))"
        cell.deadlineLabel.text = tasks[indexPath.row].date
        
        let progress = Int(tasks[indexPath.row].hoursWorked/tasks[indexPath.row].estimatedHours*100)
        cell.progressLabel.text = "\(progress)%"
        
        cell.titleLabel.sizeToFit()
        cell.progressLabel.sizeToFit()
        cell.timeLabel.sizeToFit()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateTask" {
            if let vc = segue.destination as? AddTaskViewController{
                
            }
        }
    }
    
    @IBAction func didUnwind(_ sender: UIStoryboardSegue){
        guard let vc = sender.source as? AddTaskViewController else {return}
        let task: Taskk = Taskk(name: vc.titelTextField.text ?? "", estimatedHours: Float(vc.hoursTextField.text ?? "")!)
        tasks.append(task)
        tableView.reloadData()
    }
   
    
    
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

extension TasksSettingsViewController: AddTaskDelegate{
    
    func addTask(task: Taskk) {
        print("test")
        self.dismiss(animated: true) {
            self.tasks.append(task)
            self.tableView.reloadData()
        }
    }
    
}
