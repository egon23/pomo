//
//  FirstViewController.swift
//  pomo
//
//  Created by Egon Manya on 28.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var daysTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysTableView.delegate = self
        daysTableView.dataSource = self
        
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as! DayCell
        
        cell.dayLabel.text = "01.01.10"
        cell.activeLabel.text = "4h 20min"
        cell.breakLabel.text = "96 min"
        cell.tasksLabel.text = "Chillin"
        cell.sessionLabel.text = "1"
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

