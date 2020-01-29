//
//  DayViewController.swift
//  pomo
//
//  Created by roli on 29.01.20.
//  Copyright © 2020 Egon Manya. All rights reserved.
//

import UIKit

class DayViewController: UIViewController {

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var activeTimeLabel: UILabel!
    @IBOutlet weak var breakTimeLabel: UILabel!
    
    var date = ""
    var tasks = ""
    var activeTime = ""
    var breakTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = date
        tasksLabel.text = tasks
        activeTimeLabel.text = activeTime
        breakTimeLabel.text = breakTime
        
        tasksLabel.sizeToFit()
        activeTimeLabel.sizeToFit()
        breakTimeLabel.sizeToFit()
    }
    

    

}
