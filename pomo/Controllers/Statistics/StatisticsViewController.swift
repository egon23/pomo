//
//  StatisticsViewController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var days: [Day] = []
    @IBOutlet weak var daysTableView: UITableView!
    @IBOutlet weak var weekStatsView: WeekStatsView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Days"
        
        daysTableView.delegate = self
        daysTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let data = try! UIApplication.appDelegate.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "Day")) as! [Day]
        self.days = data
        weekStatsView.setBarsValues(values: days)
        weekStatsView.play()
        daysTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DayCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        cell.dayLabel.text = formatter.string(from: days[indexPath.row].date!)
        
        let secs = lrint(days[indexPath.row].workedHoursInSeconds)
                
        if secs < 60 {
            cell.activeLabel.text = "<0min"
        }
        else if secs < 3600 {
             cell.activeLabel.text = "\(secs/60)min"
        } else {
            cell.activeLabel.text = "\(secs/3600)h \((secs % 3600)/60)min"
        }
        cell.breakLabel.text = "\(lrint(days[indexPath.row].breakMinutesInSeconds/60))min"
        if let tasks = days[indexPath.row].tasks?.allObjects as? [Task] {
            cell.tasksLabel.text = tasks.first?.name
        } else {
            cell.tasksLabel.text = ""
        }
        cell.sessionLabel.text = Int(days[indexPath.row].intervals).description
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDay" {
            let vc = segue.destination as! DayViewController
                if let cell = sender as? DayCell {
                    vc.date = cell.dayLabel.text!
                    vc.activeTime = cell.activeLabel.text!
                    vc.tasks = cell.tasksLabel.text!
                    vc.breakTime = cell.breakLabel.text!
                    
                }
            
        }

    }
}

