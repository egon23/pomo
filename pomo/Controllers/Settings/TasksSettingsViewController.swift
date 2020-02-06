//
//  TasksSettingsViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import CoreData

class TasksSettingsViewController: UITableViewController {

    
    var tasks: [Task] = []
    var empty = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Task")) as! [Task]
        
        self.tasks = data
        if tasks.count > 0 {empty = false}
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tasks"
        
        
        
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if empty {return 1}
        
        return tasks.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tasks.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            print("cell")
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
            
            
            cell.titleLabel.text = tasks[indexPath.row].name
            let secs = lrint(tasks[indexPath.row].workedHours)
                    
            if secs < 60 {
                cell.timeLabel.text = "<0min"
            }
            else if secs < 3600 {
                 cell.timeLabel.text = "\(secs/60)min"
            } else {
                cell.timeLabel.text = "\(secs/3600)h \((secs % 3600)/60)min"
            }
            
            cell.goalLabel.text = "\(Int(tasks[indexPath.row].estimatedHours))h"
            
            let progress = lrint(Double(secs)/(tasks[indexPath.row].estimatedHours*3600)*100)
            cell.progressLabel.text = "\(progress)%"
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formatterString = formatter.string(from: tasks[indexPath.row].deadline ?? Date())
            let formatterDate = formatter.date(from: formatterString)
            formatter.dateFormat = "dd MMM. yyyy"
            
            cell.deadlineLabel.text = formatter.string(from: formatterDate!)
            
            cell.deadlineLabel.sizeToFit()
            cell.titleLabel.sizeToFit()
            cell.progressLabel.sizeToFit()
            cell.timeLabel.sizeToFit()
            cell.goalLabel.sizeToFit()
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateTask" {
            if let vc = segue.destination as? AddTaskViewController{
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let data = tasks[indexPath.row]
            UIApplication.appDelegate.persistentContainer.viewContext.delete(data)
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            UIApplication.appDelegate.saveContext()
            if tasks.count == 0 {
                empty = true
            }
            tableView.reloadData()
        }
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

